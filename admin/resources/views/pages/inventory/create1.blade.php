@extends('layouts.app')

@section('content')
    <!DOCTYPE html>
    <html lang="id">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Tambah Alat</title>
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
                <h1 class="h3 mb-0">Tambah Data Alat</h1>
            </div>

            <div class="row mt-4">
                <div class="col-md-6 offset-md-3">
                    <div class="card card-custom shadow-lg">
                        <div class="card-body">

                            <script
                                src="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.15/dist/sweetalert2.all.min.js"></script>

                            @if(session('success'))
                                <script>
                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Berhasil!',
                                        text: @json(session('success')),
                                        didClose: () => {
                                            window.location.href = "/Inventory";
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

                            <form action="/Inventory" method="POST">
                                @csrf
                                @method('POST')
                                <div class="mb-3">
                                    <label for="nama_alat" class="form-label">Nama Alat</label>
                                    <input type="text" class="form-control" id="nama_alat" name="nama_alat"
                                        placeholder="Masukkan Nama Alat" required>
                                </div>
                                <div class="mb-3">
                                    <label for="jenis_alat" class="form-label">Jenis Alat</label>
                                    <select class="form-select" id="jenis_alat" name="jenis_alat" required>
                                        <option value="" disabled selected>Pilih Jenis Alat</option>
                                        <option value="pompa_standart">Pompa Standart</option>
                                        <option value="pompa_mini">Pompa Mini</option>
                                        <option value="pompa_longboom">Pompa LongBoom</option>
                                        <option value="pompa_superlong">Pompa SuperLong</option>
                                        <option value="pompa_kodok">Pompa Kodok</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="status" class="form-label">Status Alat</label>
                                    <select class="form-select" id="status" name="status" required>
                                        <option value="tersedia">Tersedia</option>
                                        <option value="sedang_disewa">Sedang DiSewa</option>
                                        <option value="sedang_perawatan">Sedang Perawatan</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="waktu_pemakaian" class="form-label">Waktu Pemakaian (Jam)</label>
                                    <input type="number" class="form-control" id="waktu_pemakaian" name="waktu_pemakaian"
                                        placeholder="Masukkan Waktu Pemakaian" required>
                                </div>
                                <div class="mb-3">
                                    <label for="harga" class="form-label">Harga sewa (Jam)</label>
                                    <input type="number" class="form-control" id="harga" name="harga"
                                        placeholder="Masukkan harga sewa per hari" required>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <a href="/Inventory" class="btn btn-secondary">Kembali</a>
                                    <button type="submit" class="btn btn-primary">Simpan</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </body>

    </html>

@endsection