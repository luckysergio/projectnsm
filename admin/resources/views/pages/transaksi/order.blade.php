@extends('layouts.app')

@section('title', 'Order Masuk')

@section('content')
    <style>
        /* Header Styling */
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

        /* Card Styling */
        .order-card {
            background: #ffffff;
            border-radius: 15px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
            padding: 25px;
            transition: 0.3s ease;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            height: 100%;
        }

        .order-card:hover {
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
        }

        /* Order Title */
        .order-title {
            background-color: #007bff;
            color: white;
            text-align: center;
            font-size: 18px;
            font-weight: 600;
            border-radius: 10px;
            padding: 10px;
            margin-bottom: 15px;
        }

        /* Detail Text */
        .order-card p {
            font-size: 15px;
            line-height: 1.7;
            color: #444;
            margin-bottom: 6px;
        }

        .order-card p strong {
            color: #222;
        }

        /* Styling untuk Tombol */
        .action-btn,
        .delete-btn {
            color: #fff;
            border-radius: 50px;
            padding: 14px 30px;
            font-weight: 600;
            text-decoration: none;
            width: 100%;
            text-align: center;
            margin-bottom: 15px;
            display: inline-block;
            text-transform: uppercase;
            letter-spacing: 1px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
        }

        .action-btn {
            background-color: #007bff;
            border: 2px solid #007bff;
        }

        .delete-btn {
            background-color: #dc3545;
            border: 2px solid #dc3545;
        }

        .action-btn:hover {
            background-color: #0056b3;
            border-color: #0056b3;
            transform: translateY(-2px);
            box-shadow: 0 6px 10px rgba(0, 0, 0, 0.15);
        }

        .delete-btn:hover {
            background-color: #c82333;
            border-color: #c82333;
            transform: translateY(-2px);
            box-shadow: 0 6px 10px rgba(0, 0, 0, 0.15);
        }

        .button-container {
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            gap: 15px;
            margin-top: 20px;
        }

        @media (max-width: 768px) {
            .order-card {
                padding: 20px;
            }

            .action-btn,
            .delete-btn {
                width: 100%;
                text-align: center;
                margin-bottom: 15px;
            }
        }

        /* Modal Styling */
        .modal-dialog {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            /* Ensure it's vertically centered */
        }
    </style>

    <div class="container mt-4">
        <div class="page-header">
            Order Masuk
        </div>

        <div class="row">
            @if (count($order) < 1)
                <div class="col-12">
                    <div class="alert alert-info text-center">
                        Tidak ada data
                    </div>
                </div>
            @else
                @foreach ($order as $item)
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="order-card">
                            <div class="order-title">
                                <i class="fas fa-box"></i> Order #{{ $item->id }}
                            </div>
                            <p><strong>Sales:</strong> {{ $item->sales_name }}</p>
                            <p><strong>Pemesan:</strong> {{ $item->nama_pemesan }}</p>
                            <p><strong>Alamat:</strong> {{ $item->alamat_pemesan }}</p>
                            <p><strong>Alat:</strong> {{ $item->inventori_name }}</p>
                            <p><strong>Sewa:</strong> {{ $item->total_sewa }} jam</p>
                            <p><strong>Pembayaran:</strong> {{ $item->status_pembayaran }}</p>
                            <p><strong>Order Status:</strong> {{ $item->status_order }}</p>
                            <p><strong>Catatan:</strong> {{ $item->catatan }}</p>
                            <p><strong>Total harga:</strong>Rp {{ number_format($item->total_harga, 0, ',', '.') }}</p>

                            <div class="button-container">
                                <button class="action-btn" onclick="window.location.href='/order/{{ $item->id }}'">
                                    <i class="fas fa-sync-alt"></i> Proses
                                </button>

                                <!-- Reject Button, Trigger Modal -->
                                <button class="delete-btn" data-bs-toggle="modal"
                                    data-bs-target="#confirmationDeleteModal-{{ $item->id }}">
                                    <i class="fas fa-times"></i> Reject
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Modal for Reject Confirmation -->
                    <div class="modal fade" id="confirmationDeleteModal-{{ $item->id }}" tabindex="-1"
                        aria-labelledby="confirmationDeleteModalLabel-{{ $item->id }}" aria-hidden="true">
                        <div class="modal-dialog">
                            <form action="{{ url('/order/' . $item->id) }}" method="POST">
                                @csrf
                                @method('DELETE')
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title" id="confirmationDeleteModalLabel-{{ $item->id }}">Konfirmasi Hapus
                                        </h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        <span>Apakah Anda yakin ingin menghapus order ini?</span>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                        <button type="submit" class="btn btn-danger">Ya, Hapus!</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                @endforeach
            @endif
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

@endsection