<?php

namespace App\Http\Controllers\Web;

use App\Events\PerawatanCountUpdated;
use App\Http\Controllers\Controller;
use App\Models\Perawatan;
use App\Models\DetailPerawatan;
use App\Models\Karyawan;
use App\Models\Inventory;
use App\Models\Role;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;

class PerawatanController extends Controller
{
    public function index()
    {
        $perawatans = Perawatan::whereHas('detailPerawatans', function ($q) {
            $q->whereIn('status', ['pending', 'proses']);
        })
            ->with(['operator', 'detailPerawatans' => function ($q) {
                $q->whereIn('status', ['pending', 'proses']);
            }, 'detailPerawatans.alat'])
            ->latest()
            ->paginate(10);

        return view('pages.perawatan.index', compact('perawatans'));
    }

    public function selesai(Request $request)
    {
        $query = Perawatan::whereDoesntHave('detailPerawatans', function ($q) {
            $q->whereIn('status', ['pending', 'proses']);
        })
            ->whereHas('detailPerawatans', function ($q) use ($request) {
                $q->where('status', 'selesai');

                if ($request->filled('bulan') && $request->filled('tahun')) {
                    $q->whereMonth('tgl_selesai', $request->bulan)
                        ->whereYear('tgl_selesai', $request->tahun);
                }
            })
            ->with([
                'operator',
                'detailPerawatans' => function ($q) use ($request) {
                    $q->where('status', 'selesai');

                    if ($request->filled('bulan') && $request->filled('tahun')) {
                        $q->whereMonth('tgl_selesai', $request->bulan)
                            ->whereYear('tgl_selesai', $request->tahun);
                    }
                },
                'detailPerawatans.alat',
            ]);

        $perawatans = $query->latest()->paginate(9);

        return view('pages.perawatan.selesai', compact('perawatans'));
    }

    public function exportSelesai(Request $request)
    {
        $query = Perawatan::whereDoesntHave('detailPerawatans', function ($q) {
            $q->whereIn('status', ['pending', 'proses']);
        })
            ->whereHas('detailPerawatans', function ($q) use ($request) {
                $q->where('status', 'selesai');

                if ($request->filled('bulan') && $request->filled('tahun')) {
                    $q->whereMonth('tgl_selesai', $request->bulan)
                        ->whereYear('tgl_selesai', $request->tahun);
                }
            })
            ->with([
                'operator',
                'detailPerawatans' => function ($q) {
                    $q->where('status', 'selesai');
                },
                'detailPerawatans.alat',
            ]);

        $perawatans = $query->latest()->get();

        $pdf = Pdf::loadView('pdf.perawatan-selesai', compact('perawatans'));
        return $pdf->stream('perawatan-selesai.pdf');
    }

    public function create()
    {
        $operatorRoleId = Role::where('jabatan', 'Operator Maintenance')->value('id');

        $operators = Karyawan::where('role_id', $operatorRoleId)->get();

        $alatList = Inventory::where('status', 'tersedia')->get();

        return view('pages.perawatan.create', compact('operators', 'alatList'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'id_operator' => 'required|exists:karyawans,id',
            'details' => 'required|array|min:1',
            'details.*.id_alat' => 'required|exists:inventories,id',
            'details.*.tgl_mulai' => 'required|date',
            'details.*.status' => 'required|in:pending,proses,selesai',
            'details.*.catatan' => 'nullable|string',
        ]);

        $perawatan = Perawatan::create([
            'id_operator' => $request->id_operator
        ]);

        foreach ($request->details as $item) {
            DetailPerawatan::create([
                'id_perawatan' => $perawatan->id,
                'id_alat' => $item['id_alat'],
                'tgl_mulai' => $item['tgl_mulai'],
                'tgl_selesai' => $item['tgl_selesai'] ?? null,
                'status' => $item['status'],
                'catatan' => $item['catatan'] ?? null,
            ]);

            Inventory::where('id', $item['id_alat'])->update(['status' => 'perawatan']);
        }

        $perawatan->load(['operator', 'detailPerawatans.alat']);
        $totalPerawatan = DetailPerawatan::whereIn('status', ['pending', 'proses'])->count();

        $firstDetail = $perawatan->detailPerawatans->first();
        $perawatanData = [
            'id' => $perawatan->id,
            'operator' => $perawatan->operator->nama ?? '-',
            'alat' => $firstDetail->alat->nama ?? '-',
            'tanggal_mulai' => $firstDetail->tgl_mulai ?? '-',
            'tanggal_selesai' => $firstDetail->tgl_selesai ?? '-',
            'status' => $firstDetail->status ?? '-',
        ];

        event(new PerawatanCountUpdated($totalPerawatan, $perawatanData));

        return back()->with('success', 'Data perawatan berhasil ditambahkan.');
    }

    public function edit($id)
    {
        $perawatan = Perawatan::with('detailPerawatans')->findOrFail($id);

        $operatorRoleId = Role::where('jabatan', 'Operator Maintenance')->value('id');
        $operators = Karyawan::where('role_id', $operatorRoleId)->get();

        $alatList = Inventory::where('status', 'tersedia')
            ->orWhereIn('id', $perawatan->detailPerawatans->pluck('id_alat'))
            ->get();

        return view('pages.perawatan.edit', compact('perawatan', 'operators', 'alatList'));
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'id_operator' => 'required|exists:karyawans,id',
            'details' => 'required|array',
            'details.*.id_alat' => 'required|exists:inventories,id',
            'details.*.tgl_mulai' => 'required|date',
            'details.*.tgl_selesai' => 'nullable|date',
            'details.*.status' => 'required|in:pending,proses,selesai',
            'details.*.catatan' => 'nullable|string',
        ]);

        $perawatan = Perawatan::findOrFail($id);
        $perawatan->update([
            'id_operator' => $request->id_operator
        ]);

        foreach ($perawatan->detailPerawatans as $detail) {
            Inventory::where('id', $detail->id_alat)->update(['status' => 'tersedia']);
            $detail->delete();
        }

        foreach ($request->details as $item) {
            DetailPerawatan::create([
                'id_perawatan' => $perawatan->id,
                'id_alat' => $item['id_alat'],
                'tgl_mulai' => $item['tgl_mulai'],
                'tgl_selesai' => $item['tgl_selesai'] ?? null,
                'status' => $item['status'],
                'catatan' => $item['catatan'] ?? null,
            ]);

            $newStatus = $item['status'] === 'selesai' ? 'tersedia' : 'perawatan';
            Inventory::where('id', $item['id_alat'])->update(['status' => $newStatus]);
        }

        return back()->with('success', 'Data perawatan berhasil diperbarui.');
    }

    public function destroy($id)
    {
        $perawatan = Perawatan::with('detailPerawatans')->findOrFail($id);

        foreach ($perawatan->detailPerawatans as $detail) {
            Inventory::where('id', $detail->id_alat)->update(['status' => 'tersedia']);
            $detail->delete();
        }

        $perawatan->delete();

        return back()->with('success', 'Data perawatan berhasil dihapus.');
    }
}
