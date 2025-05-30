<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::factory()->create([
            'name' => 'ADMIN NIAGA SOLUSI MANDIRI',
            'nik' => '0000000000',
            'role' => 'admin',
            'email' => 'admin@nsm.com',
            'password' => '12341234'
        ]);
    }
}
