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
                    window.location.href = "/karyawan";
                }
            });
        </script>
    @endif

    @if ($errors->any())
        <script>
            Swal.fire({
                icon: 'error',
                title: 'Gagal!',
                html: "{!! implode('<br>', $errors->all()) !!}"
            });
        </script>
    @endif

    <div class="max-w-xl mx-auto p-4">

        <form action="/karyawan/{{ $karyawan->id }}" method="POST" class="bg-white shadow-md rounded px-6 py-8 space-y-6">
            @csrf
            @method('PUT')

            <div>
                <label class="block text-sm font-medium mb-1">Nama</label>
                <input type="text" name="nama" value="{{ old('nama', $karyawan->nama) }}" placeholder="Nama lengkap"
                    class="w-full border border-gray-300 rounded px-4 py-2 focus:ring-blue-400 focus:outline-none">
                @error('nama')
                    <p class="text-red-500 text-sm">{{ $message }}</p>
                @enderror
            </div>

            <div>
                <label class="block text-sm font-medium mb-1">NIK</label>
                <input type="text" name="nik" value="{{ old('nik', $karyawan->nik) }}" placeholder="NIK karyawan"
                    class="w-full border border-gray-300 rounded px-4 py-2 focus:ring-blue-400 focus:outline-none">
                @error('nik')
                    <p class="text-red-500 text-sm">{{ $message }}</p>
                @enderror
            </div>

            <div>
                <label class="block text-sm font-medium mb-1">Email</label>
                <input type="email" name="email" value="{{ old('email', optional($karyawan->user)->email) }}"
                    placeholder="Contoh: example@mail.com"
                    class="w-full border border-gray-300 rounded px-4 py-2 focus:ring-blue-400 focus:outline-none">
                @error('email')
                    <p class="text-red-500 text-sm">{{ $message }}</p>
                @enderror
            </div>

            <div>
                <label class="block text-sm font-medium mb-1">Role</label>
                <select name="role_id"
                    class="w-full border border-gray-300 rounded px-4 py-2 focus:ring-blue-400 focus:outline-none">
                    @foreach ($roles as $role)
                        <option value="{{ $role->id }}"
                            {{ old('role_id', $karyawan->role_id) == $role->id ? 'selected' : '' }}>
                            {{ $role->jabatan }}
                        </option>
                    @endforeach
                </select>
                @error('role_id')
                    <p class="text-red-500 text-sm">{{ $message }}</p>
                @enderror
            </div>

            <div>
                <div class="relative">
                    <label class="block text-sm font-medium mb-1">Password Baru (optional)</label>
                    <input type="password" name="password" id="password"
                        class="w-full border border-gray-300 rounded px-4 py-2 pr-10 focus:ring-blue-400 focus:outline-none">
                    <button type="button" id="togglePassword"
                        class="absolute inset-y-0 right-3 flex items-center text-sm text-gray-500">
                        <div class="absolute right-3 top-9 cursor-pointer" onclick="togglePassword()">
                            <svg id="eyeIcon" class="h-5 w-5 text-gray-500" fill="none" stroke="currentColor"
                                viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.478 0-8.268-2.943-9.542-7z" />
                            </svg>
                        </div>
                    </button>
                    @error('password')
                        <p class="text-red-500 text-sm">{{ $message }}</p>
                    @enderror
                </div>
            </div>

            <div class="flex justify-center space-x-4">
                <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded font-semibold">
                    Update
                </button>
            </div>
        </form>
    </div>
@endsection

@push('scripts')
    <script>
        const togglePassword = document.querySelector("#togglePassword");
        const password = document.querySelector("#password");
        const eyeIcon = document.querySelector("#eyeIcon");

        togglePassword.addEventListener("click", function() {
            const type = password.getAttribute("type") === "password" ? "text" : "password";
            password.setAttribute("type", type);
            if (type === "text") {
                eyeIcon.innerHTML =
                    `<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.477 0-8.268-2.943-9.542-7a9.953 9.953 0 011.491-2.667M6.7 6.7l10.6 10.6m0 0a10.05 10.05 0 001.241-1.709M17.3 17.3L6.7 6.7" />`;
            } else {
                eyeIcon.innerHTML =
                    `<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.477 0 8.268 2.943 9.542 7-1.274 4.057-5.065 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />`;
            }
        });
    </script>
@endpush
