@extends('layouts.app')

@section('content')

    <!DOCTYPE html>
    <html lang="id">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Proses Order</title>
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
                Proses Order Masuk
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
                                            window.location.href = "/order";
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

                            <form action="/order/{{ $order->id }}" method="POST">
                                @csrf
                                @method('PUT')
                                <div class="mb-3">
                                    <label for="status_order" class="form-label">Status Order</label>
                                    <select class="form-select" id="status_order" name="status_order" required>
                                        <option value="" disabled>Status Order</option>
                                        <option value="diproses" {{ $order->status_order == 'diproses' ? 'selected' : '' }}>
                                            diproses</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="tgl_pemakaian" class="form-label">Tanggal Pengiriman</label>
                                    <input type="date" class="form-control" id="tgl_pemakaian" name="tgl_pemakaian"
                                        value="{{ old('tgl_pemakaian', $order->tgl_pemakaian ?? '') }}" required>
                                </div>

                                <div class="mb-3">
                                    <label for="jam_mulai" class="form-label">Jam Mulai</label>
                                    <input type="time" class="form-control" id="jam_mulai" name="jam_mulai"
                                        value="{{ old('jam_mulai', date('H:i', strtotime($order->jam_mulai))) }}">
                                </div>

                                <div class="mb-3">
                                    <label for="jam_selesai" class="form-label">Jam Selesai</label>
                                    <input type="time" class="form-control" id="jam_selesai" name="jam_selesai"
                                        value="{{ old('jam_selesai', $order->jam_selesai ?? '') }}" required>
                                </div>

                                <div class="mb-3">
                                    <label for="catatan" class="form-label">Catatan</label>
                                    <textarea class="form-control" id="catatan" name="catatan"
                                        rows="3">{{ old('catatan', $order->catatan) }}</textarea>
                                </div>

                                <div class="d-flex justify-content-between">
                                    <a href="/order" class="btn btn-secondary">Kembali</a>
                                    <button type="submit" class="btn btn-primary">Proses order</button>
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