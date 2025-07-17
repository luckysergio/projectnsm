<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Karyawan;
use Illuminate\Support\Facades\Hash;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;
use PHPOpenSourceSaver\JWTAuth\Exceptions\JWTException;
use Illuminate\Support\Facades\Log;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $login = $request->input('login');
        $password = $request->input('password');

        $user = null;

        if (filter_var($login, FILTER_VALIDATE_EMAIL)) {
            $user = User::where('email', $login)->first();
        } else {
            $karyawan = Karyawan::where('nik', $login)->first();
            if ($karyawan) {
                $user = $karyawan->user;
            }
        }

        if (!$user || !Hash::check($password, $user->password)) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        $token = JWTAuth::fromUser($user);

        return response()->json([
            'token' => $token,
            'user' => $user->load('karyawan.role')
        ]);
    }

    public function me(Request $request)
    {
        try {
            $user = JWTAuth::parseToken()->authenticate();
            Log::info('User authenticated: ', ['user' => $user]);

            if (!$user) {
                return response()->json(['error' => 'User not found'], 404);
            }

            $user->load('karyawan.role');

            return response()->json(['user' => $user]);
        } catch (\Exception $e) {
            Log::error('JWT Auth Me Error: ' . $e->getMessage());
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function logout()
    {
        try {
            JWTAuth::invalidate(JWTAuth::getToken());
            return response()->json(['message' => 'Successfully logged out']);
        } catch (JWTException $e) {
            return response()->json(['error' => 'Failed to logout'], 500);
        }
    }

    public function refresh()
    {
        try {
            $newToken = JWTAuth::refresh(JWTAuth::getToken());
            return response()->json([
                'token' => $newToken
            ]);
        } catch (JWTException $e) {
            return response()->json(['error' => 'Failed to refresh token'], 500);
        }
    }

    public function checkAuth(Request $request)
    {
        return response()->json(['message' => 'Token valid'], 200);
    }

    public function changePassword(Request $request)
    {
        // Validasi input
        $request->validate([
            'old_password' => 'required',
            'new_password' => 'required|min:6|confirmed',
        ]);

        try {
            $user = JWTAuth::parseToken()->authenticate();

            if (!$user) {
                return response()->json(['error' => 'User not found'], 404);
            }

            if (!Hash::check($request->old_password, $user->password)) {
                return response()->json(['error' => 'Password lama tidak sesuai'], 401);
            }

            $user->password = bcrypt($request->new_password);
            $user->save();

            return response()->json(['message' => 'Password berhasil diubah']);
        } catch (\Exception $e) {
            Log::error('Change Password Error: ' . $e->getMessage());
            return response()->json(['error' => 'Terjadi kesalahan'], 500);
        }
    }
}
