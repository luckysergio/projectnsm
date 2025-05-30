@extends('layouts.app')

@section('content')
<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tambah Data User</title>
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
    </style>
</head>

<body>
    <div class="container mt-4">
        <div class="page-header">
            <h1 class="h3 mb-0">Tambah Data User</h1>
        </div>
        <div class="container mt-4">
            <div class="card shadow-lg mx-auto" style="max-width: 500px; border-radius: 10px;">
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

                    <form action="/register" method="POST">
                        @csrf
                        @method('POST')
                    
                        <div class="mb-3">
                            <label for="name" class="form-label">Nama Lengkap</label>
                            <input type="text" class="form-control @error('name') is-invalid @enderror" id="name" name="name" placeholder="Masukkan Nama Lengkap">
                            @error('name')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    
                        <div class="mb-3">
                            <label for="nik" class="form-label">Nomor Induk Karyawan (NIK)</label>
                            <input type="text" class="form-control @error('nik') is-invalid @enderror" id="nik" name="nik" placeholder="Masukkan NIK">
                            @error('nik')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    
                        <div class="mb-3">
                            <label for="role" class="form-label">Jabatan</label>
                            <select class="form-select @error('role') is-invalid @enderror" id="role" name="role">
                                <option value="" selected>Pilih Jabatan</option>
                                <option value="admin">Admin</option>
                                <option value="sales">Sales</option>
                                <option value="pj_alat">Penanggung Jawab Alat</option>
                            </select>
                            @error('role')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    
                        <div class="mb-3">
                            <label for="email" class="form-label">Email</label>
                            <input type="email" class="form-control @error('email') is-invalid @enderror" id="email" name="email" placeholder="Masukkan Email">
                            @error('email')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    
                        <div class="mb-3">
                            <label for="password" class="form-label">Password</label>
                            <div class="input-group">
                                <input type="password" class="form-control @error('password') is-invalid @enderror" id="password" name="password" placeholder="password">
                                <span class="input-group-text" onclick="togglePassword('password', 'togglePasswordIcon')">
                                    <i id="togglePasswordIcon" class="fas fa-eye-slash"></i>
                                </span>
                            </div>
                            @error('password')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    
                        <div class="mb-3">
                            <label for="password_confirmation" class="form-label">Konfirmasi Password</label>
                            <div class="input-group">
                                <input type="password" class="form-control @error('password_confirmation') is-invalid @enderror" id="password_confirmation" name="password_confirmation" placeholder="konfirmasi password">
                                <span class="input-group-text" onclick="togglePassword('password_confirmation', 'toggleConfirmIcon')">
                                    <i id="toggleConfirmIcon" class="fas fa-eye-slash"></i>
                                </span>
                            </div>
                            @error('password_confirmation')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    
                        <div class="d-flex justify-content-between">
                            <a href="/user" class="btn btn-secondary">Kembali</a>
                            <button type="submit" class="btn btn-primary">Simpan</button>
                        </div>
                    </form>
                    
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

@endsection
