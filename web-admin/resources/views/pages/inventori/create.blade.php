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

    <div class="max-w-xl mx-auto p-4">
        <div class="bg-white p-6 rounded-lg shadow">
            <form action="/inventori" method="POST" class="bg-white shadow-md rounded px-6 py-8 space-y-6"">
                @csrf

                <div>
                    <label for="nama" class="font-medium">Nama Alat</label>
                    <input type="text" name="nama" autocomplete="off"
                        class="w-full border border-gray-300 rounded px-3 py-2 focus:ring focus:ring-blue-200" required>
                </div>

                <div>
                    <label class="font-medium">Jenis Alat</label>
                    <select name="jenis_id" id="jenis_id"
                        class="w-full border border-gray-300 rounded px-3 py-2 focus:ring focus:ring-blue-200">
                        <option value="">-- Pilih Jenis --</option>
                        @foreach ($jenisAlats as $jenis)
                            <option value="{{ $jenis->id }}">{{ $jenis->nama }}</option>
                        @endforeach
                    </select>
                </div>

                <div>
                    <label for="new_jenis" class="font-medium">Atau Tambah Jenis Baru</label>
                    <input type="text" name="new_jenis" id="new_jenis" autocomplete="off"
                        class="w-full border border-gray-300 rounded px-3 py-2 focus:ring focus:ring-blue-200">
                </div>

                <script>
                    const jenisSelect = document.getElementById('jenis_id');
                    const newJenisInput = document.getElementById('new_jenis');

                    function toggleNewJenis() {
                        if (jenisSelect.value) {
                            newJenisInput.disabled = true;
                            newJenisInput.value = '';
                        } else {
                            newJenisInput.disabled = false;
                        }
                    }

                    toggleNewJenis();
                    jenisSelect.addEventListener('change', toggleNewJenis);
                </script>

                <div>
                    <label for="harga" class="block text-sm font-medium text-gray-700 mb-1">Harga</label>
                    <input type="text" name="harga" id="harga" inputmode="numeric" autocomplete="off"
                        class="block w-full px-4 py-2 text-sm border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition {{ $errors->has('harga') ? 'border-red-500' : 'border-gray-300' }}"
                        value="{{ old('harga') }}" placeholder="Masukkan harga (contoh: Rp 2.500.000)">
                    @error('harga')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <script>
                    document.getElementById('harga').addEventListener('input', function(e) {
                        let angka = this.value.replace(/[^\d]/g, '');
                        this.value = new Intl.NumberFormat('id-ID', {
                            style: 'currency',
                            currency: 'IDR',
                            minimumFractionDigits: 0
                        }).format(angka);
                    });
                </script>

                <div>
                    <label for="pemakaian" class="font-medium">Pemakaian</label>
                    <input type="number" name="pemakaian" autocomplete="off"
                        class="w-full border border-gray-300 rounded px-3 py-2 focus:ring focus:ring-blue-200" required>
                </div>

                <div>
                    <label for="status" class="font-medium">Status</label>
                    <select name="status"
                        class="w-full border border-gray-300 rounded px-3 py-2 focus:ring focus:ring-blue-200" required>
                        <option value="tersedia">Tersedia</option>
                        <option value="disewa">Disewa</option>
                        <option value="perawatan">Perawatan</option>
                    </select>
                </div>

                <div class="text-center">
                    <button type="submit"
                        class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg font-semibold shadow-md transition">
                        Simpan
                    </button>
                </div>
            </form>
        </div>
    </div>
@endsection
