@extends('layouts.app')

@section('content')

<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ubah Data User</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.15/dist/sweetalert2.min.css" rel="stylesheet">

    <style>
        /* Style Header */
        .page-header {
        background: linear-gradient(145deg, #007bff, #00c6ff);
        color: white;
        padding: 25px 30px;
        border-radius: 15px;
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        text-align: center;
        font-size: 32px;
        font-weight: 700;
        margin-bottom: 40px;
    }

        /* Style Tombol */
        .btn-custom {
            background: #28a745;
            color: white;
            transition: 0.3s;
        }

        .btn-custom:hover {
            background: #218838;
        }

        .btn-secondary {
            background: #6c757d;
            color: white;
        }

        /* Style Form */
        .card-custom {
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }

        .input-group-text {
            cursor: pointer;
        }
    </style>
</head>

<body>

    <div class="container mt-4">
        <div class="page-header">
            <h1 class="h3 mb-0">Ubah Data User</h1>
        </div>

        <div class="row mt-4">
            <div class="col-md-6 offset-md-3">
                <div class="card card-custom shadow-lg">
                    <div class="card-body">

                        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.15/dist/sweetalert2.all.min.js"></script>

                    @if(session('success'))
                        <script>
                            Swal.fire({
                                icon: 'success',
                                title: 'Berhasil!',
                                text: @json(session('success')),
                                didClose: () => {
                                    window.location.href = "/user";
                                }
                            });
                        </script>
                    @endif

                    @if($errors->any())
                        <script>
                            Swal.fire({
                                icon: 'error',
                                title: 'Gagal!',
                                html: "{!! implode('<br>', $errors->all()) !!}"
                            });
                        </script>
                    @endif

                        <form action="/user/{{ $user->id }}" method="POST">
                            @csrf
                            @method('PUT')

                            <div class="mb-3">
                                <label for="name" class="form-label">Nama Lengkap</label>
                                <input type="text" class="form-control" id="name" name="name" value="{{ old('name', $user->name) }}">
                            </div>

                            <div class="mb-3">
                                <label for="nik" class="form-label">Nomor Induk Karyawan</label>
                                <input type="text" class="form-control" id="nik" name="nik" value="{{ old('nik', $user->nik) }}">
                            </div>

                            <div class="mb-3">
                                <label for="role" class="form-label">Jabatan</label>
                                <select class="form-select" id="role" name="role" required>
                                    <option value="" disabled>Pilih Jabatan</option>
                                    <option value="admin" {{ $user->role == 'admin' ? 'selected' : '' }}>Admin</option>
                                    <option value="sales" {{ $user->role == 'sales' ? 'selected' : '' }}>Sales</option>
                                    <option value="pj_alat" {{ $user->role == 'pj_alat' ? 'selected' : '' }}>Penanggung Jawab Alat</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label for="email" class="form-label">Email</label>
                                <input type="email" class="form-control" id="email" name="email" value="{{ old('email', $user->email) }}">
                            </div>

                            <div class="mb-3">
                                <label for="password" class="form-label">Password (Opsional)</label>
                                <div class="input-group">
                                    <input type="password" class="form-control" id="password" name="password" placeholder="Biarkan kosong jika tidak ingin mengubah password">
                                    <span class="input-group-text" onclick="togglePassword('password', 'togglePasswordIcon')">
                                        <i id="togglePasswordIcon" class="fas fa-eye-slash"></i>
                                    </span>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="password_confirmation" class="form-label">Konfirmasi Password</label>
                                <div class="input-group">
                                    <input type="password" class="form-control" id="password_confirmation" name="password_confirmation">
                                    <span class="input-group-text" onclick="togglePassword('password_confirmation', 'toggleConfirmIcon')">
                                        <i id="toggleConfirmIcon" class="fas fa-eye-slash"></i>
                                    </span>
                                </div>
                            </div>

                            <div class="d-flex justify-content-between">
                                <a href="/user" class="btn btn-secondary">Kembali</a>
                                <button type="submit" class="btn btn-warning">Simpan Perubahan</button>
                            </div>

                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function togglePassword(inputId, iconId) {
            var input = document.getElementById(inputId);
            var icon = document.getElementById(iconId);
            if (input.type === "password") {
                input.type = "text";
                icon.classList.remove("fa-eye-slash");
                icon.classList.add("fa-eye");
            } else {
                input.type = "password";
                icon.classList.remove("fa-eye");
                icon.classList.add("fa-eye-slash");
            }
        }
    </script>

</body>

</html>

@endsection
