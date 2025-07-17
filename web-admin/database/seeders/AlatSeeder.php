<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Inventory;
use App\Models\JenisAlat;

class AlatSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $dataAlat = [
            'Pompa Mini' => 437500,
            'Pompa Standart' => 437500,
            'Pompa Longboom' => 625000,
            'Pompa Super Longboom' => 937500,
            'Pompa Kodok' => 1062500,
        ];

        foreach ($dataAlat as $namaJenis => $harga) {
            $jenis = JenisAlat::where('nama', $namaJenis)->first();

            if ($jenis) {
                Inventory::create([
                    'nama' => $namaJenis,
                    'jenis_id' => $jenis->id,
                    'status' => 'tersedia',
                    'harga' => $harga,
                    'pemakaian' => 0,
                ]);
            }
        }
    }
}
