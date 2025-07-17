@extends('layouts.app')

@section('content')
    <div class="max-w-7xl mx-auto px-4 py-10">
        <div class="flex justify-center">
            <form method="GET" id="filter-form"
                class="bg-white shadow-sm border border-gray-200 rounded-xl p-6 w-full max-w-4xl">
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 justify-center place-items-center">
                    <div class="w-full max-w-xs text-center">
                        <label for="bulan" class="block text-sm text-gray-600 mb-1">Bulan</label>
                        <select id="bulan" name="bulan" onchange="document.getElementById('filter-form').submit()"
                            class="bg-white border border-gray-300 rounded-lg px-3 py-2 shadow-sm focus:ring-blue-500 focus:border-blue-500 text-center w-full">
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
                            class="bg-white border border-gray-300 rounded-lg px-3 py-2 shadow-sm focus:ring-blue-500 focus:border-blue-500 text-center w-full">
                            <option value="">Pilih Tahun</option>
                            @for ($y = 2025; $y <= 2030; $y++)
                                <option value="{{ $y }}" {{ request('tahun') == $y ? 'selected' : '' }}>
                                    {{ $y }}
                                </option>
                            @endfor
                        </select>
                    </div>
                </div>
            </form>
        </div>

        @if (request('bulan') && request('tahun'))
            @if ($perawatans->isNotEmpty())
                <div class="mt-10 flex flex-col items-center justify-center text-center">
                    <a href="{{ route('perawatan.selesai.export', request()->only('bulan', 'tahun')) }}" target="_blank"
                        class="inline-flex items-center gap-2 bg-gradient-to-r from-red-500 to-red-600 hover:to-red-700 text-white px-6 py-2.5 rounded-lg shadow transition">
                        <i class="fas fa-file-pdf"></i> Export PDF
                    </a>
                </div>
            @endif

            <div class="mt-10">
                @if ($perawatans->isEmpty())
                    <div class="text-center text-gray-400 py-20">
                        🚫 Belum ada data perawatan untuk bulan dan tahun ini.
                    </div>
                @else
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                        @foreach ($perawatans as $perawatan)
                            <div class="bg-white rounded-3xl shadow-md border border-gray-100 p-6 hover:shadow-xl">
                                {{-- Header --}}
                                <div class="text-center mb-4">
                                    <h2 class="text-green-600 font-bold text-lg">
                                        PERAWATAN-{{ sprintf('%03d', $perawatan->id) }}</h2>
                                    <div class="text-sm text-gray-500">
                                        <i class="fas fa-clock mr-1"></i>
                                        {{ \Carbon\Carbon::parse($perawatan->created_at)->format('d-m-y') }}
                                    </div>
                                </div>

                                <div class="text-sm text-gray-600 space-y-1 mb-4 text-center">
                                    <p><strong>Operator:</strong> {{ $perawatan->operator->nama ?? '-' }}</p>
                                </div>

                                <div class="space-y-3">
                                    @foreach ($perawatan->detailPerawatans as $detail)
                                        @php
                                            $statusClass = match ($detail->status) {
                                                'selesai' => 'bg-green-100 text-green-700',
                                                'proses' => 'bg-yellow-100 text-yellow-800',
                                                default => 'bg-gray-200 text-gray-600',
                                            };
                                        @endphp

                                        <div class="bg-gray-50 border rounded-lg p-3 text-sm">
                                            <p><strong>Alat:</strong> {{ $detail->alat->nama ?? '-' }}</p>
                                            <p><strong>Tgl Mulai:</strong>
                                                {{ \Carbon\Carbon::parse($detail->tgl_mulai)->format('d-m-y') }}</p>
                                            <p><strong>Tgl Selesai:</strong>
                                                {{ $detail->tgl_selesai ? \Carbon\Carbon::parse($detail->tgl_selesai)->format('d-m-y') : '-' }}
                                            </p>
                                            <p>
                                                <strong>Status:</strong>
                                                <span
                                                    class="inline-block px-2 py-1 rounded-full font-medium {{ $statusClass }}">
                                                    {{ ucfirst($detail->status) }}
                                                </span>
                                            </p>
                                            <p><strong>Catatan:</strong> {{ $detail->catatan ?? '-' }}</p>
                                        </div>
                                    @endforeach
                                </div>
                            </div>
                        @endforeach
                    </div>

                    <div class="mt-10">
                        {{ $perawatans->withQueryString()->links() }}
                    </div>
                @endif
            </div>
        @else
            <div class="mt-10 text-center text-gray-400">
                <i class="fas fa-calendar-alt text-4xl mb-4"></i>
                <p class="text-lg">
                    Silakan pilih <strong>bulan</strong> dan <strong>tahun</strong> terlebih dahulu untuk melihat data
                    perawatan.
                </p>
            </div>
        @endif
    </div>
@endsection
