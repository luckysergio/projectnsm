@extends('layouts.app')

@section('content')
    <!DOCTYPE html>
    <html lang="id">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Histori Perawatan</title>

        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

        <!-- Font Awesome -->
        <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>

        <!-- Google Fonts -->
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">

        <style>
            /* Global Styles */
            body {
                font-family: 'Poppins', sans-serif;
                background-color: #f4f7fb;
                margin: 0;
                padding: 0;
            }

            /* Header Styling */
            .page-header {
                background: linear-gradient(135deg, #007bff, #0056b3);
                color: white;
                padding: 30px 20px;
                border-radius: 12px;
                box-shadow: 0 6px 15px rgba(0, 0, 0, 0.1);
                text-align: center;
            }

            .page-header h1 {
                font-size: 2.5rem;
                margin: 0;
            }

            /* Search Box Styling */
            .search-form {
                max-width: 800px;
                margin: 30px auto;
            }

            .input-group {
                box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
                border-radius: 12px;
                overflow: hidden;
            }

            .input-group input,
            .input-group select {
                border: none;
                padding: 12px;
                font-size: 1rem;
                background: #f8f9fa;
            }

            .input-group input:focus,
            .input-group select:focus {
                background: #ffffff;
                box-shadow: none;
            }

            .input-group .btn {
                padding: 0 20px;
                background: linear-gradient(135deg, #007bff, #0056b3);
                border: none;
                transition: background 0.3s ease;
            }

            .input-group .btn:hover {
                background: linear-gradient(135deg, #0056b3, #003f7f);
            }

            .filter-form {
                max-width: 800px;
                margin: 30px auto;
            }

            .filter-form .form-select,
            .filter-form .btn {
                padding: 12px 16px;
                border-radius: 8px;
                font-size: 1rem;
            }

            .filter-form .btn {
                background: linear-gradient(135deg, #007bff, #0056b3);
                border: none;
                transition: background 0.3s ease;
            }

            .filter-form .btn:hover {
                background: linear-gradient(135deg, #0056b3, #004080);
            }

            /* Card Styling */
            .card-custom {
                border-radius: 12px;
                box-shadow: 0 6px 15px rgba(0, 0, 0, 0.1);
                overflow: hidden;
                transition: transform 0.3s ease, box-shadow 0.3s ease;
            }

            .card-custom:hover {
                transform: translateY(-10px);
                box-shadow: 0 12px 24px rgba(0, 0, 0, 0.2);
            }

            .card-custom .card-header {
                background: linear-gradient(135deg, #007bff, #0056b3);
                color: white;
                font-weight: bold;
                padding: 20px;
                text-align: center;
            }

            .card-body {
                background-color: #fff;
                padding: 20px;
                font-size: 1rem;
            }

            .card-footer {
                background-color: #f8f9fa;
                padding: 15px;
                text-align: center;
            }

            .badge-status {
                padding: 5px 15px;
                border-radius: 20px;
                font-size: 0.9rem;
            }

            .badge-success {
                background-color: #28a745;
            }

            .badge-warning {
                background-color: #ffc107;
            }

            .badge-danger {
                background-color: #dc3545;
            }

            /* Modal Styling */
            .modal-header {
                background-color: #007bff;
                color: white;
                border-bottom: 2px solid #0056b3;
            }

            .modal-footer {
                text-align: center;
            }

            .modal-body .card-body {
                font-size: 1rem;
            }

            /* Responsive Styles */
            @media (max-width: 768px) {
                .card-custom {
                    margin-bottom: 20px;
                }

                .page-header {
                    padding: 20px;
                }

                .search-box {
                    width: 90%;
                }
            }
        </style>
    </head>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <body>

        <div class="container mt-4">
            <!-- Header -->
            <div class="page-header">
                <h1 class="h3 mb-0">Data Perawatan alat</h1>
            </div>
            <form action="{{ url('/historiperawatan') }}" method="GET" class="filter-form">
                <div class="row g-2 align-items-center justify-content-center">
                    <div class="col-md-4">
                        <select name="bulan" class="form-select">
                            <option value="">Pilih Bulan</option>
                            @for ($i = 1; $i <= 12; $i++)
                                <option value="{{ $i }}" {{ request('bulan') == $i ? 'selected' : '' }}>
                                    {{ DateTime::createFromFormat('!m', $i)->format('F') }}
                                </option>
                            @endfor
                        </select>
                    </div>

                    <div class="col-md-4">
                        <select name="tahun" class="form-select">
                            <option value="">Pilih Tahun</option>
                            @for ($i = date('Y'); $i <= 2030; $i++)
                                <option value="{{ $i }}" {{ request('tahun') == $i ? 'selected' : '' }}>
                                    {{ $i }}</option>
                            @endfor
                        </select>
                    </div>

                    <div class="col-md-2">
                        <button class="btn btn-primary w-100" type="submit">
                            <i class="fas fa-search"></i> Filter
                        </button>
                    </div>
                </div>
            </form>

            @if (isset($totalPerawatan))
                <div class="alert alert-info text-center mt-3">
                    Total Perawatan : <strong>{{ $totalPerawatan }}</strong> Perawatan
                </div>
            @endif

            @if ($totalPerawatan > 0)
                <div class="text-center mb-3">
                    <a href="{{ route('perawatan.exportPdf', request()->all()) }}" class="btn btn-danger">
                        <i class="fas fa-file-pdf"></i> Cetak laporan perawatan
                    </a>
                </div>
            @endif

            <!-- Card Display for Orders -->
            <div class="row mt-4">
                @if (count($perawatan) < 1)
                    <div class="col-12">
                        <div class="alert alert-warning text-center">
                            Tidak ada data
                        </div>
                    </div>
                @else
                    @foreach ($perawatan as $item)
                        <div class="col-md-4 mb-4">
                            <div class="card card-custom">
                                <div class="card-header">
                                    <h5 class="card-title"><strong>ID Perawatan </strong>{{ $item->id }}</h5>
                                </div>
                                <div class="card-body">
                                    <p class="card-text"><strong>Operator:</strong> {{ $item->operator_name }}</p>
                                    <p class="card-text"><strong>Alat:</strong> {{ $item->inventori_name }}</p>
                                    <p class="card-text"><strong>Status Perawatan:</strong>
                                        <span
                                            class="badge badge-status {{ $item->status_perawatan == 'selesai' ? 'badge-success' : 'badge-warning' }}">
                                            {{ ucfirst($item->status_perawatan) }}
                                        </span>
                                    </p>
                                    <p class="card-text"><strong>Catatan:</strong> {{ $item->catatan }}</p>
                                </div>
                                <div class="card-footer">
                                    <button class="btn btn-primary" data-bs-toggle="modal"
                                        data-bs-target="#orderModal{{ $item->id }}">
                                        <i class="fas fa-info-circle"></i> Detail
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Modal Detail Order -->
                        <div class="modal fade" id="orderModal{{ $item->id }}" tabindex="-1"
                            aria-labelledby="orderModalLabel{{ $item->id }}" aria-hidden="true">
                            <div class="modal-dialog modal-lg">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title" id="orderModalLabel{{ $item->id }}">
                                            <i class="fas fa-info-circle"></i> Detail Order ID: {{ $item->id }}
                                        </h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"
                                            aria-label="Close"></button>
                                    </div>

                                    <div class="modal-body">
                                        <div class="container">
                                            <div class="row">
                                                <div class="col-md-6 mb-3">
                                                    <div class="card shadow-sm">
                                                        <div class="card-body">
                                                            <h6><i class="fas fa-user"></i> Nama Operator:</h6>
                                                            <p>{{ $item->operator_name }}</p>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="col-md-6 mb-3">
                                                    <div class="card shadow-sm">
                                                        <div class="card-body">
                                                            <h6><i class="fas fa-cogs"></i> Nama alat:</h6>
                                                            <p>{{ $item->inventori_name }}</p>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="col-md-6 mb-3">
                                                    <div class="card shadow-sm">
                                                        <div class="card-body">
                                                            <h6><i class="fas fa-calendar-day"></i> Tanggal Mulai:</h6>
                                                            <p>{{ \Carbon\Carbon::parse($item->tanggal_mulai)->format('d/m/Y') }}
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="col-md-6 mb-3">
                                                    <div class="card shadow-sm">
                                                        <div class="card-body">
                                                            <h6><i class="fas fa-calendar-check"></i> Tanggal Selesai:</h6>
                                                            <p>{{ \Carbon\Carbon::parse($item->tanggal_selesai)->format('d/m/Y') }}
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="col-12 mb-3">
                                                    <div class="card shadow-sm">
                                                        <div class="card-body text-center">
                                                            <h6><i class="fas fa-sticky-note"></i> Catatan:</h6>
                                                            <p>{{ $item->catatan ?? '-' }}</p>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary"
                                            data-bs-dismiss="modal">Tutup</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    @endforeach
                @endif
            </div>
        </div>

    </body>

    </html>
@endsection
