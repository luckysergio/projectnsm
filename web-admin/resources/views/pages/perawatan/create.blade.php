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

    <div class="max-w-4xl mx-auto px-4 py-10">

        <form action="{{ route('perawatan.store') }}" method="POST" class="bg-white p-6 rounded-xl shadow-md space-y-6">
            @csrf
            <div>
                <label for="id_operator" class="block text-sm font-medium text-gray-700 mb-1">Pilih Operator</label>
                <select name="id_operator" id="id_operator" required
                    class="w-full border border-gray-300 px-4 py-2 rounded-lg focus:outline-none focus:ring focus:border-blue-500">
                    <option value="" disabled selected>-- Pilih Operator --</option>
                    @foreach ($operators as $operator)
                        <option value="{{ $operator->id }}">{{ $operator->nama }}</option>
                    @endforeach
                </select>
            </div>
            <div id="detail-container">

                <div class="grid grid-cols-1 gap-6">
                    <div class="bg-gray-50 border p-5 rounded-xl space-y-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Alat</label>
                            <select name="details[0][id_alat]" class="w-full border border-gray-300 rounded-lg px-4 py-2">
                                @foreach ($alatList as $alat)
                                    <option value="{{ $alat->id }}">{{ $alat->nama }}</option>
                                @endforeach
                            </select>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Tanggal Mulai</label>
                            <input type="date" name="details[0][tgl_mulai]" class="w-full border border-gray-300 rounded-lg px-4 py-2" required>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
                            <select name="details[0][status]" class="w-full border border-gray-300 rounded-lg px-4 py-2">
                                <option value="pending">Pending</option>
                                <option value="proses">Proses</option>
                                <option value="selesai">Selesai</option>
                            </select>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Catatan</label>
                            <textarea name="details[0][catatan]" rows="2"
                                class="w-full border border-gray-300 rounded-lg px-4 py-2"
                                placeholder="Masukkan catatan tambahan jika ada..."></textarea>
                        </div>
                    </div>
                </div>
            </div>
            <div class="pt-6 flex justify-center">
                <button type="submit"
                    class="inline-flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-blue-500 to-blue-600 text-white font-semibold rounded-lg shadow-md hover:from-blue-600 hover:to-blue-700 transition-all">
                    <i class="fas fa-save"></i> Simpan Perawatan
                </button>
            </div>
        </form>
    </div>
@endsection
