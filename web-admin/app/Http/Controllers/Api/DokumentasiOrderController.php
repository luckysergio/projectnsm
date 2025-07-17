<?php

namespace App\Http\Controllers\api;

use App\Events\DokumentasiCreated;
use App\Events\NotificationCreated;
use App\Http\Controllers\Controller;
use App\Models\DokumentasiOrder;
use App\Models\Notification;
use Illuminate\Http\Request;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;

class DokumentasiOrderController extends Controller
{
        public function store(Request $request)
    {
        $request->validate([
            'order_id' => 'required|exists:orders,id',
            'note' => 'required|string',
            'photo' => 'required|array',
            'photo.*' => 'image|max:2048',
        ]);

        $photoPaths = [];

        foreach ($request->file('photo') as $file) {
            $path = $file->store('dokumentasi', 'public');
            $photoPaths[] = $path;
        }

        $dokumentasi = DokumentasiOrder::create([
            'id_order' => $request->order_id,
            'catatan' => $request->note,
            'foto' => $photoPaths,
        ]);

        $dokumentasi->load('order.customer');

        $order = $dokumentasi->order;
        $customer = $order->customer->nama ?? 'Pelanggan';

        $notification = Notification::create([
            'title' => 'Dokumentasi Baru',
            'message' => "Dokumentasi untuk Order SEWA-" . str_pad($order->id, 3, '0', STR_PAD_LEFT) . " oleh $customer telah ditambahkan.",
            'url' => route('dokumentasi.index'),
        ]);

        event(new NotificationCreated($notification));
        event(new DokumentasiCreated($dokumentasi));

        return response()->json([
            'status' => 'success',
            'message' => 'Dokumentasi berhasil disimpan',
            'data' => $dokumentasi,
        ], 201);
    }

    public function getDokumentasiBySales()
    {
        $user = JWTAuth::parseToken()->authenticate();
        $salesId = $user->karyawan->id ?? null;

        if (!$salesId) {
            return response()->json([
                'message' => 'User bukan sales atau tidak memiliki ID karyawan.'
            ], 403);
        }

        $data = DokumentasiOrder::whereHas('order', function ($query) use ($salesId) {
            $query->where('id_sales', $salesId);
        })
            ->with('order.customer')
            ->latest()
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $data->map(function ($item) {
                return [
                    'id' => $item->id,
                    'order_id' => $item->id_order,
                    'nama_pemesan' => $item->order->customer->nama ?? '-',
                    'note' => $item->catatan,
                    'photo' => is_array($item->foto)
                        ? array_map(fn($path) => asset('storage/' . $path), $item->foto)
                        : [],
                    'created_at' => $item->created_at->format('Y-m-d H:i:s'),
                    'order' => [
                        'id' => $item->order->id ?? null,
                        'customer' => [
                            'id' => $item->order->customer->id ?? null,
                            'nama' => $item->order->customer->nama ?? '-',
                            'instansi' => $item->order->customer->instansi ?? null,
                        ],
                    ],
                ];
            }),
        ]);
    }
}
