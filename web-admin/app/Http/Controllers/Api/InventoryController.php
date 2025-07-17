<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Inventory;
use App\Models\JenisAlat;
use Illuminate\Http\Request;

class InventoryController extends Controller
{
    public function index()
    {
        $inventories = Inventory::with('jenisAlat')->get();

        return response()->json([
            'status' => 'success',
            'data' => $inventories
        ]);
    }

    public function filterByCategory($kategori)
    {
        $kategoriFormatted = str_replace('_', ' ', strtolower($kategori));

        $inventories = Inventory::with('jenisAlat')
            ->whereHas('jenisAlat', function ($query) use ($kategoriFormatted) {
                $query->whereRaw('LOWER(nama) = ?', [$kategoriFormatted]);
            })
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $inventories
        ]);
    }

    public function getJenisAlat()
    {
        $jenisAlat = JenisAlat::select('id', 'nama')->get();
        return response()->json([
            'status' => 'success',
            'data' => $jenisAlat
        ]);
    }

    public function tersedia()
    {
        $available = Inventory::with('jenisAlat')
            ->where('status', 'tersedia')
            ->get();

        if ($available->isEmpty()) {
            return response()->json([
                'status' => 'success',
                'message' => 'Tidak ada inventory dengan status tersedia',
                'data' => []
            ]);
        }

        return response()->json([
            'status' => 'success',
            'data' => $available
        ]);
    }
}
