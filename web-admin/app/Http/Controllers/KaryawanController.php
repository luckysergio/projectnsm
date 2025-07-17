<?php

namespace App\Http\Controllers;

use App\Models\Karyawan;
use App\Models\User;
use App\Models\Role;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class KaryawanController extends Controller
{
    public function index(Request $request)
    {
        $search = $request->input('search');
        $roleId = $request->input('role_id');

        $karyawans = Karyawan::with(['user', 'role'])
            ->when($search, function ($query) use ($search) {
                $query->where(function ($q) use ($search) {
                    $q->where('nama', 'like', "%$search%")
                      ->orWhere('nik', 'like', "%$search%");
                });
            })
            ->when($roleId, function ($query) use ($roleId) {
                $query->where('role_id', $roleId);
            })
            ->orderBy('role_id', 'asc')
            ->orderBy('created_at', 'desc')
            ->paginate(10)
            ->withQueryString();

        $roles = Role::orderBy('jabatan')->get();

        return view('pages.karyawan.index', compact('karyawans', 'roles'));
    }

    public function create()
    {
        $roles = Role::all();
        $users = User::doesntHave('karyawan')->get();

        return view('pages.karyawan.create', compact('roles', 'users'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama'      => 'required|string|max:50',
            'nik'       => 'required|numeric|unique:karyawans,nik',
            'email'     => 'nullable|email|unique:users,email|required_with:password',
            'password'  => 'nullable|min:6|required_with:email',
            'role_id'   => 'nullable|exists:roles,id',
            'new_role'  => 'nullable|string|max:50',
        ], [
            'email.required_with'    => 'Email wajib diisi jika password diisi.',
            'password.required_with' => 'Password wajib diisi jika email diisi.',
        ]);

        try {
            DB::transaction(function () use ($request) {
                if (!$request->role_id && $request->new_role) {
                    $role = Role::create([
                        'jabatan' => $request->new_role
                    ]);
                    $role_id = $role->id;
                } else {
                    $role_id = $request->role_id;
                }

                $user_id = null;
                if ($request->filled('email') && $request->filled('password')) {
                    $user = User::create([
                        'email'    => $request->email,
                        'password' => bcrypt($request->password),
                    ]);
                    $user_id = $user->id;
                }

                Karyawan::create([
                    'nama'    => $request->nama,
                    'nik'     => $request->nik,
                    'role_id' => $role_id,
                    'user_id' => $user_id,
                ]);
            });

            return back()->with('success', 'Data karyawan berhasil ditambahkan.');
        } catch (\Exception $e) {
            return back()->with('error', 'Gagal menyimpan data: ' . $e->getMessage());
        }
    }

    public function edit($id)
    {
        $karyawan = Karyawan::with(['user', 'role'])->findOrFail($id);
        $roles = Role::all();

        return view('pages.karyawan.edit', compact('karyawan', 'roles'));
    }

    public function update(Request $request, $id)
    {
        $karyawan = Karyawan::findOrFail($id);
        $user = $karyawan->user;

        $validated = $request->validate([
            'nama'     => 'required|string|max:50',
            'nik'      => 'required|numeric|unique:karyawans,nik,' . $karyawan->id,
            'email'    => [
                'nullable',
                'email',
                'required_with:password',
                Rule::unique('users', 'email')->ignore(optional($user)->id),
            ],
            'password' => 'nullable|min:6|required_with:email',
            'role_id'  => 'nullable|exists:roles,id',
        ], [
            'email.required_with'    => 'Email wajib diisi jika password diisi.',
            'password.required_with' => 'Password wajib diisi jika email diisi.',
        ]);

        try {
            DB::transaction(function () use ($validated, $request, $karyawan, $user) {
                if ($user) {
                    $user->update([
                        'email'    => $validated['email'],
                        'password' => $request->filled('password')
                            ? bcrypt($validated['password'])
                            : $user->password,
                    ]);
                } elseif ($request->filled('email') && $request->filled('password')) {
                    $newUser = User::create([
                        'email'    => $validated['email'],
                        'password' => bcrypt($validated['password']),
                    ]);
                    $karyawan->user_id = $newUser->id;
                    $karyawan->save();
                }

                // Update karyawan
                $karyawan->update([
                    'nama'    => $validated['nama'],
                    'nik'     => $validated['nik'],
                    'role_id' => $validated['role_id'],
                ]);
            });

            return back()->with('success', 'Data karyawan berhasil diubah.');
        } catch (\Exception $e) {
            return back()->with('error', 'Gagal mengubah data: ' . $e->getMessage());
        }
    }

    public function destroy($id)
    {
        try {
            $karyawan = Karyawan::findOrFail($id);

            if ($karyawan->user) {
                $karyawan->user->delete();
            }

            $karyawan->delete();

            return back()->with('success', 'Data karyawan dan user berhasil dihapus.');
        } catch (\Exception $e) {
            return back()->with('error', 'Gagal menghapus data: ' . $e->getMessage());
        }
    }
}
