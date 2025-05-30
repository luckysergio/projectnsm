<?php

namespace App\Http\Controllers;

use App\Models\Inventory;
use Illuminate\Http\Request;

class InventoryController extends Controller
{

    public function index1(Request $request)
    {
        $search = $request->input('search');

        $inventory = Inventory::when($search, function ($query, $search) {
            return $query->where('nama_alat', 'like', "%{$search}%")
                ->orWhere('jenis_alat', 'like', "%{$search}%");
        })
            ->orderBy('waktu_pemakaian', 'desc')
            ->get();

        return view('pages.inventory.index1', compact('inventory'));
    }


    public function create1()
    {
        return view('pages.inventory.create1');
    }

    public function store1(Request $request)
    {
        try {
            $validateData = $request->validate([
                'nama_alat' => 'required|string',
                'jenis_alat' => 'required|in:pompa_standart,pompa_longboom,pompa_superlong,pompa_kodok,pompa_mini',
                'status' => 'required|in:tersedia,sedang_disewa,sedang_perawatan',
                'waktu_pemakaian' => 'required|integer|min:0',
                'harga' => 'required|decimal:0,2|min:0',
            ]);

            Inventory::create($validateData);

            return back()->with('success', 'Berhasil menambah data');
        } catch (\Exception $e) {
            return back()->with('error', 'Gagal menambah data: ' . $e->getMessage())->withInput();
        }
    }


    public function update1(Request $request, $id)
    {
        try {
            $validatedData = $request->validate([
                'nama_alat' => 'required|string',
                'jenis_alat' => 'required|in:pompa_standart,pompa_longboom,pompa_superlong,pompa_kodok,pompa_mini',
                'status' => 'required|in:tersedia,sedang_disewa,sedang_perawatan',
                'waktu_pemakaian' => 'required|integer|min:0',
                'harga' => 'required|decimal:0,2|min:0',
            ]);

            $inventory = Inventory::findOrFail($id);
            $inventory->update($validatedData);

            return back()->with('success', 'Berhasil mengubah data');
        } catch (\Exception $e) {
            return back()->with('error', 'Gagal mengubah data: ' . $e->getMessage())->withInput();
        }
    }


    public function edit1($id)
    {
        $resident = Inventory::findOrFail($id);
        return view('pages.inventory.edit1', ['resident' => $resident]);
    }

    public function destroy1($id)
    {
        $inventory = Inventory::findOrFail($id);
        $inventory->delete();
        return redirect('/Inventory')->with('success', 'Berhasil menghapus data');
    }

    public function index()
    {
        return response()->json(Inventory::all());
    }

    public function show($id)
    {
        $inventory = Inventory::find($id);

        if (!$inventory) {
            return response()->json(['message' => 'Alat tidak ditemukan'], 404);
        }

        return response()->json($inventory);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama_alat' => 'required|string',
            'jenis_alat' => 'required|in:pompa_standart,pompa_longboom,pompa_superlong,pompa_kodok,pompa_mini',
            'status' => 'required|in:tersedia,sedang_disewa,sedang_perawatan',
            'waktu_pemakaian' => 'required|integer|min:0',
        ]);

        $inventory = Inventory::create($request->all());

        return response()->json(['message' => 'Alat berhasil ditambahkan', 'data' => $inventory], 201);
    }

    public function update(Request $request, $id)
    {
        $inventory = Inventory::find($id);

        if (!$inventory) {
            return response()->json(['message' => 'Alat tidak ditemukan'], 404);
        }

        $request->validate([
            'nama_alat' => 'string',
            'jenis_alat' => 'in:pompa_standart,pompa_longboom,pompa_superlong,pompa_kodok,pompa_mini',
            'status' => 'in:tersedia,sedang_disewa,sedang_perawatan',
            'waktu_pemakaian' => 'integer|min:0',
        ]);

        $inventory->update($request->all());

        return response()->json(['message' => 'Alat berhasil diperbarui', 'data' => $inventory]);
    }

    public function destroy($id)
    {
        $inventory = Inventory::find($id);

        if (!$inventory) {
            return response()->json(['message' => 'Alat tidak ditemukan'], 404);
        }

        $inventory->delete();

        return response()->json(['message' => 'Alat berhasil dihapus']);
    }

    public function getTersedia()
    {
        $inventori = Inventory::where('status', 'tersedia')->get();
        return response()->json($inventori);
    }

    public function getByJenis(Request $request, $jenis)
    {
        $allowedJenis = ['pompa_standart', 'pompa_longboom', 'pompa_superlong', 'pompa_kodok', 'pompa_mini'];
        if (!in_array($jenis, $allowedJenis)) {
            return response()->json(['message' => 'Jenis alat tidak valid'], 400);
        }

        $inventory = Inventory::where('jenis_alat', $jenis)
            ->orderBy('waktu_pemakaian', 'desc')
            ->get();

        return response()->json($inventory);
    }
}
