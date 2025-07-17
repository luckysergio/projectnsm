<?php

namespace App\Http\Controllers;

use App\Models\Inventory;
use App\Models\JenisAlat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class InventoryController extends Controller
{
    public function index(Request $request)
    {
        $jenisId = $request->input('jenis_id');

        $inventories = Inventory::with('jenisAlat')
            ->when($jenisId, function ($query) use ($jenisId) {
                $query->where('jenis_id', $jenisId);
            })
            ->orderBy('jenis_id', 'asc') // Urutkan berdasarkan ID jenis
            ->paginate(10)
            ->withQueryString();

        $jenisList = JenisAlat::orderBy('nama')->get(); // ✅ ganti 'nama_jenis' jadi 'nama'

        return view('pages.inventori.index', compact('inventories', 'jenisList'));
    }

    public function create()
    {
        $jenisAlats = JenisAlat::all();
        return view('pages.inventori.create', compact('jenisAlats'));
    }

    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'nama' => 'required|string|max:255',
            'jenis_id' => 'nullable|exists:jenis_alats,id',
            'new_jenis' => 'nullable|string|max:255',
            'harga' => 'required|string',
            'pemakaian' => 'required|integer',
            'status' => 'required|in:tersedia,disewa,perawatan',
        ]);

        if (!$validatedData['jenis_id'] && $validatedData['new_jenis']) {
            $existingJenis = JenisAlat::where('nama', $validatedData['new_jenis'])->first();
            if ($existingJenis) {
                return back()->withErrors(['new_jenis' => 'Jenis alat sudah tersedia, silakan pilih dari daftar.'])->withInput();
            } else {
                $jenis = JenisAlat::create(['nama' => $validatedData['new_jenis']]);
                $validatedData['jenis_id'] = $jenis->id;
            }
        }

        $validatedData['harga'] = preg_replace('/[^\d]/', '', $validatedData['harga']);

        Inventory::create([
            'nama' => $validatedData['nama'],
            'jenis_id' => $validatedData['jenis_id'],
            'harga' => $validatedData['harga'],
            'pemakaian' => $validatedData['pemakaian'],
            'status' => $validatedData['status'],
        ]);

        return back()->with('success', 'Data inventori berhasil ditambahkan.');
    }

    public function edit($id)
    {
        $inventory = Inventory::findOrFail($id);
        $jenisAlats = JenisAlat::all();
        return view('pages.inventori.edit', compact('inventory', 'jenisAlats'));
    }

    public function update(Request $request, $id)
    {
        $inventory = Inventory::findOrFail($id);

        $validatedData = $request->validate([
            'nama' => 'required|string|max:50',
            'harga' => 'required|string',
            'pemakaian' => 'required|integer',
            'status' => 'required|in:tersedia,disewa,perawatan',
            'jenis_id' => 'nullable|exists:jenis_alats,id',
            'new_jenis' => 'nullable|string|max:50',
        ]);

        if (!$validatedData['jenis_id'] && $validatedData['new_jenis']) {
            $existingJenis = JenisAlat::where('nama', $validatedData['new_jenis'])->first();

            if ($existingJenis) {
                return back()->withErrors(['new_jenis' => 'Jenis alat sudah tersedia, silakan pilih dari daftar.'])->withInput();
            } else {
                $jenis = JenisAlat::create(['nama' => $validatedData['new_jenis']]);
                $validatedData['jenis_id'] = $jenis->id;
            }
        }

        $validatedData['harga'] = preg_replace('/[^\d]/', '', $validatedData['harga']);

        $inventory->update([
            'nama' => $validatedData['nama'],
            'jenis_id' => $validatedData['jenis_id'],
            'status' => $validatedData['status'],
            'harga' => $validatedData['harga'],
            'pemakaian' => $validatedData['pemakaian'],
        ]);

        return back()->with('success', 'Data inventory berhasil diubah.');
    }

    public function destroy($id)
    {
        $inventory = Inventory::findOrFail($id);
        $inventory->delete();

        return back()->with('success', 'Data inventory berhasil dihapus.');
    }
}
