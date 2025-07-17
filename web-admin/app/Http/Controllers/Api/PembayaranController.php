<?php

namespace App\Http\Controllers\api;

use App\Events\NotificationCreated;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Pembayaran;
use App\Models\DetailPembayaran;
use App\Models\Notification;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class PembayaranController extends Controller
{
    public function getPembayaran($orderId)
    {
        $pembayaran = Pembayaran::with('detailPembayarans')
            ->where('id_order', $orderId)
            ->first();

        if (!$pembayaran) {
            return response()->json([
                'message' => 'Pembayaran tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'pembayaran' => $pembayaran
        ]);
    }

    public function storePembayaran(Request $request)
    {
        $request->validate([
            'id_order' => 'required|exists:orders,id',
            'tagihan' => 'required|numeric|min:1',
        ]);

        $existing = Pembayaran::where('id_order', $request->id_order)->first();
        if ($existing) {
            return response()->json([
                'message' => 'Pembayaran untuk order ini sudah dibuat.'
            ], 400);
        }

        $pembayaran = Pembayaran::create([
            'id_order' => $request->id_order,
            'tagihan' => $request->tagihan,
        ]);

        return response()->json([
            'message' => 'Pembayaran berhasil disimpan',
            'pembayaran' => $pembayaran
        ]);
    }

    public function storeDetailPembayaran(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id_pembayaran' => 'required|exists:pembayarans,id',
            'jml_dibayar' => 'required|numeric|min:1',
            'bukti' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $pembayaran = Pembayaran::with(['detailPembayarans', 'order.customer'])->find($request->id_pembayaran);

        $totalTagihan = $pembayaran->tagihan;
        $totalDibayar = $pembayaran->detailPembayarans->sum('jml_dibayar');
        $sisa = $totalTagihan - $totalDibayar;

        if ($request->jml_dibayar > $sisa) {
            return response()->json([
                'errors' => ['jml_dibayar' => ['Jumlah dibayar melebihi sisa pembayaran (Rp ' . number_format($sisa, 0, ',', '.') . ')']],
            ], 422);
        }

        $buktiPath = null;
        if ($request->hasFile('bukti')) {
            $buktiPath = $request->file('bukti')->store('bukti_pembayaran', 'public');
        }

        $detail = DetailPembayaran::create([
            'id_pembayaran' => $request->id_pembayaran,
            'jml_dibayar' => $request->jml_dibayar,
            'bukti' => $buktiPath,
        ]);

        // ✅ Kirim notifikasi realtime ke admin
        $orderId = $pembayaran->order->id ?? null;
        $customer = $pembayaran->order->customer->nama ?? 'Pelanggan';

        $notification = Notification::create([
            'title'   => 'Pembayaran Baru',
            'message' => "Pembayaran dari $customer untuk Order SEWA-" . str_pad($orderId, 3, '0', STR_PAD_LEFT) .
                " sebesar Rp " . number_format($request->jml_dibayar, 0, ',', '.'),
            'url'     => null,
        ]);

        event(new NotificationCreated($notification));

        return response()->json([
            'message' => 'Detail pembayaran berhasil ditambahkan',
            'detail' => $detail,
        ]);
    }
}
