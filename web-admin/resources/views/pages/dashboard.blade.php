@extends('layouts.app')

@section('content')
    <div class="max-w-7xl mx-auto p-4">
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">

            <a href="/order"
                class="relative flex flex-col items-center justify-center bg-gradient-to-r from-blue-500 to-blue-700 text-white p-6 rounded-xl shadow-md hover:shadow-lg transition-transform transform hover:-translate-y-1">
                <i class="fas fa-box fa-3x mb-4"></i>
                <h3 class="text-lg font-semibold">Order Masuk</h3>
                <div id="orderCount"
                    class="absolute top-2 right-4 bg-red-500 text-white text-xs font-bold px-2 py-1 rounded-full {{ $orderCount > 0 ? '' : 'hidden' }}">
                    {{ $orderCount }}
                </div>
            </a>

            <a href="/pengiriman"
                class="relative flex flex-col items-center justify-center bg-gradient-to-r from-purple-400 to-purple-600 text-white p-6 rounded-xl shadow-md hover:shadow-lg transition-transform transform hover:-translate-y-1">
                <i class="fas fa-calendar-alt fa-3x mb-4"></i>
                <h3 class="text-lg font-semibold">Jadwal Pengiriman</h3>
                <div id="pengirimanCount"
                    class="absolute top-2 right-4 bg-red-500 text-white text-xs font-bold px-2 py-1 rounded-full {{ $pengirimanCount > 0 ? '' : 'hidden' }}">
                    {{ $pengirimanCount }}
                </div>
            </a>

            <a href="/perawatan"
                class="relative flex flex-col items-center justify-center bg-gradient-to-r from-yellow-400 to-yellow-600 text-white p-6 rounded-xl shadow-md hover:shadow-lg transition-transform transform hover:-translate-y-1">
                <i class="fas fa-tools fa-3x mb-4"></i>
                <h3 class="text-lg font-semibold">Jadwal Perawatan</h3>
                <div id="perawatanCount"
                    class="absolute top-2 right-4 bg-red-500 text-white text-xs font-bold px-2 py-1 rounded-full {{ $perawatanCount > 0 ? '' : 'hidden' }}">
                    {{ $perawatanCount }}
                </div>
            </a>

            <a href="/dokumentasi"
                class="flex flex-col items-center justify-center bg-gradient-to-r from-green-400 to-green-600 text-white p-6 rounded-xl shadow-md hover:shadow-lg transition-transform transform hover:-translate-y-1">
                <i class="fas fa-image fa-3x mb-4"></i>
                <h3 class="text-lg font-semibold">Dokumentasi Order</h3>
            </a>

        </div>
    </div>
@endsection