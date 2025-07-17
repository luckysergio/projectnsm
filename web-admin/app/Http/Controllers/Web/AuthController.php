<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AuthController extends Controller
{
    public function showLoginForm()
    {
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'login' => 'required|string',
            'password' => 'required|string|min:8',
        ]);

        $loginInput = $request->input('login');
        $password = $request->input('password');

        if (filter_var($loginInput, FILTER_VALIDATE_EMAIL)) {
            $user = User::with('karyawan.role')
                ->where('email', $loginInput)
                ->first();
        } else {
            $user = User::with('karyawan.role')
                ->whereHas('karyawan', function ($query) use ($loginInput) {
                    $query->where('nik', $loginInput);
                })
                ->first();
        }

        if (!$user) {
            return back()->with('error', 'Email atau NIK tidak ditemukan.')->withInput();
        }

        if (!Hash::check($password, (string) $user->password)) {
            return back()->with('error', 'Password salah.')->withInput();
        }

        if (
            !$user->karyawan ||
            !$user->karyawan->role ||
            strtolower($user->karyawan->role->jabatan) !== 'admin'
        ) {
            return back()->with('error', 'Akses ditolak. Hanya Admin yang dapat login.')->withInput();
        }

        Auth::login($user);
        return redirect()->route('dashboard')->with('success', 'Berhasil login!');
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect('/')->with('success', 'Berhasil logout!');
    }
}
