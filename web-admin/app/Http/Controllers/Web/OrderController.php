<?php

namespace App\Http\Controllers\Web;

use App\Events\OrderCountUpdated;
use App\Http\Controllers\Controller;
use App\Models\Inventory;
use App\Models\Karyawan;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\DetailOrder;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function index()
    {
        $orders = Order::with([
            'detailOrders' => function ($q) {
                $q->where('status', 'pending')->with('alat');
            },
            'customer',
            'sales',
            'pembayaran.detailPembayarans'
        ])
            ->whereHas('detailOrders', function ($q) {
                $q->where('status', 'pending');
            })
            ->latest()
            ->paginate(6);

        return view('pages.order.index', compact('orders'));
    }

    public function editorder($id)
    {
        $order = Order::with('detailOrders')->findOrFail($id);
        $inventories = Inventory::all();
        $operators = Karyawan::all();

        return view('pages.order.edit', compact('order', 'inventories', 'operators'));
    }

    public function prosesorder(Request $request, $id)
    {
        $request->validate([
            'detail' => 'required|array',
            'detail.*.id_detail' => 'required|exists:detail_orders,id',
            'detail.*.id_alat' => 'required|exists:inventories,id',
            'detail.*.alamat' => 'required|string',
            'detail.*.tgl_mulai' => 'required|date',
            'detail.*.jam_mulai' => 'required',
            'detail.*.harga_sewa' => 'required|numeric',
            'detail.*.total_sewa' => 'required|integer',
            'detail.*.catatan' => 'nullable|string',
            'detail.*.status' => 'required|string|in:proses,persiapan,dikirim,selesai',
        ]);

        DB::beginTransaction();

        try {
            $order = Order::findOrFail($id);
            $totalTagihan = 0;

            foreach ($request->detail as $detailData) {
                $detail = DetailOrder::findOrFail($detailData['id_detail']);

                $hargaSewa = (int) str_replace('.', '', $detailData['harga_sewa']);

                $hargaSewa = (int) $detailData['harga_sewa'];
                $totalSewa = (int) $detailData['total_sewa'];

                $totalTagihan += $hargaSewa;

                $detail->update([
                    'id_alat' => $detailData['id_alat'],
                    'status' => $detailData['status'],
                    'alamat' => $detailData['alamat'],
                    'tgl_mulai' => $detailData['tgl_mulai'],
                    'jam_mulai' => $detailData['jam_mulai'],
                    'tgl_selesai' => $detailData['tgl_selesai'] ?? null,
                    'jam_selesai' => $detailData['jam_selesai'] ?? null,
                    'harga_sewa' => $hargaSewa,
                    'total_sewa' => $totalSewa,
                    'catatan' => $detailData['catatan'],
                ]);
            }

            $order->pembayaran()->updateOrCreate(
                ['id_order' => $order->id],
                ['tagihan' => $totalTagihan]
            );

            $totalPending = DetailOrder::where('status', 'pending')->count();
            $totalPengiriman = DetailOrder::whereIn('status', ['proses', 'persiapan', 'dikirim'])->count();
            event(new OrderCountUpdated($totalPending, $totalPengiriman));

            DB::commit();
            return redirect()->back()->with('success', 'Detail order dan tagihan berhasil diperbarui');
        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->withErrors(['error' => 'Terjadi kesalahan: ' . $e->getMessage()]);
        }
    }

    public function pengiriman()
    {
        $orders = Order::with([
            'detailOrders' => function ($q) {
                $q->whereIn('status', ['proses', 'persiapan', 'dikirim'])->with('alat');
            },
            'customer',
            'sales',
            'pembayaran.detailPembayarans'
        ])
            ->whereHas('detailOrders', function ($q) {
                $q->whereIn('status', ['proses', 'persiapan', 'dikirim']);
            })
            ->latest()
            ->paginate(6);

        return view('pages.pengiriman.index', compact('orders'));
    }

    public function editpengiriman($id)
    {
        $order = Order::with('detailOrders')->findOrFail($id);
        $inventories = Inventory::all();
        $operators = Karyawan::all();

        return view('pages.pengiriman.edit', compact('order', 'inventories', 'operators'));
    }

    public function prosespengiriman(Request $request, $id)
    {
        $request->validate([
            'detail' => 'required|array',
            'detail.*.id_detail' => 'required|exists:detail_orders,id',
            'detail.*.id_alat' => 'required|exists:inventories,id',
            'detail.*.alamat' => 'required|string',
            'detail.*.tgl_mulai' => 'required|date',
            'detail.*.jam_mulai' => 'required',
            'detail.*.harga_sewa' => 'required|numeric',
            'detail.*.total_sewa' => 'required|integer',
            'detail.*.catatan' => 'nullable|string',
            'detail.*.status' => 'required|string|in:proses,persiapan,dikirim,selesai',
        ]);

        DB::beginTransaction();

        try {
            $order = Order::findOrFail($id);
            $totalTagihan = 0;

            foreach ($request->detail as $detailData) {
                $detail = DetailOrder::findOrFail($detailData['id_detail']);
                $prevStatus = $detail->status;

                $hargaSewa = (int) $detailData['harga_sewa'];
                $totalSewa = (int) $detailData['total_sewa'];
                $totalTagihan += $hargaSewa;

                // Update detail order
                $detail->update([
                    'id_alat' => $detailData['id_alat'],
                    'status' => $detailData['status'],
                    'alamat' => $detailData['alamat'],
                    'tgl_mulai' => $detailData['tgl_mulai'],
                    'jam_mulai' => $detailData['jam_mulai'],
                    'tgl_selesai' => $detailData['tgl_selesai'] ?? null,
                    'jam_selesai' => $detailData['jam_selesai'] ?? null,
                    'harga_sewa' => $hargaSewa,
                    'total_sewa' => $totalSewa,
                    'catatan' => $detailData['catatan'],
                ]);

                $inventory = Inventory::findOrFail($detailData['id_alat']);

                if (in_array($detailData['status'], ['persiapan', 'dikirim', 'proses'])) {
                    $inventory->update(['status' => 'disewa']);
                } elseif ($detailData['status'] === 'selesai') {
                    if ($prevStatus !== 'selesai') {
                        $inventory->update([
                            'status' => 'tersedia',
                            'pemakaian' => $inventory->pemakaian + $totalSewa
                        ]);
                    } else {
                        $inventory->update(['status' => 'tersedia']);
                    }
                }
            }

            $order->pembayaran()->updateOrCreate(
                ['id_order' => $order->id],
                ['tagihan' => $totalTagihan]
            );

            $totalPending = DetailOrder::where('status', 'pending')->count();
            $totalPengiriman = DetailOrder::whereIn('status', ['proses', 'persiapan', 'dikirim'])->count();
            event(new OrderCountUpdated($totalPending, $totalPengiriman));

            DB::commit();
            return redirect()->back()->with('success', 'Detail order dan tagihan berhasil diperbarui');
        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->withErrors(['error' => 'Terjadi kesalahan: ' . $e->getMessage()]);
        }
    }

    public function destroy($id)
    {
        $order = Order::with('detailOrders')->findOrFail($id);

        DB::beginTransaction();
        try {
            foreach ($order->detailOrders as $detail) {
                $detail->delete();
            }

            $order->delete();

            DB::commit();

            $totalPending = DetailOrder::where('status', 'pending')->count();
            $totalPengiriman = DetailOrder::whereIn('status', ['proses', 'persiapan', 'dikirim'])->count();

            // Tidak perlu orderData saat delete
            event(new OrderCountUpdated($totalPending, $totalPengiriman));

            return redirect()->back()->with('success', 'Order berhasil dihapus');
        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->with('error', 'Terjadi kesalahan saat menghapus order: ' . $e->getMessage());
        }
    }

    public function selesai(Request $request)
    {
        $query = Order::with([
            'detailOrders' => function ($q) {
                $q->where('status', 'selesai')->with('alat');
            },
            'customer',
            'sales',
            'pembayaran.detailPembayarans'
        ])->whereHas('detailOrders', function ($q) {
            $q->where('status', 'selesai');
        });

        if ($request->filled('bulan') || $request->filled('tahun')) {
            $query->whereHas('detailOrders', function ($q) use ($request) {
                $q->where('status', 'selesai');

                if ($request->filled('bulan')) {
                    $q->whereMonth('tgl_selesai', $request->bulan);
                }

                if ($request->filled('tahun')) {
                    $q->whereYear('tgl_selesai', $request->tahun);
                }
            });
        }

        $orders = $query->latest()->paginate(6);

        $totalPendapatan = $orders->sum(function ($order) {
            return $order->pembayaran->tagihan ?? 0;
        });

        return view('pages.order.selesai', compact('orders', 'totalPendapatan'));
    }

    public function exportSelesai(Request $request)
    {
        $query = Order::with([
            'detailOrders' => fn($q) => $q->where('status', 'selesai')->with('alat'),
            'customer',
            'sales',
            'pembayaran.detailPembayarans'
        ])
            ->whereHas('detailOrders', fn($q) => $q->where('status', 'selesai'));

        if ($request->filled('bulan')) {
            $query->whereMonth('created_at', $request->bulan);
        }

        if ($request->filled('tahun')) {
            $query->whereYear('created_at', $request->tahun);
        }

        $orders = $query->latest()->get();
        $totalPendapatan = $orders->sum(fn($order) => $order->pembayaran->tagihan ?? 0);

        $pdf = Pdf::loadView('pdf.order_selesai', compact('orders', 'totalPendapatan'));
        return $pdf->stream('laporan-order-selesai.pdf');
    }
}
