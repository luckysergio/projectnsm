<?php

namespace App\Http\Controllers\Api;

use App\Events\NotificationCreated;
use App\Events\PerawatanCountUpdated;
use App\Http\Controllers\Controller;
use App\Models\Karyawan;
use Illuminate\Http\Request;
use App\Models\Perawatan;
use App\Models\DetailPerawatan;
use App\Models\Inventory;
use App\Models\Notification;
use Illuminate\Support\Facades\DB;

class PerawatanController extends Controller
{
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

        DB::beginTransaction();

        try {
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

                Inventory::where('id', $item['id_alat'])->update([
                    'status' => $item['status'] === 'selesai' ? 'tersedia' : 'perawatan',
                ]);
            }

            DB::commit();

            $perawatan->load([
                'operator.user',
                'detailPerawatans.alat'
            ]);

            $totalAktif = Perawatan::whereHas('detailPerawatans', function ($q) {
                $q->whereIn('status', ['pending', 'proses']);
            })->count();

            $perawatanData = [
                'id' => $perawatan->id,
                'operator' => $perawatan->operator->user->nama ?? 'Operator',
                'created_at_human' => $perawatan->created_at->diffForHumans(),
                'detail_perawatans' => $perawatan->detailPerawatans->map(function ($detail) {
                    return [
                        'alat' => $detail->alat->nama ?? '-',
                        'tgl_mulai' => \Carbon\Carbon::parse($detail->tgl_mulai)->format('d-m-Y'),
                        'tgl_selesai' => $detail->tgl_selesai ? \Carbon\Carbon::parse($detail->tgl_selesai)->format('d-m-Y') : '-',
                        'status' => $detail->status,
                        'catatan' => $detail->catatan ?? '-',
                    ];
                }),
            ];

            event(new PerawatanCountUpdated($totalAktif, $perawatanData));

            $notif = Notification::create([
                'title' => 'Perawatan Baru',
                'message' => 'Perawatan baru telah dibuat',
                'url' => route('perawatan.index'),
            ]);
            event(new NotificationCreated($notif));

            return response()->json([
                'message' => 'Perawatan berhasil dibuat',
                'perawatan_id' => $perawatan->id,
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Gagal: ' . $e->getMessage()], 500);
        }
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

        DB::beginTransaction();

        try {
            $perawatan = Perawatan::findOrFail($id);
            $perawatan->update(['id_operator' => $request->id_operator]);

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

                Inventory::where('id', $item['id_alat'])->update([
                    'status' => $item['status'] === 'selesai' ? 'tersedia' : 'perawatan'
                ]);
            }

            DB::commit();

            $perawatan->load([
                'operator.user',
                'detailPerawatans.alat'
            ]);

            $totalAktif = Perawatan::whereHas('detailPerawatans', function ($q) {
                $q->whereIn('status', ['pending', 'proses']);
            })->count();

            $perawatanData = [
                'id' => $perawatan->id,
                'operator' => $perawatan->operator->user->nama ?? 'Operator',
                'created_at_human' => $perawatan->updated_at->diffForHumans(),
                'detail_perawatans' => $perawatan->detailPerawatans->map(function ($d) {
                    return [
                        'alat' => $d->alat->nama ?? '-',
                        'tgl_mulai' => \Carbon\Carbon::parse($d->tgl_mulai)->format('d-m-Y'),
                        'tgl_selesai' => $d->tgl_selesai ? \Carbon\Carbon::parse($d->tgl_selesai)->format('d-m-Y') : null,
                        'status' => $d->status,
                        'catatan' => $d->catatan,
                    ];
                })->toArray(),
            ];

            event(new PerawatanCountUpdated($totalAktif, $perawatanData));

            $notif = Notification::create([
                'title' => 'Perawatan Diperbarui',
                'message' => 'Data perawatan telah diperbarui',
                'url' => route('perawatan.index'),
            ]);
            event(new NotificationCreated($notif));

            return response()->json(['message' => 'Perawatan berhasil diperbarui']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Gagal: ' . $e->getMessage()], 500);
        }
    }

    public function getOperators()
    {
        $operators = Karyawan::whereHas('role', function ($query) {
            $query->where('jabatan', 'Operator Maintenance');
        })->select('id', 'nama')->get();

        return response()->json(['operators' => $operators]);
    }

    public function count()
    {
        $countAktif = DetailPerawatan::whereIn('status', ['pending', 'proses'])->count();
        $countSelesai = DetailPerawatan::where('status', 'selesai')->count();

        return response()->json([
            'aktif' => $countAktif,
            'selesai' => $countSelesai,
        ]);
    }

    public function all()
    {
        $perawatans = Perawatan::with(['operator', 'detailPerawatans.alat'])
            ->orderByDesc('created_at')
            ->get();

        $formatted = $perawatans->map(function ($item) {
            return [
                'id' => $item->id,
                'operator_name' => $item->operator->nama ?? '-',
                'status_perawatan' => $item->status,
                'detail_perawatans' => $item->detailPerawatans->map(function ($detail) {
                    return [
                        'inventori_name' => $detail->alat->nama ?? '-',
                        'tanggal_mulai' => $detail->tgl_mulai ?? '-',
                        'catatan' => $detail->catatan ?? '-',
                    ];
                }),
            ];
        });

        return response()->json([
            'perawatans' => $perawatans,
            'count' => $perawatans->count(),
        ]);
    }

    public function getActivePerawatanPublic()
    {
        $statuses = ['pending', 'proses'];

        $perawatans = Perawatan::with([
            'operator',
            'detailPerawatans' => function ($query) use ($statuses) {
                $query->whereIn('status', $statuses)
                    ->with('alat');
            },
        ])
            ->whereHas('detailPerawatans', function ($query) use ($statuses) {
                $query->whereIn('status', $statuses);
            })
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'perawatans' => $perawatans,
            'count' => $perawatans->count(),
        ]);
    }

    public function getActivePerawatanByOperator($id_operator)
    {
        $statuses = ['pending', 'proses'];

        $perawatans = Perawatan::with([
            'operator',
            'detailPerawatans' => function ($query) use ($statuses) {
                $query->whereIn('status', $statuses)
                    ->with('alat');
            },
        ])
            ->where('id_operator', $id_operator)
            ->whereHas('detailPerawatans', function ($query) use ($statuses) {
                $query->whereIn('status', $statuses);
            })
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'perawatans' => $perawatans,
            'count' => $perawatans->count(),
        ]);
    }

    public function getSelesai()
    {
        $perawatans = Perawatan::with([
            'operator',
            'detailPerawatans.alat'
        ])
            ->whereHas('detailPerawatans', function ($query) {
                $query->where('status', 'selesai');
            })
            ->orderByDesc('created_at')
            ->get();

        $formatted = $perawatans->map(function ($item) {
            return [
                'id' => $item->id,
                'operator_name' => $item->operator->nama ?? '-',
                'status_perawatan' => $item->status,
                'detail_perawatans' => $item->detailPerawatans->map(function ($detail) {
                    return [
                        'inventori_name' => $detail->alat->nama ?? '-',
                        'tanggal_mulai' => $detail->tgl_mulai ?? '-',
                        'catatan' => $detail->catatan ?? '-',
                    ];
                }),
            ];
        });

        return response()->json([
            'perawatans' => $perawatans,
            'count' => $perawatans->count(),
        ]);
    }
}
