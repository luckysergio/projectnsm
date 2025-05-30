@extends('layouts.app')

@section('content')
    <!DOCTYPE html>
    <html lang="id">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Buat jadwal perawatan alat</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
        <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.15/dist/sweetalert2.min.css" rel="stylesheet">

        <style>
            /* Style Header */
            .page-header {
                background: linear-gradient(135deg, #007bff, #00c6ff);
                color: white;
                padding: 15px 20px;
                border-radius: 10px;
                box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
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

            .page-header {
                background: linear-gradient(135deg, #007bff, #00c6ff);
                color: white;
                padding: 20px;
                border-radius: 12px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
                text-align: center;
                font-size: 28px;
                font-weight: 700;
                margin-bottom: 30px;
            }
        </style>
    </head>

    <body>

        <div class="container mt-4">
            <div class="page-header">
                Buat Jadwal perawatan alat
            </div>

            <div class="row mt-4">
                <div class="col-md-6 offset-md-3">
                    <div class="card card-custom shadow-lg">
                        <div class="card-body">

                            <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.15/dist/sweetalert2.all.min.js"></script>

                            @if (session('success'))
                                <script>
                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Berhasil!',
                                        text: @json(session('success')),
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
                                        title: 'Gagal!',
                                        html: `{!! implode('<br>', $errors->all()) !!}`
                                    });
                                </script>
                            @endif

                            <form action="/perawatan" method="POST">
                                @csrf
                                @method('POST')

                                <div class="mb-3">
                                    <label for="inventori_id" class="form-label">Nama Alat</label>
                                    <select class="form-select" id="inventori_id" name="inventori_id" required>
                                        <option value="" disabled selected>Pilih Alat</option>
                                        @foreach ($inventori as $inventory)
                                            <option value="{{ $inventory->id }}"
                                                {{ old('inventori_id') == $inventory->id ? 'selected' : '' }}>
                                                {{ $inventory->nama_alat }}
                                            </option>
                                        @endforeach
                                    </select>
                                </div>

                                <div class="mb-3">
                                    <label for="tanggal_mulai" class="form-label">Tanggal Mulai Perawatan</label>
                                    <input type="date" class="form-control" id="tanggal_mulai" name="tanggal_mulai"
                                        value="{{ old('tanggal_mulai') }}" required>
                                </div>

                                <div class="mb-3">
                                    <label for="tanggal_selesai" class="form-label">Tanggal Selesai</label>
                                    <input type="date" class="form-control" id="tanggal_selesai" name="tanggal_selesai"
                                        value="{{ old('tanggal_selesai') }}">
                                </div>

                                <div class="mb-3">
                                    <label for="status_perawatan" class="form-label">Status Perawatan</label>
                                    <select class="form-select" id="status_perawatan" name="status_perawatan" required>
                                        <option value="pending"
                                            {{ old('status_perawatan') == 'pending' ? 'selected' : '' }}>Pending</option>
                                        <option value="proses" {{ old('status_perawatan') == 'proses' ? 'selected' : '' }}>
                                            Proses</option>
                                        <option value="selesai"
                                            {{ old('status_perawatan') == 'selesai' ? 'selected' : '' }}>Selesai</option>
                                    </select>
                                </div>

                                <div class="mb-3">
                                    <label for="operator_name" class="form-label">Operator Perawatan</label>
                                    <input type="text" class="form-control" id="operator_name" name="operator_name"
                                        value="{{ old('operator_name') }}">
                                </div>

                                <div class="mb-3">
                                    <label for="catatan" class="form-label">Catatan</label>
                                    <textarea class="form-control" id="catatan" name="catatan" rows="3">{{ old('catatan') }}</textarea>
                                </div>

                                <div class="d-flex justify-content-between">
                                    <a href="/perawatan" class="btn btn-secondary">Kembali</a>
                                    <button type="submit" class="btn btn-primary">Simpan Jadwal</button>
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
