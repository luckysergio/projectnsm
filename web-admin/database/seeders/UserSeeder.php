<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Karyawan;
use App\Models\Role;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $adminRole = Role::where('jabatan', 'Admin')->first();

        if (!$adminRole) {
            $adminRole = Role::create(['jabatan' => 'Admin']);
        }

        $user = User::create([
            'email' => 'admin@nsm.com',
            'password' => Hash::make('12341234'),
        ]);

        Karyawan::create([
            'nik' => '0000000000',
            'nama' => 'Admin Utama',
            'user_id' => $user->id,
            'role_id' => $adminRole->id,
        ]);
    }
}
