@extends('layouts.app')

@section('content')
    {{-- SweetAlert2 --}}
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.15/dist/sweetalert2.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.15/dist/sweetalert2.all.min.js"></script>

    {{-- Alert Success/Error --}}
    @if (session('success'))
        <script>
            Swal.fire({
                icon: 'success',
                title: 'Berhasil!',
                text: @json(session('success')),
                confirmButtonColor: '#2563eb',
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

    <div class="container mx-auto p-4">
        <div class="mb-6">
            <button onclick="openModal('jenis')" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded shadow">
                + Tambah Jenis Alat
            </button>
        </div>

        <div class="overflow-x-auto bg-white shadow-lg rounded-xl">
            <table class="min-w-full text-sm text-left">
                <thead class="bg-blue-600 text-white">
                    <tr>
                        <th class="px-6 py-3 text-center">#</th>
                        <th class="px-6 py-3 text-center">Nama Jenis</th>
                        <th class="px-6 py-3 text-center">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 bg-white">
                    @foreach ($jenis as $index => $item)
                        <tr class="hover:bg-gray-50 transition duration-200">
                            <td class="px-6 py-4 text-center">{{ $index + 1 }}</td>
                            <td class="px-6 py-4 text-center">{{ $item->nama }}</td>
                            <td class="px-6 py-4 text-center space-x-2">
                                <button onclick="openEditModal('jenis', {{ $item->id }}, '{{ $item->nama }}')"
                                    class="text-yellow-500 hover:text-yellow-600 transition" title="Edit">✏️</button>
                                <button type="button"
                                    class="text-red-500 hover:text-red-600 transition delete-button"
                                    data-type="jenis" data-id="{{ $item->id }}" title="Hapus">🗑️</button>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>

    {{-- Modal Form --}}
    <div id="modalForm"
        class="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center invisible opacity-0 pointer-events-none transition-opacity duration-300">
        <div class="bg-white rounded-lg p-6 w-full max-w-md shadow-xl">
            <h2 id="modalTitle" class="text-lg font-semibold mb-4">Tambah Data</h2>
            <form id="modalFormElement" method="POST" action="{{ route('data.store') }}">
                @csrf
                <input type="hidden" id="typeInput" name="type" value="jenis">
                <input type="hidden" id="editId">
                <div class="mb-4">
                    <label class="block text-sm font-medium mb-1">Nama</label>
                    <input type="text" name="nama" id="namaInput"
                        class="w-full border border-gray-300 rounded px-4 py-2 focus:ring-blue-500 focus:outline-none"
                        required>
                </div>
                <div class="flex justify-end gap-2">
                    <button type="button" onclick="closeModal()"
                        class="bg-gray-300 hover:bg-gray-400 text-gray-800 px-4 py-2 rounded">Batal</button>
                    <button type="submit"
                        class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">Simpan</button>
                </div>
            </form>
        </div>
    </div>

    {{-- Form Hapus --}}
    <form id="delete-form" method="POST" class="hidden">
        @csrf
        @method('DELETE')
    </form>

    {{-- Script Modal & Hapus --}}
    <script>
        function openModal(type) {
            document.getElementById('modalTitle').innerText = 'Tambah ' + (type === 'jabatan' ? 'Jabatan' : 'Jenis Alat');
            document.getElementById('typeInput').value = type;
            document.getElementById('namaInput').value = '';
            document.getElementById('modalFormElement').action = "{{ route('data.store') }}";

            const modal = document.getElementById('modalForm');
            modal.classList.remove('invisible', 'opacity-0', 'pointer-events-none');
            modal.classList.add('visible', 'opacity-100');
        }

        function openEditModal(type, id, nama) {
            document.getElementById('modalTitle').innerText = 'Edit ' + (type === 'jabatan' ? 'Jabatan' : 'Jenis Alat');
            document.getElementById('typeInput').value = type;
            document.getElementById('namaInput').value = nama;
            document.getElementById('modalFormElement').action = `/data/${type}/${id}`;

            let methodInput = document.querySelector('#modalFormElement input[name="_method"]');
            if (!methodInput) {
                methodInput = document.createElement('input');
                methodInput.type = 'hidden';
                methodInput.name = '_method';
                methodInput.value = 'PUT';
                document.getElementById('modalFormElement').appendChild(methodInput);
            }

            const modal = document.getElementById('modalForm');
            modal.classList.remove('invisible', 'opacity-0', 'pointer-events-none');
            modal.classList.add('visible', 'opacity-100');
        }

        function closeModal() {
            const modal = document.getElementById('modalForm');
            modal.classList.add('invisible', 'opacity-0', 'pointer-events-none');
            modal.classList.remove('visible', 'opacity-100');

            const methodInput = document.querySelector('#modalFormElement input[name="_method"]');
            if (methodInput) methodInput.remove();
        }

        document.querySelectorAll('.delete-button').forEach(button => {
            button.addEventListener('click', function () {
                const id = this.dataset.id;
                const type = this.dataset.type;
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
                        form.action = `/data/${type}/${id}`;
                        form.submit();
                    }
                });
            });
        });
    </script>
@endsection
