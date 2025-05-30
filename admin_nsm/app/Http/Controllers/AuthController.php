<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{

    public function login1()
    {
        // if (Auth::check()) {
        //     return back();
        // }

        return view('pages.auth.login');
    }

    public function authenticate(Request $request)
    {
        $request->validate([
            'nik' => ['required', 'numeric', 'digits_between:1,20'],
            'password' => ['required']
        ], [
            'nik.required' => 'Nomer Induk Karyawan harus diisi',
            'nik.numeric' => 'Nomer Induk Karyawan harus berupa angka',
            'nik.digits_between' => 'Nomer Induk Karyawan harus antara 1-20 digit',
            'password.required' => 'Password harus diisi',
        ]);


        $user = User::where('nik', $request->nik)->first();
        if (!$user) {
            return back()->withErrors([
                'nik' => 'NIK tidak terdaftar'
            ])->onlyInput('nik');
        }

        if (!Auth::attempt(['nik' => $request->nik, 'password' => $request->password])) {
            return back()->withErrors([
                'password' => 'Password salah, silakan coba lagi'
            ])->onlyInput('nik');
        }

        $request->session()->regenerate();

        if ($user->role == 'sales') {
            $this->_logout($request);
            return back()->withErrors([
                'nik' => 'Hanya Admin yang dapat login!! Untuk sales silahkan menggunakan aplikasi mobile'
            ]);
        } else if ($user->role == 'pj_alat') {
            $this->_logout($request);
            return back()->withErrors([
                'nik' => 'Hanya Admin yang dapat login!! Untuk Penanggung Jawab Alat silahkan menggunakan aplikasi mobile'
            ]);
        }
        return redirect('/')->with('success', 'Email dan password benar, tekan oke untuk menuju dashboard');
    }


    public function _logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
    }

    public function logout1(Request $request)
    {
        if (!Auth::check()) {
            return back();
        }

        $this->_logout($request);

        return redirect('/');
    }


    public function index(Request $request)
    {
        $query = User::query();

        // Jika ada pencarian
        if ($request->has('search')) {
            $search = $request->search;
            $query->where('name', 'like', "%$search%")
                ->orWhere('nik', 'like', "%$search%");
        }

        $user = $query->get();

        return view('pages.user.index', compact('user'));
    }


    public function create1()
    {
        return view('pages.user.create1');
    }

    public function register1(Request $request)
    {
        try {
            // Menambahkan pesan custom untuk setiap validasi
            $request->validate([
                'name' => 'required|string|max:255',
                'nik' => 'required|numeric|digits:10|unique:users',
                'role' => 'required|in:admin,sales,pj_alat',
                'email' => 'required|string|email|max:255|unique:users',
                'password' => 'required|string|min:6|confirmed',
            ], [
                'name.required' => 'Nama lengkap harus diisi.',
                'nik.required' => 'Nomor Induk Karyawan (NIK) harus diisi.',
                'nik.numeric' => 'NIK hanya boleh berupa angka.',
                'nik.digits' => 'NIK harus terdiri dari 10 angka.',
                'nik.unique' => 'NIK yang Anda masukkan sudah terdaftar.',
                'role.required' => 'Jabatan harus dipilih.',
                'role.in' => 'Jabatan yang dipilih tidak valid.',
                'email.required' => 'Email harus diisi.',
                'email.email' => 'Email yang Anda masukkan tidak valid.',
                'email.unique' => 'Email yang Anda masukkan sudah terdaftar.',
                'password.required' => 'Password harus diisi.',
                'password.min' => 'Password harus memiliki minimal 6 karakter.',
                'password.confirmed' => 'Password dan konfirmasi password tidak sama.',
            ]);

            // Simpan user ke database
            $user = User::create([
                'name' => $request->name,
                'nik' => $request->nik,
                'role' => $request->role,
                'email' => $request->email,
                'password' => Hash::make($request->password),
            ]);


            return redirect('/user/create1')->with('success', 'Berhasil menambah data');
        } catch (\Exception $e) {
            return redirect('/user/create1')->withErrors([
                'error' => $e->getMessage()
            ]);
        }
    }


    public function edit1($id)
    {
        $user = User::findOrFail($id);
        return view('pages.user.edit1', ['user' => $user]);
    }

    public function destroy1($id)
    {
        $user = User::findOrFail($id);
        $user->delete();
        return redirect('/user')->with('success', 'Berhasil menghapus data');
    }


    public function register(Request $request)
    {
        try {
            $request->validate([
                'name' => 'required|string|max:255',
                'nik' => 'required|numeric|digits:10|unique:users',
                'role' => 'required|in:admin,sales,pj_alat',
                'email' => 'required|string|email|max:255|unique:users',
                'password' => 'required|string|min:6|confirmed',
            ]);

            $user = User::create([
                'name' => $request->name,
                'nik' => $request->nik,
                'role' => $request->role,
                'email' => $request->email,
                'password' => Hash::make($request->password),
            ]);

            $token = JWTAuth::fromUser($user);

            return response()->json([
                'success' => true,
                'message' => 'User berhasil didaftarkan',
                'user' => $user,
                'token' => $token
            ], 201);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat register',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function login(Request $request)
    {
        try {
            $request->validate([
                'nik' => 'required|numeric|digits:10',
                'password' => 'required|string|min:6',
            ]);

            $credentials = $request->only('nik', 'password');

            if (!$token = JWTAuth::attempt($credentials)) {
                return response()->json([
                    'success' => false,
                    'message' => 'NIK atau password salah'
                ], 401);
            }

            return response()->json([
                'success' => true,
                'message' => 'Login berhasil',
                'token' => $token,
                'user' => Auth::user()
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat login',
                'error' => $e->getMessage()
            ], 500);
        }
    }


    public function profile()
    {
        try {
            return response()->json([
                'success' => true,
                'message' => 'Profil user',
                'user' => Auth::user()
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mendapatkan data user',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function logout()
    {
        try {
            JWTAuth::invalidate(JWTAuth::getToken());

            return response()->json([
                'success' => true,
                'message' => 'Logout berhasil'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal logout',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, $id)
    {
        try {
            // Validasi input
            $request->validate([
                'name' => 'required|string|max:255',
                'nik' => 'required|numeric|digits:10|unique:users,nik,' . $id,
                'role' => 'required|in:admin,sales,pj_alat',
                'email' => 'required|string|email|max:255|unique:users,email,' . $id,
                'password' => 'nullable|string|min:6|confirmed',
            ]);

            // Cari user berdasarkan ID
            $user = User::findOrFail($id);

            // Update data user
            $user->name = $request->name;
            $user->nik = $request->nik;
            $user->role = $request->role;
            $user->email = $request->email;

            // Jika password diisi, update password
            if ($request->filled('password')) {
                $user->password = Hash::make($request->password);
            }

            $user->save();

            return back()->with('success', 'Data user berhasil diperbarui');
        } catch (ValidationException $e) {
            return back()->withErrors($e->errors())->withInput();
        } catch (\Exception $e) {
            return back()->with('error', 'Terjadi kesalahan saat memperbarui user: ' . $e->getMessage());
        }
    }
}
