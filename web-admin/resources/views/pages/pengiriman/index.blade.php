@extends('layouts.app')

@section('content')
    <div class="max-w-7xl mx-auto px-4 py-8">

        <div id="pengirimanCardContainer" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-3 gap-8">
            @forelse ($orders as $order)
                @php
                    $tagihan = $order->pembayaran->tagihan ?? 0;
                    $detailPembayarans = $order->pembayaran->detailPembayarans ?? collect();
                    $totalBayar = $detailPembayarans->sum('jml_dibayar');
                    $sisaBayar = $tagihan - $totalBayar;
                @endphp

                <div id="pengiriman-card-{{ $order->id }}"
                    class="bg-white rounded-3xl shadow-md border border-gray-100 p-6 transition-all duration-300 hover:shadow-xl">

                    <div class="text-center mb-4">
                        <h2 class="text-blue-600 font-bold text-lg">SEWA-{{ sprintf('%03d', $order->id) }}</h2>
                        <div class="text-sm text-gray-500">
                            <i class="fas fa-clock mr-1"></i>{{ $order->created_at->diffForHumans() }}
                        </div>
                    </div>

                    <div class="text-sm text-gray-600 space-y-1 mb-4 text-center">
                        <p>{{ $order->customer->nama }} - {{ $order->customer->instansi }}</p>
                    </div>

                    <div class="bg-gray-50 rounded-xl p-4 mb-4 text-sm text-gray-700 space-y-2">
                        @foreach ($order->detailOrders as $detail)
                            @php
                                $statusClass = match ($detail->status) {
                                    'proses' => 'bg-yellow-100 text-yellow-800',
                                    'persiapan' => 'bg-blue-100 text-blue-700',
                                    'dikirim' => 'bg-green-100 text-green-700',
                                    default => 'bg-gray-200 text-gray-600',
                                };
                            @endphp
                            <div class="border border-gray-200 rounded-md p-3 bg-white mb-2">
                                <p><strong>Alat:</strong> {{ $detail->alat->nama ?? '-' }}</p>
                                <p><strong>Kirim:</strong>
                                    {{ $detail->tgl_mulai ? \Carbon\Carbon::parse($detail->tgl_mulai)->format('d M Y') : '-' }}
                                </p>
                                <p><strong>Jam Mulai:</strong>
                                    {{ $detail->jam_mulai ? \Carbon\Carbon::parse($detail->jam_mulai)->format('H:i') : '-' }}
                                </p>
                                <p>
                                    <strong>Status:</strong>
                                    <span class="inline-block px-2 py-1 rounded-full text-xs font-medium {{ $statusClass }}">
                                        {{ ucfirst($detail->status) }}
                                    </span>
                                </p>
                            </div>
                        @endforeach
                    </div>

                    <div class="bg-gray-50 rounded-xl p-4 mb-4 text-sm text-gray-700 space-y-1">
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
                                                        alt="Bukti Pembayaran"
                                                        class="w-full h-40 object-contain bg-white border border-gray-200">
                                                </a>
                                                <div
                                                    class="absolute bottom-0 left-0 right-0 bg-white bg-opacity-70 text-center text-xs text-gray-600 py-1">
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

                    <div class="flex gap-3 mt-4">
                        <form action="/pengiriman/{{ $order->id }}/edit" method="GET" class="w-full">
                            <button type="submit"
                                class="w-full py-2 rounded-xl bg-gradient-to-tr from-blue-500 to-blue-600 text-white font-semibold shadow hover:from-blue-600 hover:to-blue-700 transition-all">
                                Proses
                            </button>
                        </form>
                    </div>

                </div>
            @empty
                <div class="text-center text-gray-400 text-xl py-20 w-full col-span-full">
                    Tidak ada jadwal pengiriman
                </div>
            @endforelse
        </div>

        <div class="mt-10">
            {{ $orders->links() }}
        </div>
    </div>
@endsection

@push('scripts')
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        function confirmReject(orderId) {
            Swal.fire({
                title: 'Yakin ingin reject?',
                text: "Data order akan dihapus permanen!",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Ya, Hapus!',
                cancelButtonText: 'Batal'
            }).then((result) => {
                if (result.isConfirmed) {
                    document.getElementById('reject-form-' + orderId).submit();
                }
            });
        }
    </script>
@endpush
