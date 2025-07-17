@extends('layouts.app')

@section('content')
    <div class="max-w-7xl mx-auto px-4 py-10">

        <div class="flex justify-center mb-8">
            <input type="text" name="search" id="searchInput"
                value="{{ request('search') }}"
                placeholder="Cari nama pemesan atau instansi..."
                class="w-full max-w-md px-4 py-2 border border-gray-300 rounded-xl shadow-sm focus:ring-2 focus:ring-blue-500 focus:outline-none transition"
                autofocus>
        </div>

        @if ($dokumentasi->isEmpty())
            <div id="empty-dokumentasi-message" class="text-center py-20">
                <i class="fas fa-folder-open text-4xl text-gray-300 mb-4"></i>
                <p class="text-gray-500 text-lg">Belum ada dokumentasi order yang tersedia.</p>
            </div>
        @endif

        <div id="dokumentasiCardContainer" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            @foreach ($dokumentasi as $item)
                <div class="bg-white border border-gray-200 rounded-2xl shadow-sm p-6 transition hover:shadow-md">
                    <div class="mb-3 space-y-1">
                        <p class="text-xs text-gray-500">Nama Pemesan</p>
                        <p class="font-semibold text-gray-800">{{ $item->order->customer->nama ?? '-' }}</p>

                        <p class="text-xs text-gray-500">Instansi</p>
                        <p class="text-sm text-gray-800">{{ $item->order->customer->instansi ?? '-' }}</p>

                        <p class="text-xs text-gray-500">Tanggal Dokumentasi</p>
                        <p class="text-sm text-gray-700">{{ $item->created_at->format('d M Y H:i') }}</p>
                    </div>

                    @if ($item->catatan)
                        <div class="mb-3">
                            <p class="text-xs text-gray-500">Catatan</p>
                            <p class="text-sm text-gray-700">{{ $item->catatan }}</p>
                        </div>
                    @endif

                    @if (is_array($item->foto) && count($item->foto))
                        <div class="grid grid-cols-2 gap-2 mt-2">
                            @foreach ($item->foto as $foto)
                                <a href="{{ asset('storage/' . $foto) }}" target="_blank"
                                    class="group relative overflow-hidden rounded-lg hover:shadow-md transition">
                                    <img src="{{ asset('storage/' . $foto) }}" alt="Foto"
                                        class="w-full h-28 object-contain bg-gray-50 rounded-md group-hover:scale-105 transition">
                                </a>
                            @endforeach
                        </div>
                    @else
                        <p class="italic text-sm text-gray-400 mt-2">Tidak ada foto dokumentasi</p>
                    @endif
                </div>
            @endforeach
        </div>

        @if ($dokumentasi->isNotEmpty())
            <div class="mt-10">
                {{ $dokumentasi->withQueryString()->links() }}
            </div>
        @endif
    </div>

    <script>
        const searchInput = document.getElementById('searchInput');
        let typingTimer;
        const delay = 600;

        searchInput.addEventListener('input', () => {
            clearTimeout(typingTimer);
            typingTimer = setTimeout(() => {
                const searchValue = searchInput.value.trim();
                const url = new URL(window.location.href);
                if (searchValue !== "") {
                    url.searchParams.set('search', searchValue);
                } else {
                    url.searchParams.delete('search');
                }
                window.location.href = url.toString();
            }, delay);
        });
    </script>
@endsection
