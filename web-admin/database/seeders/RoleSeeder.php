<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Role;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        Role::create(['jabatan' => 'Admin']);
        Role::create(['jabatan' => 'Sales']);
        Role::create(['jabatan' => 'Penanggung Jawab Alat']);
        Role::create(['jabatan' => 'Operator Alat']);
        Role::create(['jabatan' => 'Operator Maintenance']);
    }
}
