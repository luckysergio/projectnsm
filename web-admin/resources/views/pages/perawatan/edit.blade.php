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

        <form action="{{ route('perawatan.update', $perawatan->id) }}" method="POST"
            class="bg-white p-6 rounded-xl shadow-md space-y-8">
            @csrf
            @method('PUT')

            <div>
                <label for="id_operator" class="block text-sm font-medium text-gray-700 mb-1">Operator</label>
                <select name="id_operator" id="id_operator" required
                    class="w-full border border-gray-300 px-4 py-2 rounded-lg focus:outline-none focus:ring focus:border-blue-500">
                    <option disabled selected value="">Pilih Operator</option>
                    @foreach ($operators as $operator)
                        <option value="{{ $operator->id }}"
                            {{ $operator->id == $perawatan->id_operator ? 'selected' : '' }}>
                            {{ $operator->nama }}
                        </option>
                    @endforeach
                </select>
            </div>

            @foreach ($perawatan->detailPerawatans as $index => $detail)
                <div class="bg-gray-50 p-5 rounded-xl border space-y-4 shadow-sm">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Alat</label>
                        <select name="details[{{ $index }}][id_alat]"
                            class="w-full border border-gray-300 rounded-lg px-4 py-2">
                            @foreach ($alatList as $alat)
                                <option value="{{ $alat->id }}" {{ $alat->id == $detail->id_alat ? 'selected' : '' }}>
                                    {{ $alat->nama }}
                                </option>
                            @endforeach
                        </select>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Tanggal Mulai</label>
                            <input type="date" name="details[{{ $index }}][tgl_mulai]"
                                value="{{ $detail->tgl_mulai }}" class="w-full border border-gray-300 rounded-lg px-4 py-2"
                                required>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Tanggal Selesai</label>
                            <input type="date" name="details[{{ $index }}][tgl_selesai]"
                                value="{{ $detail->tgl_selesai }}"
                                class="w-full border border-gray-300 rounded-lg px-4 py-2">
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
                        <select name="details[{{ $index }}][status]"
                            class="w-full border border-gray-300 rounded-lg px-4 py-2">
                            @foreach (['pending', 'proses', 'selesai'] as $status)
                                <option value="{{ $status }}" {{ $detail->status === $status ? 'selected' : '' }}>
                                    {{ ucfirst($status) }}
                                </option>
                            @endforeach
                        </select>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Catatan</label>
                        <textarea name="details[{{ $index }}][catatan]" rows="2"
                            class="w-full border border-gray-300 rounded-lg px-4 py-2">{{ $detail->catatan }}</textarea>
                    </div>
                </div>
            @endforeach

            <div class="text-center mt-6">
                <button type="submit"
                    class="bg-blue-600 text-white px-6 py-3 rounded-lg shadow hover:bg-blue-700 transition">
                    Simpan Perubahan
                </button>
            </div>
        </form>
    </div>
@endsection
