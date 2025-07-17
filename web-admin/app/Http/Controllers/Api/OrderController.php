<?php

namespace App\Http\Controllers\Api;

use App\Events\NotificationCreated;
use App\Events\OrderCountUpdated;
use App\Events\OrderCreated;
use App\Events\PengirimanUpdated;
use App\Http\Controllers\Controller;
use App\Models\Karyawan;
use App\Models\Pembayaran;
use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\DetailOrder;
use App\Models\Customer;
use App\Models\Inventory;
use App\Models\Notification;
use Illuminate\Support\Facades\DB;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;
use Illuminate\Support\Facades\Validator;
use OrderUpdated;

class OrderController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'customer_id' => 'nullable|integer|exists:customers,id',
            'customer_baru.nama' => 'required_without:customer_id|string|max:50',
            'customer_baru.instansi' => 'nullable|string|max:50',
            'details' => 'required|array|min:1',
            'details.*.id_alat' => 'required|integer|exists:inventories,id',
            'details.*.alamat' => 'required|string',
            'details.*.tgl_mulai' => 'required|date',
            'details.*.jam_mulai' => 'required',
            'details.*.tgl_selesai' => 'nullable|date',
            'details.*.jam_selesai' => 'nullable',
            'details.*.total_sewa' => 'required|integer',
            'details.*.catatan' => 'nullable|string',
        ]);

        DB::beginTransaction();

        try {
            $user = JWTAuth::parseToken()->authenticate();
            $karyawan = $user->karyawan;

            $customer = Customer::find($request->customer_id);
            if (!$customer) {
                $customer = Customer::create([
                    'nama' => $request->input('customer_baru.nama'),
                    'instansi' => $request->input('customer_baru.instansi'),
                ]);
            }

            $order = Order::create([
                'id_sales' => $karyawan->id,
                'id_pemesan' => $customer->id,
            ]);

            $total_tagihan = 0;

            foreach ($request->details as $detail) {
                $alat = Inventory::findOrFail($detail['id_alat']);
                $harga_sewa = $detail['total_sewa'] * $alat->harga;

                DetailOrder::create([
                    'id_order'   => $order->id,
                    'id_alat'    => $detail['id_alat'],
                    'alamat'     => $detail['alamat'],
                    'id_operator' => null,
                    'tgl_mulai'  => $detail['tgl_mulai'],
                    'jam_mulai'  => $detail['jam_mulai'],
                    'tgl_selesai' => $detail['tgl_selesai'] ?? null,
                    'jam_selesai' => $detail['jam_selesai'] ?? null,
                    'status'      => 'pending',
                    'catatan'     => $detail['catatan'] ?? '',
                    'harga_sewa'  => $harga_sewa,
                    'total_sewa'  => $detail['total_sewa'],
                ]);

                $total_tagihan += $harga_sewa;
            }

            $pembayaran = Pembayaran::create([
                'id_order' => $order->id,
                'tagihan'  => $total_tagihan,
            ]);

            DB::commit();

            $order->load(['customer', 'sales', 'detailOrders.alat', 'pembayaran.detailPembayarans']);

            $totalPending = DetailOrder::where('status', 'pending')->count();
            $totalPengiriman = DetailOrder::whereIn('status', ['proses', 'persiapan', 'dikirim'])->count();

            $sisaBayar = ($order->pembayaran->tagihan ?? 0) -
                ($order->pembayaran->detailPembayarans->sum('jml_dibayar') ?? 0);

            $orderData = [
                'id' => $order->id,
                'customer' => $order->customer->nama ?? '-',
                'sales' => $order->sales->nama ?? '-',
                'jumlah_item' => $order->detailOrders->count(),
                'tagihan' => $order->pembayaran->tagihan ?? 0,
                'total_bayar' => $order->pembayaran->detailPembayarans->sum('jml_dibayar') ?? 0,
                'sisa_bayar' => $sisaBayar, // dihitung manual di controller
                'bukti_list' => $order->pembayaran->detailPembayarans->pluck('bukti')->filter()->toArray(),
                'created_at_human' => $order->created_at->diffForHumans(),
            ];

            event(new OrderCountUpdated($totalPending, $totalPengiriman, $orderData));

            $notification = Notification::create([
                'title'   => 'Order Baru',
                'message' => 'Order baru telah dibuat dengan ID SEWA-00' . $order->id,
                'url'     => route('order.index')
            ]);
            event(new NotificationCreated($notification));

            return response()->json([
                'message' => 'Order berhasil dibuat',
                'order' => [
                    'id' => $order->id,
                    'created_at' => $order->created_at->diffForHumans(),
                    'customer'   => [
                        'id'   => $order->customer->id,
                        'nama' => $order->customer->nama,
                    ],
                    'sales'      => [
                        'id'   => $order->sales->id,
                        'nama' => $order->sales->nama,
                    ],
                    'detail_orders' => $order->detailOrders->map(function ($detail) {
                        return [
                            'id'           => $detail->id,
                            'id_alat'     => $detail->id_alat,
                            'nama_alat'   => $detail->alat->nama,
                            'status'      => $detail->status,
                            'tgl_mulai'   => $detail->tgl_mulai,
                            'jam_mulai'   => $detail->jam_mulai,
                            'tgl_selesai' => $detail->tgl_selesai,
                            'jam_selesai' => $detail->jam_selesai,
                            'catatan'     => $detail->catatan,
                            'harga_sewa'  => $detail->harga_sewa,
                            'total_sewa'  => $detail->total_sewa,
                        ];
                    }),
                    'pembayaran' => [
                        'id'     => $order->pembayaran->id,
                        'tagihan' => $order->pembayaran->tagihan,
                    ],
                ],
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'error'   => 'Gagal membuat order',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function getCompletedOrders(Request $request)
    {
        $user = JWTAuth::parseToken()->authenticate();
        $salesId = $user->karyawan->id ?? null;

        if (!$salesId) {
            return response()->json([
                'message' => 'User bukan sales atau tidak memiliki ID karyawan.'
            ], 403);
        }

        $orders = Order::with([
            'customer',
            'detailOrders' => function ($query) {
                $query->where('status', 'selesai')->with(['alat', 'operator']);
            },
            'pembayaran.detailPembayarans',
        ])
            ->where('id_sales', $salesId)
            ->whereHas('detailOrders', function ($query) {
                $query->where('status', 'selesai');
            })
            ->orderByDesc('created_at')
            ->get();

        $formattedOrders = $orders->map(function ($order) {
            $pembayaran = $order->pembayaran;

            return [
                'id' => $order->id,
                'nama_pemesan' => $order->customer->nama ?? '-',
                'alamat' => optional($order->detailOrders->first())->alamat,
                'harga_sewa' => optional($order->detailOrders->first())->harga_sewa,
                'total_sewa' => optional($order->detailOrders->first())->total_sewa,
                'tagihan' => optional($pembayaran)->tagihan,
                'detail_orders' => $order->detailOrders->map(function ($detail) {
                    return [
                        'id' => $detail->id,
                        'alat' => optional($detail->alat)->nama ?? '-',
                        'operator' => optional($detail->operator)->nama ?? '-',
                        'alamat' => $detail->alamat,
                        'tgl_mulai' => $detail->tgl_mulai,
                        'tgl_selesai' => $detail->tgl_selesai,
                        'jam_mulai' => $detail->jam_mulai,
                        'jam_selesai' => $detail->jam_selesai,
                        'harga_sewa' => $detail->harga_sewa,
                        'total_sewa' => $detail->total_sewa,
                    ];
                }),
                'detail_pembayarans' => optional($pembayaran)->detailPembayarans->map(function ($detail) {
                    return [
                        'id' => $detail->id,
                        'jml_dibayar' => $detail->jml_dibayar,
                        'bukti_pembayaran' => $detail->bukti
                            ? asset('storage/' . $detail->bukti)
                            : null,
                    ];
                }),
                // Tampilkan tanggal & jam dari detail pertama sebagai ringkasan
                'tgl_mulai' => optional($order->detailOrders->first())->tgl_mulai,
                'tgl_selesai' => optional($order->detailOrders->first())->tgl_selesai,
                'jam_mulai' => optional($order->detailOrders->first())->jam_mulai,
                'jam_selesai' => optional($order->detailOrders->first())->jam_selesai,
                'alat' => optional(optional($order->detailOrders->first())->alat)->nama,
                'operator' => optional(optional($order->detailOrders->first())->operator)->nama,
            ];
        });

        return response()->json([
            'orders' => $formattedOrders,
            'count' => $formattedOrders->count(),
        ]);
    }

    public function getCompletedOrdersPublic()
    {
        $orders = Order::with([
            'customer',
            'sales',
            'detailOrders' => function ($query) {
                $query->where('status', 'selesai')->with(['alat', 'operator']);
            },
            'pembayaran.detailPembayarans',
        ])
            ->whereHas('detailOrders', function ($query) {
                $query->where('status', 'selesai');
            })
            ->orderByDesc('created_at')
            ->get();

        $formattedOrders = $orders->map(function ($order) {
            $pembayaran = $order->pembayaran;
            $firstDetail = optional($order->detailOrders->first());

            return [
                'id' => $order->id,
                'nama_pemesan' => $order->customer->nama ?? '-',
                'nama_sales' => $order->sales->nama ?? '-',
                'alamat' => $firstDetail->alamat ?? '-',
                'harga_sewa' => $firstDetail->harga_sewa ?? 0,
                'total_sewa' => $firstDetail->total_sewa ?? 0,
                'tagihan' => $pembayaran?->tagihan ?? 0,

                'detail_orders' => $order->detailOrders->map(function ($detail) {
                    return [
                        'id' => $detail->id,
                        'alat' => $detail->alat->nama ?? '-',
                        'operator' => $detail->operator->nama ?? '-',
                        'alamat' => $detail->alamat,
                        'tgl_mulai' => $detail->tgl_mulai,
                        'tgl_selesai' => $detail->tgl_selesai,
                        'jam_mulai' => $detail->jam_mulai,
                        'jam_selesai' => $detail->jam_selesai,
                        'harga_sewa' => $detail->harga_sewa,
                        'total_sewa' => $detail->total_sewa,
                    ];
                }),

                'detail_pembayarans' => $pembayaran?->detailPembayarans->map(function ($detail) {
                    return [
                        'id' => $detail->id,
                        'jml_dibayar' => $detail->jml_dibayar,
                        'bukti_pembayaran' => $detail->bukti
                            ? asset('storage/' . $detail->bukti)
                            : null,
                    ];
                }) ?? [],

                'tgl_mulai' => $firstDetail->tgl_mulai,
                'tgl_selesai' => $firstDetail->tgl_selesai,
                'jam_mulai' => $firstDetail->jam_mulai,
                'jam_selesai' => $firstDetail->jam_selesai,
                'alat' => $firstDetail->alat->nama ?? '-',
                'operator' => $firstDetail->operator->nama ?? '-',
            ];
        });

        return response()->json([
            'orders' => $formattedOrders,
            'count' => $formattedOrders->count(),
        ]);
    }

    public function getActiveOrders(Request $request)
    {
        $user = JWTAuth::parseToken()->authenticate();
        $salesId = $user->karyawan->id ?? null;

        if (!$salesId) {
            return response()->json([
                'message' => 'User bukan sales atau tidak memiliki ID karyawan.'
            ], 403);
        }

        $statuses = ['pending', 'proses', 'persiapan', 'dikirim'];

        $orders = Order::with([
            'customer',
            'detailOrders' => function ($query) use ($statuses) {
                $query->whereIn('status', $statuses)
                    ->with(['alat', 'operator']);
            },
            'pembayaran.detailPembayarans',
        ])
            ->where('id_sales', $salesId)
            ->whereHas('detailOrders', function ($query) use ($statuses) {
                $query->whereIn('status', $statuses);
            })
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'orders' => $orders,
            'count' => $orders->count(),
        ]);
    }

    public function getActiveOrdersPublic()
    {
        $statuses = ['pending', 'proses', 'persiapan', 'dikirim'];

        $orders = Order::with([
            'customer',
            'sales',
            'detailOrders' => function ($query) use ($statuses) {
                $query->whereIn('status', $statuses)
                    ->with(['alat', 'operator']);
            },
            'pembayaran.detailPembayarans',
        ])
            ->whereHas('detailOrders', function ($query) use ($statuses) {
                $query->whereIn('status', $statuses);
            })
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'orders' => $orders,
            'count' => $orders->count(),
        ]);
    }

    public function getActiveOrdersByOperator($id_operator)
    {
        $statuses = ['pending', 'proses', 'persiapan', 'dikirim'];

        $orders = Order::with([
            'customer',
            'sales',
            'detailOrders' => function ($query) use ($statuses, $id_operator) {
                $query->whereIn('status', $statuses)
                    ->where('id_operator', $id_operator)
                    ->with(['alat', 'operator']);
            },
            'pembayaran.detailPembayarans',
        ])
            ->whereHas('detailOrders', function ($query) use ($statuses, $id_operator) {
                $query->whereIn('status', $statuses)
                    ->where('id_operator', $id_operator);
            })
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'orders' => $orders,
            'count' => $orders->count(),
        ]);
    }

    public function getAllOrders(Request $request)
    {
        $user = JWTAuth::parseToken()->authenticate();
        $salesId = $user->karyawan->id ?? null;

        if (!$salesId) {
            return response()->json([
                'message' => 'User bukan sales atau tidak memiliki ID karyawan.'
            ], 403);
        }

        $orders = Order::with([
            'customer',
            'detailOrders.alat',
            'detailOrders.operator',
            'pembayaran.detailPembayarans',
        ])
            ->where('id_sales', $salesId)
            ->orderByDesc('created_at')
            ->get();

        $formattedOrders = $orders->map(function ($order) {
            $pembayaran = $order->pembayaran;
            $detailOrders = $order->detailOrders ?? collect();
            $firstDetail = $detailOrders->first();
            $lastDetail = $detailOrders->last();

            return [
                'id' => $order->id,
                'nama_pemesan' => $order->customer->nama ?? '-',
                'alamat' => $firstDetail?->alamat ?? '-',
                'harga_sewa' => $firstDetail?->harga_sewa ?? 0,
                'total_sewa' => $firstDetail?->total_sewa ?? 0,
                'tagihan' => $pembayaran?->tagihan ?? 0,
                'status_order' => $lastDetail?->status ?? '-',
                'tanggal_order' => $order->created_at->format('Y-m-d'),
                'total_dibayar' => $pembayaran?->detailPembayarans->sum('jml_dibayar') ?? 0,

                'detail_orders' => $detailOrders->map(function ($detail) {
                    return [
                        'id' => $detail->id,
                        'alat' => $detail->alat->nama ?? '-',
                        'operator' => $detail->operator->nama ?? '-',
                        'alamat' => $detail->alamat,
                        'tgl_mulai' => $detail->tgl_mulai,
                        'tgl_selesai' => $detail->tgl_selesai,
                        'jam_mulai' => $detail->jam_mulai,
                        'jam_selesai' => $detail->jam_selesai,
                        'harga_sewa' => $detail->harga_sewa,
                        'total_sewa' => $detail->total_sewa,
                        'status' => $detail->status,
                    ];
                })->values(),

                'detail_pembayarans' => $pembayaran?->detailPembayarans->map(function ($detail) {
                    return [
                        'id' => $detail->id,
                        'jml_dibayar' => $detail->jml_dibayar,
                        'bukti_pembayaran' => $detail->bukti
                            ? asset('storage/' . $detail->bukti)
                            : null,
                    ];
                })->values() ?? [],

                // Ringkasan waktu
                'tgl_mulai' => $firstDetail?->tgl_mulai,
                'tgl_selesai' => $firstDetail?->tgl_selesai,
                'jam_mulai' => $firstDetail?->jam_mulai,
                'jam_selesai' => $firstDetail?->jam_selesai,
                'alat' => $firstDetail?->alat->nama ?? '-',
                'operator' => $firstDetail?->operator->nama ?? '-',
            ];
        });

        return response()->json([
            'orders' => $formattedOrders,
            'count' => $formattedOrders->count(),
        ]);
    }

    public function getAllOrdersPublic()
    {
        $orders = Order::with([
            'customer',
            'sales',
            'detailOrders.alat',
            'detailOrders.operator',
            'pembayaran.detailPembayarans',
        ])
            ->orderByDesc('created_at')
            ->get();

        $formattedOrders = $orders->map(function ($order) {
            $pembayaran = $order->pembayaran;
            $detailOrders = $order->detailOrders ?? collect();
            $firstDetail = $detailOrders->first();
            $lastDetail = $detailOrders->last();

            return [
                'id' => $order->id,
                'nama_pemesan' => $order->customer->nama ?? '-',
                'nama_sales' => $order->sales->nama ?? '-',
                'alamat' => $firstDetail?->alamat ?? '-',
                'harga_sewa' => $firstDetail?->harga_sewa ?? 0,
                'total_sewa' => $firstDetail?->total_sewa ?? 0,
                'tagihan' => $pembayaran?->tagihan ?? 0,
                'status_order' => $lastDetail?->status ?? '-',
                'tanggal_order' => $order->created_at->format('Y-m-d'),
                'total_dibayar' => $pembayaran?->detailPembayarans->sum('jml_dibayar') ?? 0,
                'inventori_name' => $firstDetail?->alat->nama ?? '-',

                'detail_orders' => $detailOrders->map(function ($detail) {
                    return [
                        'id' => $detail->id,
                        'alat' => $detail->alat->nama ?? '-',
                        'operator' => $detail->operator->nama ?? '-',
                        'alamat' => $detail->alamat,
                        'tgl_mulai' => $detail->tgl_mulai,
                        'tgl_selesai' => $detail->tgl_selesai,
                        'jam_mulai' => $detail->jam_mulai,
                        'jam_selesai' => $detail->jam_selesai,
                        'harga_sewa' => $detail->harga_sewa,
                        'total_sewa' => $detail->total_sewa,
                        'status' => $detail->status,
                    ];
                })->values(),

                'detail_pembayarans' => $pembayaran?->detailPembayarans->map(function ($detail) {
                    return [
                        'id' => $detail->id,
                        'jml_dibayar' => $detail->jml_dibayar,
                        'bukti_pembayaran' => $detail->bukti
                            ? asset('storage/' . $detail->bukti)
                            : null,
                    ];
                })->values() ?? [],

                'tgl_mulai' => $firstDetail?->tgl_mulai,
                'tgl_selesai' => $firstDetail?->tgl_selesai,
                'jam_mulai' => $firstDetail?->jam_mulai,
                'jam_selesai' => $firstDetail?->jam_selesai,
                'alat' => $firstDetail?->alat->nama ?? '-',
                'operator' => $firstDetail?->operator->nama ?? '-',
            ];
        });

        return response()->json([
            'orders' => $formattedOrders,
            'count' => $formattedOrders->count(),
        ]);
    }

    public function updateDetailOrder(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:pending,proses,persiapan,dikirim,selesai',
            'catatan' => 'nullable|string',
            'id_operator' => 'required|exists:karyawans,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();

        $detailOrder = DetailOrder::findOrFail($id);

        $operator = Karyawan::where('id', $data['id_operator'])
            ->whereHas('role', fn($q) => $q->where('jabatan', 'Operator Alat'))
            ->first();

        if (!$operator) {
            return response()->json(['error' => 'Operator tidak valid'], 422);
        }

        $detailOrder->update([
            'status' => $data['status'],
            'catatan' => $data['catatan'],
            'id_operator' => $operator->id,
        ]);

        if ($detailOrder->id_alat) {
            if (in_array($data['status'], ['persiapan', 'dikirim'])) {
                Inventory::where('id', $detailOrder->id_alat)->update(['status' => 'disewa']);
            } elseif (in_array($data['status'], ['pending', 'proses', 'selesai'])) {
                Inventory::where('id', $detailOrder->id_alat)->update(['status' => 'tersedia']);
            }
        }

        $order = $detailOrder->order()
            ->with(['customer', 'sales', 'detailOrders.alat', 'pembayaran.detailPembayarans'])
            ->first();

        $tagihan = $order->pembayaran->tagihan ?? 0;
        $totalBayar = $order->pembayaran->detailPembayarans->sum('jml_dibayar');
        $sisaBayar = $tagihan - $totalBayar;

        $orderData = [
            'id' => $order->id,
            'customer' => $order->customer->nama . ' - ' . $order->customer->instansi,
            'sales' => $order->sales->nama ?? '-',
            'jumlah_item' => $order->detailOrders->count(),
            'tagihan' => $tagihan,
            'total_bayar' => $totalBayar,
            'sisa_bayar' => $sisaBayar,
            'bukti_list' => $order->pembayaran->detailPembayarans->pluck('bukti')->filter()->toArray(),
            'created_at_human' => $order->created_at->diffForHumans(),
            'details' => $order->detailOrders->map(function ($detail) {
                return [
                    'alat' => $detail->alat->nama ?? '-',
                    'tgl_mulai' => optional($detail->tgl_mulai ? \Carbon\Carbon::parse($detail->tgl_mulai) : null)->format('d M Y'),
                    'jam_mulai' => optional($detail->jam_mulai ? \Carbon\Carbon::parse($detail->jam_mulai) : null)->format('H:i'),
                    'status' => $detail->status,
                ];
            }),
        ];

        event(new PengirimanUpdated($orderData));

        $notification = Notification::create([
            'title' => 'Status Order Diperbarui',
            'message' => 'Status order NSM-00' . $order->id . ' telah diperbarui menjadi "' . ucfirst($data['status']) . '".',
            'url' => '/pengiriman/' . $order->id . '/edit',
        ]);
        event(new NotificationCreated($notification));

        return response()->json([
            'message' => 'Detail order berhasil diperbarui',
            'data' => $detailOrder,
        ]);
    }

    public function getOperators()
    {
        $operators = Karyawan::whereHas('role', function ($query) {
            $query->where('jabatan', 'Operator Alat');
        })->select('id', 'nama')->get();

        return response()->json(['operators' => $operators]);
    }
}
