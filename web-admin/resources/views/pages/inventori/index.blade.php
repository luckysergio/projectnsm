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
                    window.location.href = "/inventori";
                }
            });
        </script>
    @endif

    <div class="max-w-6xl mx-auto p-4">
        <div class="flex flex-col md:flex-row justify-between items-center mb-6">
            <h2 class="text-2xl font-bold text-blue-600 mb-4 md:mb-0">Data Inventory</h2>
            <a href="/inventori/create"
                class="inline-flex items-center gap-3 px-5 py-3 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-semibold rounded-lg shadow-md transform hover:-translate-y-0.5 transition">
                <i class="fas fa-plus"></i> Tambah Data Alat
            </a>
        </div>

        {{-- Filter Jenis --}}
        <form method="GET" id="filter-form" class="flex justify-center mb-6">
            <select name="jenis_id" onchange="document.getElementById('filter-form').submit()"
                class="px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:ring-blue-500 focus:border-blue-500 w-full md:w-1/3 text-center">
                <option value="">🔍 Semua Jenis Alat</option>
                @foreach ($jenisList as $jenis)
                    <option value="{{ $jenis->id }}" {{ request('jenis_id') == $jenis->id ? 'selected' : '' }}>
                        {{ $jenis->nama }}
                    </option>
                @endforeach
            </select>
        </form>

        <div class="bg-white shadow-lg rounded-xl overflow-hidden">
            <div class="overflow-x-auto">
                <table class="min-w-full text-sm text-left">
                    <thead class="bg-blue-600 text-white">
                        <tr>
                            <th class="px-6 py-3 text-center">Nama</th>
                            <th class="px-6 py-3 text-center">Jenis Alat</th>
                            <th class="px-6 py-3 text-center">Harga</th>
                            <th class="px-6 py-3 text-center">Pemakaian</th>
                            <th class="px-6 py-3 text-center">Status</th>
                            <th class="px-6 py-3 text-center">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-200 bg-white">
                        @forelse ($inventories as $inventory)
                            <tr class="hover:bg-gray-50 transition duration-200">
                                <td class="px-6 py-4 text-center font-medium text-gray-700 whitespace-nowrap">
                                    {{ $inventory->nama }}
                                </td>
                                <td class="px-6 py-4 text-center text-gray-600 whitespace-nowrap">
                                    {{ $inventory->jenisAlat->nama ?? '-' }}
                                </td>
                                <td class="px-6 py-4 text-center text-gray-700 whitespace-nowrap">
                                    Rp {{ number_format($inventory->harga, 0, ',', '.') }}/Jam
                                </td>
                                <td class="px-6 py-4 text-center text-gray-600 whitespace-nowrap">
                                    {{ $inventory->pemakaian }} jam
                                </td>
                                <td class="px-6 py-4 text-center">
                                    <span
                                        class="inline-block px-3 py-1 text-xs font-semibold rounded-full
                                {{ $inventory->status == 'tersedia'
                                    ? 'bg-green-100 text-green-700'
                                    : ($inventory->status == 'disewa'
                                        ? 'bg-yellow-100 text-yellow-700'
                                        : 'bg-red-100 text-red-700') }}">
                                        {{ ucfirst($inventory->status) }}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-center space-x-2">
                                    <a href="/inventori/{{ $inventory->id }}"
                                        class="inline-flex items-center justify-center w-8 h-8 text-yellow-500 hover:text-yellow-600 transition"
                                        title="Edit">
                                        ✏️
                                    </a>
                                    <button type="button"
                                        class="inline-flex items-center justify-center w-8 h-8 text-red-500 hover:text-red-600 transition delete-button"
                                        data-id="{{ $inventory->id }}" title="Hapus">
                                        🗑️
                                    </button>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="6" class="px-6 py-10 text-center text-gray-500">
                                    Tidak ada data inventory.
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            {{-- Pagination --}}
            <div class="px-6 py-4 bg-gray-50 border-t">
                {{ $inventories->withQueryString()->links() }}
            </div>
        </div>

    </div>

    {{-- Form Delete --}}
    <form id="delete-form" method="POST" class="hidden">
        @csrf
        @method('DELETE')
    </form>

    <script>
        document.querySelectorAll('.delete-button').forEach(button => {
            button.addEventListener('click', function() {
                const id = this.dataset.id;
                Swal.fire({
                    title: 'Yakin ingin menghapus?',
                    text: "Data tidak bisa dikembalikan setelah dihapus!",
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#e3342f',
                    cancelButtonColor: '#6c757d',
                    confirmButtonText: 'Hapus',
                    cancelButtonText: 'Batal'
                }).then((result) => {
                    if (result.isConfirmed) {
                        const form = document.getElementById('delete-form');
                        form.action = `/inventori/${id}`;
                        form.submit();
                    }
                })
            });
        });
    </script>
@endsection
