<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\Auth;

class AdminMiddleware
{
    public function handle($request, Closure $next)
    {
        if (!Auth::check()) {
            return redirect()->route('login')->with('error', 'Silahkan login terlebih dahulu.');
        }

        $user = Auth::user();

        if (!$user->karyawan || !$user->karyawan->role || strtolower($user->karyawan->role->jabatan) !== 'admin') {
            Auth::logout();
            return redirect()->route('login')->with('error', 'Akses ditolak! Anda tidak memiliki hak akses.');
        }

        return $next($request);
    }
}
