@extends('layouts.app')

@section('content')

    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.15/dist/sweetalert2.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.15/dist/sweetalert2.all.min.js"></script>

    @if (session('success'))
        <script>
            Swal.fire({
                icon: 'success',
                title: 'Berhasil!',
                text: @json(session('success')),
                confirmButtonColor: '#2563eb',
                didClose: () => {
                    window.location.href = "/order";
                }
            });
        </script>
    @endif

    @if ($errors->any())
        <script>
            Swal.fire({
                icon: 'error',
                title: 'Terjadi Kesalahan',
                html: `{!! implode('<br>', $errors->all()) !!}`,
                confirmButtonColor: '#e3342f',
            });
        </script>
    @endif
    <div class="max-w-7xl mx-auto px-4 py-8">
        <div id="orderCardContainer" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-3 gap-8">
            @forelse ($orders as $order)
                @php
                    $tagihan = $order->pembayaran->tagihan ?? 0;
                    $detailPembayarans = $order->pembayaran->detailPembayarans ?? collect();
                    $totalBayar = $detailPembayarans->sum('jml_dibayar');
                    $sisaBayar = $tagihan - $totalBayar;
                @endphp

                <div id="order-card-{{ $order->id }}"
                    class="bg-white rounded-3xl shadow-md border border-gray-100 p-6 transition-all duration-300 hover:shadow-xl">

                    <div class="text-center mb-4">
                        <h2 class="text-blue-600 font-bold text-lg">SEWA-{{ sprintf('%03d', $order->id) }}</h2>
                        <div class="text-sm text-gray-500">
                            <i class="fas fa-clock mr-1"></i>{{ $order->created_at->diffForHumans() }}
                        </div>
                    </div>

                    <div class="text-sm text-gray-600 space-y-1 mb-4">
                        <p><strong>Pemesan:</strong> {{ $order->customer->nama }}</p>
                        <p><strong>Sales:</strong> {{ $order->sales->nama ?? '-' }}</p>
                        <p><strong>Jumlah Item:</strong> {{ $order->detailOrders->count() }}</p>
                    </div>

                    <div class="bg-gray-50 rounded-xl p-4 mb-4 text-sm text-gray-700 space-y-1">
                        <p><strong>Total Tagihan:</strong> Rp {{ number_format($tagihan, 0, ',', '.') }}</p>
                        <p><strong>Jumlah Bayar:</strong> Rp {{ number_format($totalBayar, 0, ',', '.') }}</p>
                        <p><strong>Sisa Bayar:</strong> Rp {{ number_format($sisaBayar, 0, ',', '.') }}</p>

                        <div class="mt-3">
                            <p><strong>Bukti:</strong></p>
                            @if ($detailPembayarans->isNotEmpty())
                                <div class="grid grid-cols-2 gap-3 mt-2">
                                    @foreach ($detailPembayarans as $dp)
                                        @if ($dp->bukti)
                                            <div class="relative border rounded-xl overflow-hidden">
                                                <a href="{{ asset('storage/' . $dp->bukti) }}" target="_blank">
                                                    <img src="{{ asset('storage/' . $dp->bukti) }}" alt="Bukti Pembayaran"
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
                        <form action="/order/{{ $order->id }}" method="GET" class="w-full">
                            <button type="submit"
                                class="w-full py-2 rounded-xl bg-gradient-to-tr from-blue-500 to-blue-600 text-white font-semibold shadow hover:from-blue-600 hover:to-blue-700 transition-all">
                                Proses
                            </button>
                        </form>

                        <button onclick="confirmReject({{ $order->id }})"
                            class="w-full py-2 rounded-xl bg-gradient-to-tr from-red-500 to-red-600 text-white font-semibold shadow hover:from-red-600 hover:to-red-700 transition-all">
                            Reject
                        </button>

                        <form id="reject-form-{{ $order->id }}" action="{{ route('order.destroy', $order->id) }}"
                            method="POST" class="hidden">
                            @csrf
                            @method('DELETE')
                        </form>
                    </div>

                </div>
            @empty
                <div class="text-center text-gray-400 text-xl py-20 col-span-full">
                    Tidak ada order masuk
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
            })
        }
    </script>
@endpush
