<?php

namespace App\Http\Controllers;

use App\Models\Inventory;
use App\Models\Perawatan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;
use Barryvdh\DomPDF\Facade\Pdf;
use DateTime;

class PerawatanController extends Controller
{
    public function index1()
    {
        $perawatan = Perawatan::whereIn('status_perawatan', ['pending', 'proses'])
            ->orderBy('tanggal_mulai', 'asc')
            ->get();

        return view('pages.perawatan.index1', compact('perawatan'));
    }

    public function history(Request $request)
    {
        $query = Perawatan::where('status_perawatan', 'selesai');

        if ($request->has('search') && !empty($request->search)) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->whereHas('inventori', function ($subQuery) use ($search) {
                    $subQuery->where('nama_alat', 'like', "%$search%");
                })
                    ->orWhere('operator_name', 'like', "%$search%")
                    ->orWhere('catatan', 'like', "%$search%");
            });
        }

        if ($request->has('bulan') && !empty($request->bulan)) {
            $query->whereMonth('tanggal_mulai', $request->bulan);
        }

        if ($request->has('tahun') && !empty($request->tahun)) {
            $query->whereYear('tanggal_mulai', $request->tahun);
        }

        $perawatan = $query->orderBy('tanggal_mulai', 'desc')->get();

        $totalPerawatan = $perawatan->count();

        return view('pages.perawatan.historiperawatan', compact('perawatan', 'totalPerawatan'));
    }

    public function exportPdf(Request $request)
    {
        $query = Perawatan::where('status_perawatan', 'selesai');

        if ($request->has('bulan') && !empty($request->bulan)) {
            $query->whereMonth('tanggal_selesai', $request->bulan);
        }

        if ($request->has('tahun') && !empty($request->tahun)) {
            $query->whereYear('tanggal_selesai', $request->tahun);
        }

        $perawatan = $query->orderBy('tanggal_selesai', 'desc')->get();
        $totalPerawatan = $perawatan->count();

        $pdf = Pdf::loadView('pages.perawatan.historiperawatan-pdf', compact('perawatan', 'totalPerawatan'))
            ->setPaper('A4', 'portrait');

        $bulan = $request->bulan ? DateTime::createFromFormat('!m', $request->bulan)->format('F') : 'All Months';
        $tahun = $request->tahun ?: date('Y');
        $fileName = "Histori_Perawatan_{$bulan}_{$tahun}.pdf";

        return $pdf->download($fileName);
    }

    public function create()
    {
        $inventori = Inventory::where('status', 'tersedia')->get();

        return view('pages.perawatan.create', compact('inventori'));
    }

    public function store(Request $request)
    {
        // Validasi: biarkan Laravel otomatis redirect back with errors jika gagal
        $validateData = $request->validate([
            'inventori_id' => 'required|exists:inventori,id',
            'tanggal_mulai' => 'required|date',
            'tanggal_selesai' => 'nullable|date|after_or_equal:tanggal_mulai',
            'status_perawatan' => 'required|in:pending,proses,selesai',
            'operator_name' => 'nullable|string|max:255',
            'catatan' => 'nullable|string',
        ]);

        try {
            // Simpan data
            $perawatan = Perawatan::create($validateData);

            // Update status alat
            $inventori = Inventory::find($request->inventori_id);
            if ($inventori) {
                $inventori->update(['status' => 'sedang_perawatan']);
            }

            // Redirect dengan pesan sukses
            return back()->with('success', 'Jadwal Perawatan berhasil ditambahkan!');
        } catch (\Exception $e) {
            // Tangkap error dan kirim ke view untuk SweetAlert
            return back()->withInput()->with('error', 'Gagal menyimpan data: ' . $e->getMessage());
        }
    }

    public function edit($id)
    {
        $perawatan = Perawatan::findOrFail($id);
        $inventories = Inventory::all();
        return view('pages.perawatan.edit', compact('perawatan', 'inventories'));
    }

    public function update(Request $request, $id)
    {
        try {
            $request->validate([
                'inventori_id' => 'required|exists:inventori,id',
                'tanggal_mulai' => 'required|date',
                'tanggal_selesai' => 'nullable|date|after_or_equal:tanggal_mulai',
                'status_perawatan' => 'required|in:pending,proses,selesai',
                'operator_name' => 'nullable|string|max:255',
                'catatan' => 'nullable|string',
            ]);

            $perawatan = Perawatan::findOrFail($id);
            $perawatan->update([
                'inventori_id' => $request->inventori_id,
                'tanggal_mulai' => $request->tanggal_mulai,
                'tanggal_selesai' => $request->tanggal_selesai,
                'status_perawatan' => $request->status_perawatan,
                'operator_name' => $request->operator_name,
                'catatan' => $request->catatan,
            ]);

            if ($request->status_perawatan === 'selesai') {
                $inventori = Inventory::find($perawatan->inventori_id);
                if ($inventori) {
                    $inventori->update(['status' => 'tersedia']);
                }
            }

            return back()->with('success', 'Jadwal Perawatan berhasil diperbarui!');
        } catch (ValidationException $e) {
            return back()->withErrors($e->errors())->withInput();
        } catch (\Exception $e) {
            return back()->with('error', 'Gagal memperbarui jadwal perawatan: ' . $e->getMessage())->withInput();
        }
    }




    public function getPerawatanCount()
    {
        $perawatanCount = Perawatan::whereIn('status_perawatan', ['pending', 'proses'])->count();
        return response()->json(['count' => $perawatanCount]);
    }

    public function store1(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'inventori_id' => 'required|exists:inventori,id',
                'tanggal_mulai' => 'required|date',
                'operator_name' => 'nullable|string|max:255',
                'catatan' => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
            }

            $perawatan = Perawatan::create([
                'inventori_id' => $request->inventori_id,
                'tanggal_mulai' => $request->tanggal_mulai,
                'status_perawatan' => 'pending',
                'operator_name' => $request->operator_name,
                'catatan' => $request->catatan,
            ]);

            $inventori = Inventory::find($request->inventori_id);
            if ($inventori) {
                $inventori->update(['status' => 'sedang_perawatan']);
            }

            return response()->json([
                'success' => true,
                'message' => 'Jadwal perawatan berhasil diajukan!',
                'perawatan' => $perawatan
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function getInProgressPerawatan()
    {
        $perawatan = Perawatan::where('status_perawatan', 'proses')
            ->orderBy('tanggal_mulai', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'perawatan' => $perawatan
        ], 200);
    }

    public function getPendingOrders()
    {
        $orders = Perawatan::whereIn('status_perawatan', ['pending', 'proses'])->get();

        return response()->json([
            'success' => true,
            'orders' => $orders
        ], 200);
    }

    public function updatePerawatan(Request $request, $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'status_perawatan' => 'required|in:pending,proses',
                'operator_name' => 'nullable|string|max:255',
                'catatan' => 'nullable|string',
            ]);

            if ($validator->fails()) {
                return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
            }

            $perawatan = Perawatan::find($id);
            if (!$perawatan) {
                return response()->json(['success' => false, 'message' => 'Data perawatan tidak ditemukan'], 404);
            }

            $perawatan->update([
                'status_perawatan' => $request->status_perawatan,
                'operator_name' => $request->operator_name,
                'catatan' => $request->catatan,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Data perawatan berhasil diperbarui',
                'perawatan' => $perawatan
            ], 200);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    public function countPerawatan()
    {
        $jumlahPerawatan = Perawatan::whereIn('status_perawatan', ['pending', 'proses'])
            ->count();

        return response()->json(['perawatan' => $jumlahPerawatan]);
    }
    public function getPerawatanProsesSelesai()
    {
        $perawatan = Perawatan::where('status_perawatan', 'selesai')
            ->orderBy('id', 'desc')
            ->get();

        return response()->json(['perawatan' => $perawatan]);
    }
}
