<?php

namespace App\Http\Controllers;

use App\Models\Inventory;
use App\Models\Order;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Barryvdh\DomPDF\Facade\Pdf;

class OrderController extends Controller
{

    public function index1()
    {
        $order = Order::where('status_order', 'belum diproses')
            ->orderBy('created_at', 'asc')
            ->get();

        return view(
            'pages.transaksi.order',
            ['order' => $order]
        );
    }

    public function getOrderCount()
    {
        $orderCount = Order::where('status_order', 'belum diproses')->count();
        return response()->json(['count' => $orderCount]);
    }

    public function getPengirimanCount()
    {
        $count = Order::whereIn('status_order', ['diproses', 'persiapan', 'dikirim'])->count();
        return response()->json(['count' => $count]);
    }

    public function index2()
    {
        $order = Order::whereIn('status_order', ['diproses', 'persiapan', 'dikirim'])
            ->orderBy('created_at', 'asc')
            ->get();

        return view(
            'pages.transaksi.pengiriman',
            ['order' => $order]
        );
    }

    public function index3(Request $request)
    {
        $query = Order::where('status_order', 'selesai');

        if ($request->has('search') && !empty($request->search)) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('nama_pemesan', 'like', "%$search%")
                    ->orWhere('alamat_pemesan', 'like', "%$search%")
                    ->orWhere('status_pembayaran', 'like', "%$search%")
                    ->orWhere('status_order', 'like', "%$search%");
            });
        }

        if ($request->has('bulan') && !empty($request->bulan)) {
            $query->whereMonth('tgl_pemakaian', $request->bulan);
        }

        if ($request->has('tahun') && !empty($request->tahun)) {
            $query->whereYear('tgl_pemakaian', $request->tahun);
        }

        $order = $query->orderBy('created_at', 'desc')->get();

        $totalOrder = $order->count();
        $totalHarga = $order->sum('total_harga');

        return view('pages.transaksi.histori', compact('order', 'totalOrder', 'totalHarga'));
    }

    public function exportPdf(Request $request)
    {
        $query = Order::where('status_order', 'selesai');

        if ($request->has('bulan') && !empty($request->bulan)) {
            $query->whereMonth('tgl_pemakaian', $request->bulan);
        }

        if ($request->has('tahun') && !empty($request->tahun)) {
            $query->whereYear('tgl_pemakaian', $request->tahun);
        }

        $orders = $query->orderBy('created_at', 'desc')->get();
        $totalOrder = $orders->count();
        $totalHarga = $orders->sum('total_harga');

        $bulan = $request->bulan ? \DateTime::createFromFormat('!m', $request->bulan)->format('F') : 'All_Months';
        $tahun = $request->tahun ?: date('Y');
        $fileName = "Laporan_Histori_Order_{$bulan}_{$tahun}.pdf";

        $pdf = Pdf::loadView('pages.transaksi.histori-pdf', compact('orders', 'totalOrder', 'totalHarga'))
            ->setPaper('A4', 'portrait');

        return $pdf->download($fileName);
    }

    public function prosesorder($id)
    {
        $order = Order::findOrFail($id);
        return view('pages.transaksi.prosesorder', ['order' => $order]);
    }

    public function jadwal($id)
    {
        $order = Order::findOrFail($id);
        return view('pages.transaksi.jadwal', ['order' => $order]);
    }

    public function update1(Request $request, $id)
    {
        try {
            $validated = $request->validate([
                'status_order' => 'nullable|string|in:belum diproses,diproses,dikirim,selesai',
                'tgl_pemakaian' => 'nullable|date',
                'catatan' => 'nullable|string',
                'jam_mulai' => 'nullable|date_format:H:i',
                'jam_selesai' => 'nullable|date_format:H:i',
            ]);


            $order = Order::findOrFail($id);


            $order->update([
                'tgl_pemakaian' => $request->filled('tgl_pemakaian') ? $request->tgl_pemakaian : $order->tgl_pemakaian,
                'status_order' => $request->filled('status_order') ? $request->status_order : $order->status_order,
                'catatan' => $request->filled('catatan') ? $request->catatan : $order->catatan,
                'jam_mulai' => $request->filled('jam_mulai') ? $request->jam_mulai : $order->jam_mulai,
                'jam_selesai' => $request->filled('jam_selesai') ? $request->jam_selesai : $order->jam_selesai,
            ]);

            // if ($request->status_order == 'diproses') {
            //     $inventori = Inventory::find($order->inventori_id);
            //     if ($inventori) {
            //         $inventori->update([
            //             'status' => 'sedang_disewa',
            //         ]);
            //     }
            // }

            return back()->with('success', 'Data order berhasil diperbarui');
        } catch (ValidationException $e) {
            return back()->withErrors($e->errors())->withInput();
        } catch (\Exception $e) {
            return back()->with('error', 'Terjadi kesalahan saat update order: ' . $e->getMessage());
        }
    }


    public function update2(Request $request, $id)
    {
        try {
            $validated = $request->validate([
                'status_order' => 'nullable|string|in:belum diproses,diproses,dikirim,selesai',
                'status_pembayaran' => 'nullable|string|in:belum dibayar,dp,lunas',
                'tgl_pemakaian' => 'nullable|date',
                'jam_mulai' => 'nullable|date_format:H:i',
                'jam_selesai' => 'nullable|date_format:H:i',
                'overtime' => 'nullable|int',
                'denda' => 'nullable|decimal:0,2',
                'catatan' => 'nullable|string',
            ]);


            $order = Order::findOrFail($id);


            $total_harga = $order->harga_sewa + ($request->denda ?? 0);


            $order->status_order = $request->status_order;
            $order->status_pembayaran = $request->status_pembayaran;
            $order->tgl_pemakaian = $request->tgl_pemakaian;
            $order->jam_mulai = $request->jam_mulai;
            $order->jam_selesai = $request->jam_selesai;
            $order->catatan = $request->catatan;
            $order->overtime = $request->overtime;
            $order->denda = $request->denda;
            $order->total_harga = $total_harga;
            $order->save();


            if ($request->status_order == 'selesai') {
                $inventori = Inventory::find($order->inventori_id);
                if ($inventori) {
                    $inventori->update([
                        'status' => 'tersedia',
                        'waktu_pemakaian' => $inventori->waktu_pemakaian + $order->total_sewa + $order->overtime
                    ]);
                }
            }

            return back()->with('success', 'Data order berhasil diperbarui');
        } catch (ValidationException $e) {
            return back()->withErrors($e->errors())->withInput();
        } catch (\Exception $e) {
            return back()->with('error', 'Terjadi kesalahan saat update order: ' . $e->getMessage());
        }
    }


    public function destroy1($id)
    {
        $order = Order::findOrFail($id);
        $order->delete();
        return redirect('/order')->with('success', 'Berhasil menolak order');
    }


    public function store(Request $request)
    {
        // ✅ Validasi request
        $validated = $request->validate([
            'nama_pemesan' => 'required|string',
            'alamat_pemesan' => 'required|string',
            'inventori_id' => 'required|exists:inventori,id',
            'tgl_pemakaian' => 'required|date',
            'jam_mulai' => 'required|date_format:H:i',
            'total_sewa' => 'required|integer|min:8',
            'harga_sewa' => 'required|decimal:0,2|min:0',
            'status_pembayaran' => 'required|in:belum dibayar,dp,lunas',
            'catatan' => 'nullable|string',
            'status_order' => 'nullable|string|in:belum diproses,diproses,dikirim,selesai'
        ]);


        $total_harga = $validated['harga_sewa'] + ($request->denda ?? 0);


        $order = Order::create([
            'sales_id' => Auth::id(),
            'nama_pemesan' => $validated['nama_pemesan'],
            'alamat_pemesan' => $validated['alamat_pemesan'],
            'inventori_id' => $validated['inventori_id'],
            'total_sewa' => $validated['total_sewa'],
            'tgl_pemakaian' => $validated['tgl_pemakaian'],
            'jam_mulai' => $validated['jam_mulai'],
            'harga_sewa' => $validated['harga_sewa'],
            'total_harga' => $total_harga,
            'status_pembayaran' => $validated['status_pembayaran'],
            'catatan' => $validated['catatan'] ?? null,
            'status_order' => $validated['status_order'] ?? 'belum diproses'
        ]);

        // // ✅ Update status inventori (misalnya menjadi 'sedang_disewa')
        // $inventori = Inventory::find($validated['inventori_id']);
        // if ($inventori) {
        //     $inventori->update([
        //         'status' => 'sedang_disewa' // Atau status lain yang sesuai
        //     ]);
        // }

        return response()->json([
            'message' => 'Order berhasil dibuat, inventori diperbarui',
            'order' => $order
        ], 201);
    }


    public function updateStatus(Request $request, $id)
    {
        $order = Order::findOrFail($id);

        $validated = $request->validate([
            'status_order' => 'required|in:belum diproses,diproses,dikirim,selesai'
        ]);

        $order->update(['status_order' => $validated['status_order']]);

        if ($validated['status_order'] == 'selesai') {
            $inventori = $order->inventori;
            if ($inventori) {
                $inventori->update([
                    'status' => 'tersedia',
                    'waktu_pemakaian' => $inventori->waktu_pemakaian + $order->total_sewa
                ]);
            }
        }

        return response()->json([
            'message' => 'Status order diperbarui',
            'order' => $order
        ]);
    }



    public function index()
    {
        $orders = Order::all();

        return response()->json($orders);
    }

    public function getPendingOrders()
    {
        $salesId = Auth::id();

        $orders = Order::where('sales_id', $salesId)
            ->whereIn('status_order', ['belum diproses', 'diproses', 'persiapan', 'dikirim'])
            ->get();

        return response()->json([
            'status' => 'success',
            'orders' => $orders
        ], 200);
    }


    public function getCompletedOrders()
    {
        $salesId = Auth::id();


        $orders = Order::where('sales_id', $salesId)
            ->where('status_order', 'selesai')
            ->get();

        return response()->json([
            'status' => 'success',
            'orders' => $orders
        ], 200);
    }

    public function getAllOrders()
    {
        $salesId = Auth::id();

        $orders = Order::where('sales_id', $salesId)->get();

        return response()->json([
            'status' => 'success',
            'orders' => $orders
        ], 200);
    }

    public function show(Order $order)
    {
        return response()->json($order);
    }

    public function getOrders(Request $request)
    {
        $query = Order::whereIn('status_order', ['belum diproses', 'diproses', 'persiapan', 'selesai'])
            ->orderBy('nama_pemesan', 'desc');

        if ($request->has('nama_pemesan')) {
            $query->where('nama_pemesan', 'like', '%' . $request->nama_pemesan . '%');
        }

        $orders = $query->get();

        return response()->json(['orders' => $orders]);
    }


    public function getOrdersJadwalPengiriman()
    {
        $orders = Order::whereIn('status_order', ['diproses', 'persiapan', 'dikirim'])
            ->orderBy('tgl_pemakaian', 'asc')
            ->get();

        return response()->json(['orders' => $orders]);
    }

    public function updateOrderStatus(Request $request, $id)
    {
        $order = Order::find($id);

        if (!$order) {
            return response()->json(['message' => 'Order tidak ditemukan'], 404);
        }

        $validatedData = $request->validate([
            'status_order' => 'required|string|in:diproses,dikirim,persiapan',
            'operator_name' => 'nullable|string|max:255',
        ]);

        $order->status_order = $validatedData['status_order'];
        $order->operator_name = $validatedData['operator_name'];
        $order->save();

        $inventori = Inventory::find($order->inventori_id);
        if ($inventori) {

            switch ($request->status_order) {
                case 'persiapan':
                    $inventori->update(['status' => 'sedang_disewa']);
                    break;

                case 'dikirim':
                    $inventori->update(['status' => 'sedang_disewa']);
                    break;
            }
        }

        return response()->json([
            'message' => 'Status order berhasil diperbarui',
            'order' => $order
        ]);
    }



    public function countOrders()
    {
        $jumlahPengiriman = Order::whereIn('status_order', ['diproses', 'persiapan', 'dikirim'])
            ->count();

        return response()->json(['pengiriman' => $jumlahPengiriman]);
    }

    public function countOrders1()
    {
        $salesId = Auth::id();

        $orderCount = Order::where('sales_id', $salesId)
            ->whereIn('status_order', ['belum diproses', 'diproses', 'persiapan', 'dikirim'])
            ->count();

        return response()->json([
            'status' => 'success',
            'total_orders' => $orderCount
        ], 200);
    }

    public function getStatusChanges()
    {
        $salesId = Auth::id();

        $updatedOrders = Order::where('sales_id', $salesId)
            ->whereIn('status_order', ['diproses', 'dikirim', 'selesai'])
            ->orderBy('updated_at', 'desc')
            ->limit(10)
            ->get(['id', 'nama_pemesan', 'status_order', 'updated_at']);

        return response()->json([
            'status' => 'success',
            'orders' => $updatedOrders
        ], 200);
    }

    public function getOrdersHistori()
    {
        $orders = Order::where('status_order', 'selesai')
            ->orderBy('tgl_pemakaian', 'desc')
            ->get();

        return response()->json(['orders' => $orders]);
    }
}
