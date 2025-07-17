<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\JenisAlat;

class JenisAlatSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        JenisAlat::create(['nama' => 'Pompa Mini']);
        JenisAlat::create(['nama' => 'Pompa Standart']);
        JenisAlat::create(['nama' => 'Pompa Longboom']);
        JenisAlat::create(['nama' => 'Pompa Super Longboom']);
        JenisAlat::create(['nama' => 'Pompa Kodok']);
    }
}
