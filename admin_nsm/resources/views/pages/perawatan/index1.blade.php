@extends('layouts.app')

@section('title', 'Jadwal Perawatan Alat')

@section('content')
    <style>
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

        .maintenance-card {
            background: #ffffff;
            border-radius: 15px;
            box-shadow: 0 6px 25px rgba(0, 0, 0, 0.08);
            padding: 30px;
            transition: all 0.3s ease;
        }

        .maintenance-card:hover {
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.15);
            transform: translateY(-5px);
        }

        .card-title {
            background-color: #007bff;
            color: white;
            text-align: center;
            font-size: 20px;
            font-weight: 600;
            border-radius: 12px;
            padding: 12px;
            margin-bottom: 20px;
        }

        .maintenance-card p {
            font-size: 16px;
            line-height: 1.8;
            color: #444;
            margin-bottom: 8px;
        }

        .maintenance-card p strong {
            color: #222;
        }

        /* Styling for buttons */
        /* Styling untuk tombol */
        .action-btn,
        .delete-btn {
            color: #fff;
            border-radius: 50px;
            /* Menambahkan border-radius lebih besar untuk tampilan yang lebih halus */
            padding: 14px 30px;
            /* Memperbesar ukuran tombol agar lebih modern */
            font-weight: 600;
            text-decoration: none;
            width: 100%;
            /* Tombol akan memanfaatkan lebar penuh */
            text-align: center;
            margin-bottom: 15px;
            /* Memberikan jarak antara tombol */
            display: inline-block;
            /* Agar tombol tetap inline dengan text-center */
            text-transform: uppercase;
            /* Mengubah teks menjadi kapital */
            letter-spacing: 1px;
            /* Memberikan sedikit jarak antar huruf */
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            /* Menambahkan bayangan halus */
            transition: all 0.3s ease;
            /* Menambahkan transisi halus */
        }

        /* Tombol "Proses" */
        .action-btn {
            background-color: #007bff;
            border: 2px solid #007bff;
            /* Menambahkan border pada tombol */
        }

        /* Tombol "Reject" */
        .delete-btn {
            background-color: #dc3545;
            border: 2px solid #dc3545;
            /* Menambahkan border pada tombol */
        }

        /* Hover effect untuk tombol */
        .action-btn:hover {
            background-color: #0056b3;
            border-color: #0056b3;
            /* Mengubah border ketika hover */
            transform: translateY(-2px);
            /* Memberikan efek tombol terangkat */
            box-shadow: 0 6px 10px rgba(0, 0, 0, 0.15);
            /* Menambah efek bayangan */
        }

        /* Hover effect untuk tombol Reject */
        .delete-btn:hover {
            background-color: #c82333;
            border-color: #c82333;
            /* Mengubah border ketika hover */
            transform: translateY(-2px);
            /* Memberikan efek tombol terangkat */
            box-shadow: 0 6px 10px rgba(0, 0, 0, 0.15);
            /* Menambah efek bayangan */
        }

        /* Mengatur focus dan active untuk tombol */
        .action-btn:focus,
        .delete-btn:focus,
        .action-btn:active,
        .delete-btn:active {
            outline: none;
            /* Menghapus outline default */
            background-color: #007bff;
            /* Tetap dengan warna latar belakang asli saat fokus atau klik */
            border-color: #007bff;
            /* Tetap dengan warna border asli */
            color: #fff;
            /* Pastikan teks tetap putih */
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            /* Menambahkan bayangan halus saat tombol difokuskan */
        }

        /* Menyusun tombol secara vertikal dan di tengah */
        .button-container {
            display: flex;
            flex-direction: column;
            /* Mengubah arah menjadi kolom */
            justify-content: center;
            /* Menjaga tombol berada di tengah secara vertikal */
            align-items: center;
            /* Menjaga tombol berada di tengah secara horizontal */
            gap: 15px;
            /* Memberikan jarak yang lebih besar antara tombol */
            margin-top: 20px;
            /* Memberikan margin atas untuk ruang lebih */
        }

        /* Responsif untuk perangkat mobile */
        @media (max-width: 768px) {
            .order-card {
                padding: 20px;
            }

            .action-btn,
            .delete-btn {
                width: 100%;
                /* Tombol akan melebar 100% pada perangkat mobile */
                text-align: center;
                margin-bottom: 15px;
                /* Memberikan jarak antar tombol pada perangkat kecil */
            }
        }



        /* Posisi tombol 'Buat Jadwal' di pojok kanan bawah */
        .btn-create {
            position: fixed;
            bottom: 30px;
            right: 30px;
            background-color: #28a745;
            color: white;
            font-weight: 600;
            border-radius: 50px;
            padding: 15px 25px;
            font-size: 16px;
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
        }

        .btn-create:hover {
            background-color: #218838;
            transform: translateY(-2px);
        }

        @media (max-width: 768px) {
            .page-header {
                font-size: 24px;
                padding: 20px;
            }

            .maintenance-card {
                padding: 20px;
            }

            .maintenance-card p {
                font-size: 14px;
            }

            .action-btn {
                width: 100%;
                text-align: center;
            }

            .btn-custom {
                width: 100%;
                text-align: center;
            }
        }
    </style>

    <div class="container mt-5">
        <div class="page-header">
            Jadwal Perawatan Alat
        </div>

        <div class="row">
            @if (count($perawatan) < 1)
                <div class="col-12">
                    <div class="alert alert-info text-center">
                        Tidak ada data
                    </div>
                </div>
            @else
                @foreach ($perawatan as $item)
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="maintenance-card">
                            <div class="card-title">
                                <i class="fas fa-tools"></i> Perawatan #{{ $item->id }}
                            </div>
                            <p><strong>Nama Alat:</strong> {{ $item->inventori_name }}</p>
                            <p><strong>Status:</strong> {{ $item->status_perawatan }}</p>
                            <p><strong>Mulai:</strong> {{ \Carbon\Carbon::parse($item->tanggal_mulai)->format('d-m-y') }}</p>
                            <p><strong>Selesai:</strong> {{ \Carbon\Carbon::parse($item->tanggal_selesai)->format('d-m-y') }}</p>
                            <p><strong>Operator:</strong> {{ $item->operator_name }}</p>
                            <p><strong>Catatan:</strong> {{ $item->catatan }}</p>
                            <div class="text-end mt-4">
                                <a href="/perawatan/{{ $item->id }}" class="action-btn btn" role="button">
                                    <i class="fas fa-sync-alt"></i> PROSES
                                </a>
                            </div>
                        </div>
                    </div>
                @endforeach
            @endif
        </div>
    </div>

    <!-- Tombol Buat Jadwal -->
    <a href="/perawatan/create" class="btn-create btn" role="button">
        <i class="fas fa-calendar-plus"></i> Buat Jadwal
    </a>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

@endsection