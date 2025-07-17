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
                    window.location.href = "/perawatan";
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
        <div id="perawatanCardContainer" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-3 gap-8">
            @forelse ($perawatans as $perawatan)
                <div id="perawatan-card-{{ $perawatan->id }}"
                    class="bg-white rounded-3xl shadow-md border border-gray-100 p-6 transition-all duration-300 hover:shadow-xl">
                    <div class="text-center mb-4">
                        <h2 class="text-blue-600 font-bold text-lg">PRW-{{ sprintf('%03d', $perawatan->id) }}</h2>
                        <div class="text-sm text-gray-500">
                            <i class="fas fa-clock mr-1"></i>{{ $perawatan->created_at->diffForHumans() }}
                        </div>
                    </div>

                    <div class="text-sm text-gray-600 space-y-1 mb-4">
                        <p><strong>Operator:</strong> {{ $perawatan->operator->nama ?? '-' }}</p>
                    </div>

                    <div class="bg-gray-50 rounded-xl p-4 mb-4 text-sm text-gray-700 space-y-2">
                        @foreach ($perawatan->detailPerawatans as $detail)
                            @php
                                $statusClass = match ($detail->status) {
                                    'selesai' => 'bg-green-100 text-green-700',
                                    'proses' => 'bg-yellow-100 text-yellow-800',
                                    default => 'bg-gray-200 text-gray-600',
                                };
                            @endphp
                            <div class="border rounded-md p-3 bg-white">
                                <p><strong>Alat:</strong> {{ $detail->alat->nama ?? '-' }}</p>
                                <p><strong>Tgl Mulai:</strong>
                                    {{ \Carbon\Carbon::parse($detail->tgl_mulai)->format('d-m-Y') }}</p>
                                <p><strong>Tgl Selesai:</strong>
                                    {{ $detail->tgl_selesai ? \Carbon\Carbon::parse($detail->tgl_selesai)->format('d-m-Y') : '-' }}
                                </p>
                                <p><strong>Status:</strong>
                                    <span
                                        class="inline-block px-2 py-1 rounded-full text-xs font-medium {{ $statusClass }}">
                                        {{ ucfirst($detail->status) }}
                                    </span>
                                </p>
                                <p><strong>Catatan:</strong> {{ $detail->catatan ?? '-' }}</p>
                            </div>
                        @endforeach
                    </div>

                    <div class="flex gap-3 mt-4">
                        <form action="{{ route('perawatan.edit', $perawatan->id) }}" method="GET" class="w-full">
                            <button type="submit"
                                class="w-full py-2 rounded-xl bg-gradient-to-tr from-blue-500 to-blue-600 text-white font-semibold shadow hover:from-blue-600 hover:to-blue-700 transition-all">
                                Proses
                            </button>
                        </form>

                        <button onclick="confirmDelete({{ $perawatan->id }})"
                            class="w-full py-2 rounded-xl bg-gradient-to-tr from-red-500 to-red-600 text-white font-semibold shadow hover:from-red-600 hover:to-red-700 transition-all">
                            Delete
                        </button>

                        <form id="delete-form-{{ $perawatan->id }}"
                            action="{{ route('perawatan.destroy', $perawatan->id) }}" method="POST" class="hidden">
                            @csrf
                            @method('DELETE')
                        </form>
                    </div>
                </div>
            @empty
                <div class="text-center text-gray-400 text-xl py-20 col-span-full">
                    Tidak ada data perawatan
                </div>
            @endforelse
        </div>

        <div class="mt-10">
            {{ $perawatans->links() }}
        </div>

        <a href="{{ route('perawatan.create') }}"
            class="fixed bottom-6 right-6 inline-flex items-center gap-2 px-5 py-3 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-semibold rounded-full shadow-lg transform hover:-translate-y-0.5 transition z-50 text-sm">
            <i class="fas fa-plus"></i> Tambah Perawatan
        </a>
    </div>
@endsection

@push('scripts')
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        function confirmDelete(id) {
            Swal.fire({
                title: 'Yakin ingin menghapus?',
                text: "Data perawatan ini akan dihapus permanen.",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Ya, Hapus!',
                cancelButtonText: 'Batal'
            }).then((result) => {
                if (result.isConfirmed) {
                    document.getElementById('delete-form-' + id).submit();
                }
            })
        }
    </script>
@endpush
