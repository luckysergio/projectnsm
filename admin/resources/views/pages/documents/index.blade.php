@extends('layouts.app')

@section('title', 'Data Dokumentasi')

@section('content')
    <style>
        .card-custom {
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
            background-color: #ffffff;
            overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .card-custom:hover {
            transform: translateY(-8px);
            /* Efek hover */
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.2);
        }

        .card-header {
            background-color: #007bff;
            color: white;
            text-transform: uppercase;
            font-weight: bold;
            padding: 15px;
            border-radius: 15px 15px 0 0;
            text-align: center;
        }

        .card-body {
            padding: 20px;
        }

        .card img {
            border-radius: 8px;
            width: 100%;
            height: auto;
            margin-bottom: 10px;
            transition: transform 0.3s ease;
        }

        .card img:hover {
            transform: scale(1.05);
            /* Efek zoom saat gambar di-hover */
        }

        .card-footer {
            background-color: #f1f1f1;
            border-radius: 0 0 15px 15px;
            padding: 10px;
            text-align: center;
            font-size: 0.875rem;
        }

        .badge-status {
            font-size: 14px;
            padding: 6px 10px;
            border-radius: 6px;
        }

        .badge-tersedia {
            background-color: #28a745;
            color: white;
        }

        .badge-dipinjam {
            background-color: #ffc107;
            color: black;
        }

        /* Gallery Styling */
        .gallery {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            justify-content: space-between;
        }

        .gallery a {
            width: calc(33.333% - 10px);
        }

        .gallery a img {
            border-radius: 8px;
        }

        /* Header Styling */
        .page-header {
            background: linear-gradient(145deg, #007bff, #00c6ff);
            color: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            text-align: center;
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 30px;
        }

        /* Card adjustments on smaller screens */
        @media (max-width: 768px) {
            .gallery a {
                width: calc(50% - 10px);
                /* 2 gambar per baris pada layar kecil */
            }
        }

        @media (max-width: 480px) {
            .gallery a {
                width: 100%;
                /* Gambar menjadi penuh pada layar sangat kecil */
            }
        }

        .search-box {
            display: flex;
            align-items: center;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
            margin-top: 15px;
            max-width: 500px;
            margin-left: auto;
            margin-right: auto;
        }

        .search-box input {
            border: none;
            padding: 10px;
            width: 100%;
            outline: none;
        }

        .search-box button {
            border: none;
            background: #007bff;
            padding: 10px 15px;
            cursor: pointer;
            transition: 0.3s;
            color: white;
        }

        .search-box button:hover {
            background: #0056b3;
        }
    </style>

    <div class="container mt-5">
        <div class="page-header">
            <h1>Dokumentasi Order</h1>
        </div>

        <form action="{{ url('/search') }}" method="GET" class="search-box">
            <input type="text" name="search" placeholder="Cari nama pemesan..." value="{{ request('search') }}">
            <button type="submit">
                <i class="fas fa-search"></i>
            </button>
        </form>

        <!-- Display Dokumentasi -->
        <div class="row mt-5">
            @if ($documents->isEmpty())
                <div class="col-12 text-center">
                    <p class="lead">Tidak ada dokumentasi yang tersedia.</p>
                </div>
            @else
                @foreach ($documents as $key => $document)
                    <div class="col-12 col-md-6 col-lg-4 mb-4">
                        <!-- Menampilkan setiap order dalam card -->
                        <div class="card card-custom">
                            <div class="card-header">
                                <h5>ID Dokumentasi #{{ $document->id }}</h5>
                            </div>
                            <div class="card-body">
                                <h6 class="card-title text-center">Nama Pemesan: {{ $document->order->nama_pemesan }}</h6>
                                <div class="gallery">
                                    @foreach (json_decode($document->photo, true) ?? [] as $photo)
                                        <a href="{{ asset('storage/' . $photo) }}" target="_blank">
                                            <img src="{{ asset('storage/' . $photo) }}" alt="Foto Dokumentasi" class="img-fluid">
                                        </a>
                                    @endforeach
                                </div>
                                <p class="mt-3 text-center"><strong>Catatan:</strong> {{ $document->note }}</p>
                            </div>
                            <div class="card-footer">
                                <small class="text-muted">Tanggal Upload: {{ $document->created_at->format('d M Y') }}</small>
                            </div>
                        </div>
                    </div>
                @endforeach
            @endif
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
@endsection