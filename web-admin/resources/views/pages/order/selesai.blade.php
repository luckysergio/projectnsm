@extends('layouts.app')

@section('content')
    <div class="max-w-7xl mx-auto px-4 py-10">
        <div class="flex justify-center">
            <form method="GET" id="filter-form"
                class="bg-white shadow-sm border border-gray-200 rounded-xl p-6 w-full max-w-4xl">
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 place-items-center">
                    <div class="w-full max-w-xs text-center">
                        <label for="bulan" class="block text-sm text-gray-600 mb-1">Bulan</label>
                        <select id="bulan" name="bulan" onchange="document.getElementById('filter-form').submit()"
                            class="w-full px-3 py-2 border rounded-lg shadow-sm focus:ring-blue-500 focus:border-blue-500 text-center">
                            <option value="">Pilih Bulan</option>
                            @for ($i = 1; $i <= 12; $i++)
                                <option value="{{ $i }}" {{ request('bulan') == $i ? 'selected' : '' }}>
                                    {{ DateTime::createFromFormat('!m', $i)->format('F') }}
                                </option>
                            @endfor
                        </select>
                    </div>

                    <div class="w-full max-w-xs text-center">
                        <label for="tahun" class="block text-sm text-gray-600 mb-1">Tahun</label>
                        <select id="tahun" name="tahun" onchange="document.getElementById('filter-form').submit()"
                            class="w-full px-3 py-2 border rounded-lg shadow-sm focus:ring-blue-500 focus:border-blue-500 text-center">
                            <option value="">Pilih Tahun</option>
                            @for ($y = 2025; $y <= 2030; $y++)
                                <option value="{{ $y }}" {{ request('tahun') == $y ? 'selected' : '' }}>
                                    {{ $y }}</option>
                            @endfor
                        </select>
                    </div>
                </div>
            </form>
        </div>

        @if (request('bulan') && request('tahun'))
            @if ($orders->count() > 0)
                <div class="mt-10 text-center">
                    <a href="{{ route('order.selesai.export', request()->only('bulan', 'tahun')) }}" target="_blank"
                        class="inline-flex items-center gap-2 bg-gradient-to-r from-red-500 to-red-600 hover:to-red-700 text-white px-6 py-2.5 rounded-lg shadow transition">
                        <i class="fas fa-file-pdf"></i> Export PDF
                    </a>

                    <div class="mt-4 text-xl font-semibold text-green-600">
                        Total Pendapatan: <span class="font-bold">Rp{{ number_format($totalPendapatan) }}</span>
                    </div>
                </div>
            @else
                <div class="mt-10 text-center text-gray-500 text-lg">
                    <i class="fas fa-info-circle"></i> Tidak ada data order pada bulan dan tahun yang dipilih.
                </div>
            @endif

            @if ($orders->count() > 0)
                <div class="mt-10 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                    @foreach ($orders as $order)
                        @php
                            $tagihan = $order->pembayaran->tagihan ?? 0;
                            $detailPembayarans = $order->pembayaran->detailPembayarans ?? collect();
                            $totalBayar = $detailPembayarans->sum('jml_dibayar');
                            $sisaBayar = $tagihan - $totalBayar;
                        @endphp

                        <div x-data="{ open: false }"
                            class="bg-white rounded-3xl shadow-md border border-gray-100 p-6 hover:shadow-xl transition-all duration-300">
                            <div class="text-center mb-4">
                                <h2 class="text-blue-600 font-bold text-lg">SEWA-{{ sprintf('%03d', $order->id) }}</h2>
                                <div class="text-sm text-gray-500"><i
                                        class="fas fa-clock mr-1"></i>{{ $order->created_at->diffForHumans() }}</div>
                            </div>

                            <div class="text-sm text-gray-600 space-y-1 mb-4">
                                <p><strong>Pemesan:</strong> {{ $order->customer->nama }}</p>
                                <p><strong>Sales:</strong> {{ $order->sales->nama ?? '-' }}</p>
                                <p>
                                    <strong>Jumlah Item:</strong>
                                    <button @click="open = true" class="text-blue-600 hover:underline font-semibold">
                                        {{ $order->detailOrders->count() }} item
                                    </button>
                                </p>
                            </div>

                            <div class="bg-gray-50 rounded-xl p-4 text-sm text-gray-700 space-y-1">
                                <p><strong>Total Tagihan:</strong> Rp {{ number_format($tagihan, 0, ',', '.') }}</p>
                                <p><strong>Jumlah Bayar:</strong> Rp {{ number_format($totalBayar, 0, ',', '.') }}</p>
                                <p><strong>Sisa Bayar:</strong> Rp {{ number_format($sisaBayar, 0, ',', '.') }}</p>

                                <div class="mt-3 text-center">
                                    <p><strong>Bukti:</strong></p>
                                    @if ($detailPembayarans->isNotEmpty())
                                        <div class="grid grid-cols-2 gap-3 mt-2">
                                            @foreach ($detailPembayarans as $dp)
                                                @if ($dp->bukti)
                                                    <div class="relative border rounded-xl overflow-hidden">
                                                        <a href="{{ asset('storage/' . $dp->bukti) }}" target="_blank">
                                                            <img src="{{ asset('storage/' . $dp->bukti) }}"
                                                                class="w-full h-40 object-contain bg-white border border-gray-200"
                                                                alt="Bukti">
                                                        </a>
                                                        <div
                                                            class="absolute bottom-0 w-full bg-white bg-opacity-70 text-xs text-center text-gray-600 py-1">
                                                            Dibayar: Rp.{{ number_format($dp->jml_dibayar, 0, ',', '.') }}
                                                        </div>
                                                    </div>
                                                @endif
                                            @endforeach
                                        </div>
                                    @else
                                        <p class="italic text-gray-400">Belum ada bukti pembayaran</p>
                                    @endif
                                </div>
                            </div>

                            <div x-show="open" x-cloak x-transition
                                class="fixed inset-0 flex items-center justify-center z-50 bg-black bg-opacity-40">
                                <div @click.away="open = false" class="bg-white rounded-xl max-w-lg w-full p-6 shadow-lg">
                                    <h3 class="text-lg font-bold text-blue-600 mb-4 text-center">Detail Order</h3>
                                    <ul class="space-y-4 text-sm text-gray-700 max-h-60 overflow-y-auto">
                                        @foreach ($order->detailOrders as $detail)
                                            <li class="border-b pb-3">
                                                <p><strong>Alat:</strong> {{ $detail->alat->nama ?? '-' }}</p>
                                                <p><strong>Alamat:</strong> {{ $detail->alamat }}</p>
                                                <p>
                                                    <strong>Tanggal :</strong>
                                                    {{ \Carbon\Carbon::parse($detail->tgl_mulai)->format('d-m-Y') }} Mulai
                                                    :
                                                    {{ $detail->jam_mulai }}
                                                </p>
                                                <p>
                                                    <strong>Tanggal :</strong>
                                                    {{ $detail->tgl_selesai ? \Carbon\Carbon::parse($detail->tgl_selesai)->format('d-m-Y') : '-' }}
                                                    Selesai : {{ $detail->jam_selesai ?? '-' }}
                                                </p>
                                                <p><strong>Total Hari:</strong> {{ $detail->total_sewa }} hari</p>
                                                <p><strong>Harga Sewa:</strong>
                                                    Rp{{ number_format($detail->harga_sewa, 0, ',', '.') }}</p>
                                                @if ($detail->catatan)
                                                    <p class="italic text-gray-500"><strong>Catatan:</strong>
                                                        {{ $detail->catatan }}</p>
                                                @endif
                                            </li>
                                        @endforeach
                                    </ul>

                                    <div class="mt-4 text-center">
                                        <button @click="open = false"
                                            class="px-4 py-2 bg-gray-300 hover:bg-gray-400 rounded-lg text-sm font-medium">
                                            Tutup
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    @endforeach
                </div>

                <div class="mt-10">
                    {{ $orders->withQueryString()->links() }}
                </div>
            @endif
        @else
            <div class="text-center text-gray-400 mt-12">
                <i class="fas fa-calendar-alt text-4xl mb-4"></i>
                <p class="text-lg">Silakan pilih <strong>bulan</strong> dan <strong>tahun</strong> terlebih dahulu.</p>
            </div>
        @endif
    </div>
@endsection
