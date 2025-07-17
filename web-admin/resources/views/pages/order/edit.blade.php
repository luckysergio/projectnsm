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

    <div class="max-w-4xl mx-auto p-2">
        <form action="{{ route('order.proses', $order->id) }}" method="POST" class="space-y-8">
            @csrf
            @method('PUT')

            @foreach ($order->detailOrders as $i => $detail)
                <div class="border border-gray-200 p-4 rounded-2xl shadow-sm bg-white space-y-4">
                    <input type="hidden" name="detail[{{ $i }}][id_detail]" value="{{ $detail->id }}">

                    <div>
                        <label class="font-medium">Alat</label>
                        <select name="detail[{{ $i }}][id_alat]"
                            class="w-full border rounded px-3 py-2 select-alat" data-index="{{ $i }}">
                            @foreach ($inventories as $alat)
                                <option value="{{ $alat->id }}" data-harga="{{ $alat->harga }}"
                                    {{ $detail->id_alat == $alat->id ? 'selected' : '' }}>
                                    {{ $alat->nama }}
                                </option>
                            @endforeach
                        </select>
                    </div>

                    <div>
                        <label class="font-medium">Status</label>
                        <select name="detail[{{ $i }}][status]" class="w-full border rounded px-3 py-2" required>
                            <option value="proses" {{ $detail->status == 'proses' ? 'selected' : '' }}>Proses</option>
                            <option value="persiapan" {{ $detail->status == 'persiapan' ? 'selected' : '' }}>Persiapan
                            </option>
                            <option value="dikirim" {{ $detail->status == 'dikirim' ? 'selected' : '' }}>Dikirim</option>
                            <option value="selesai" {{ $detail->status == 'selesai' ? 'selected' : '' }}>Selesai</option>
                        </select>
                    </div>

                    <div>
                        <label class="font-medium">Alamat</label>
                        <input type="text" name="detail[{{ $i }}][alamat]" value="{{ $detail->alamat }}"
                            class="w-full border rounded px-3 py-2" required>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="font-medium">Tanggal Mulai</label>
                            <input type="date" name="detail[{{ $i }}][tgl_mulai]"
                                value="{{ $detail->tgl_mulai }}" class="w-full border rounded px-3 py-2" required>
                        </div>
                        <div>
                            <label class="font-medium">Jam Mulai</label>
                            <input type="time" name="detail[{{ $i }}][jam_mulai]"
                                value="{{ $detail->jam_mulai }}" class="w-full border rounded px-3 py-2" required>
                        </div>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="font-medium">Tanggal Selesai</label>
                            <input type="date" name="detail[{{ $i }}][tgl_selesai]"
                                value="{{ $detail->tgl_selesai }}" class="w-full border rounded px-3 py-2">
                        </div>
                        <div>
                            <label class="font-medium">Jam Selesai</label>
                            <input type="time" name="detail[{{ $i }}][jam_selesai]"
                                value="{{ $detail->jam_selesai }}" class="w-full border rounded px-3 py-2">
                        </div>
                    </div>

                    <div>
                        <label class="font-medium">Harga Sewa</label>
                        <input type="text" id="harga_sewa_display_{{ $i }}" readonly
                            class="block w-full px-4 py-2 text-sm border rounded-lg bg-gray-100 shadow-sm"
                            value="{{ number_format($detail->harga_sewa, 0, ',', '.') }}">

                        <input type="hidden" name="detail[{{ $i }}][harga_sewa]"
                            id="harga_sewa_{{ $i }}" value="{{ $detail->harga_sewa }}">
                    </div>

                    <div>
                        <label class="font-medium">Total Sewa (Hari)</label>
                        <input type="number" name="detail[{{ $i }}][total_sewa]"
                            value="{{ $detail->total_sewa }}" class="w-full border rounded px-3 py-2 input-total-sewa"
                            data-index="{{ $i }}" required>
                    </div>

                    <div>
                        <label class="font-medium">Catatan</label>
                        <textarea name="detail[{{ $i }}][catatan]" class="w-full border rounded px-3 py-2">{{ $detail->catatan }}</textarea>
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

@push('scripts')
    <script>
        document.addEventListener("DOMContentLoaded", () => {
            function updateHargaSewa(index) {
                const select = document.querySelector(`.select-alat[data-index="${index}"]`);
                const totalSewaInput = document.querySelector(`.input-total-sewa[data-index="${index}"]`);
                const hargaSewaHidden = document.querySelector(`#harga_sewa_${index}`);
                const hargaSewaDisplay = document.querySelector(`#harga_sewa_display_${index}`);

                const selectedOption = select.options[select.selectedIndex];
                const hargaAlat = parseInt(selectedOption.dataset.harga || 0);
                const totalSewa = parseInt(totalSewaInput.value || 0);

                const totalHargaSewa = hargaAlat * totalSewa;

                hargaSewaHidden.value = totalHargaSewa;
                hargaSewaDisplay.value = formatRupiah(totalHargaSewa);

                updateTotalTagihan();
            }

            function formatRupiah(angka) {
                return angka.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
            }

            function updateTotalTagihan() {
                let total = 0;
                document.querySelectorAll('[id^="harga_sewa_"]').forEach(input => {
                    total += parseInt(input.value || 0);
                });
                document.getElementById('total_tagihan').textContent = 'Rp ' + formatRupiah(total);
            }


            document.querySelectorAll('.select-alat').forEach(select => {
                const index = select.dataset.index;
                select.addEventListener('change', () => updateHargaSewa(index));
            });

            document.querySelectorAll('.input-total-sewa').forEach(input => {
                const index = input.dataset.index;
                input.addEventListener('input', () => updateHargaSewa(index));
            });

            // Hitung total saat awal load
            document.querySelectorAll('.select-alat').forEach(select => {
                const index = select.dataset.index;
                updateHargaSewa(index);
            });
        });
    </script>
@endpush
