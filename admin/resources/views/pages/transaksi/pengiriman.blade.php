@extends('layouts.app')

@section('title', 'Jadwal Pengiriman')

@section('content')
<style>
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

    .delivery-card {
        background: #ffffff;
        border-radius: 15px;
        box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
        padding: 25px;
        transition: 0.3s ease;
    }

    .delivery-card:hover {
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
    }

    .card-title {
        background-color: #007bff;
        color: white;
        text-align: center;
        font-size: 18px;
        font-weight: 600;
        border-radius: 10px;
        padding: 10px;
        margin-bottom: 15px;
    }

    .delivery-card p {
        font-size: 15px;
        line-height: 1.7;
        color: #444;
        margin-bottom: 6px;
    }

    .delivery-card p strong {
        color: #222;
    }

    .action-btn {
        color: #fff;
        background-color: #007bff;
        border-radius: 8px;
        padding: 10px 15px;
        font-weight: 600;
        transition: background-color 0.3s ease;
        text-decoration: none;
    }

/* Styling untuk Tombol */
.action-btn, .delete-btn {
    color: #fff;
    border-radius: 50px; /* Menambahkan border-radius lebih besar untuk tampilan yang lebih halus */
    padding: 14px 30px; /* Memperbesar ukuran tombol agar lebih modern */
    font-weight: 600;
    text-decoration: none;
    width: 100%; /* Tombol akan memanfaatkan lebar penuh */
    text-align: center;
    margin-bottom: 15px; /* Memberikan jarak antara tombol */
    display: inline-block; /* Agar tombol tetap inline dengan text-center */
    text-transform: uppercase; /* Mengubah teks menjadi kapital */
    letter-spacing: 1px; /* Memberikan sedikit jarak antar huruf */
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* Menambahkan bayangan halus */
    transition: all 0.3s ease; /* Menambahkan transisi halus */
}

/* Tombol "Proses" */
.action-btn {
    background-color: #007bff;
    border: 2px solid #007bff; /* Menambahkan border pada tombol */
}

/* Tombol "Reject" */
.delete-btn {
    background-color: #dc3545;
    border: 2px solid #dc3545; /* Menambahkan border pada tombol */
}

/* Hover effect untuk tombol */
.action-btn:hover {
    background-color: #0056b3;
    border-color: #0056b3; /* Mengubah border ketika hover */
    transform: translateY(-2px); /* Memberikan efek tombol terangkat */
    box-shadow: 0 6px 10px rgba(0, 0, 0, 0.15); /* Menambah efek bayangan */
}

.delete-btn:hover {
    background-color: #c82333;
    border-color: #c82333; /* Mengubah border ketika hover */
    transform: translateY(-2px); /* Memberikan efek tombol terangkat */
    box-shadow: 0 6px 10px rgba(0, 0, 0, 0.15); /* Menambah efek bayangan */
}

/* Menyusun tombol secara vertikal dan di tengah */
.button-container {
    display: flex;
    flex-direction: column; /* Mengubah arah menjadi kolom */
    justify-content: center; /* Menjaga tombol berada di tengah secara vertikal */
    align-items: center; /* Menjaga tombol berada di tengah secara horizontal */
    gap: 15px; /* Memberikan jarak yang lebih besar antara tombol */
    margin-top: 20px; /* Memberikan margin atas untuk ruang lebih */
}

/* Responsif untuk perangkat mobile */
@media (max-width: 768px) {
    .order-card {
        padding: 20px;
    }

    .action-btn, .delete-btn {
        width: 100%; /* Tombol akan melebar 100% pada perangkat mobile */
        text-align: center;
        margin-bottom: 15px; /* Memberikan jarak antar tombol pada perangkat kecil */
    }
}


</style>

<div class="container mt-4">
    <div class="page-header">
        Jadwal Pengiriman
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
                    <div class="delivery-card">
                        <div class="card-title">
                            <i class="fas fa-truck"></i> Order #{{ $item->id }}
                        </div>
                        <p><strong>Sales:</strong> {{ $item->sales_name }}</p>
                        <p><strong>Pemesan:</strong> {{ $item->nama_pemesan }}</p>
                        <p><strong>Alamat:</strong> {{ $item->alamat_pemesan }}</p>
                        <p><strong>Alat:</strong> {{ $item->inventori_name }}</p>
                        <p><strong>Sewa:</strong> {{ $item->total_sewa }} jam</p>
                        <p><strong>Pengiriman:</strong> {{ \Carbon\Carbon::parse($item->tgl_pengiriman)->format('d-m-y') }}</p>
                        <p><strong>Jam Mulai:</strong> {{ \Carbon\Carbon::parse($item->jam_mulai)->format('H:i') }} WIB</p>
                        <p><strong>Jam Selesai:</strong> {{ \Carbon\Carbon::parse($item->jam_selesai)->format('H:i') }} WIB</p>
                        <p><strong>Pengembalian:</strong> {{ \Carbon\Carbon::parse($item->tgl_pengembalian)->format('d-m-y') }}</p>
                        <p><strong>Operator:</strong> {{ $item->operator_name }}</p>
                        <p><strong>Status:</strong> {{ $item->status_order }}</p>
                        <p><strong>Catatan:</strong> {{ $item->catatan }}</p>
                        <div class="text-end mt-3">
                            <a href="/jadwal/{{ $item->id }}" class="action-btn btn" role="button">
                                <i class="fas fa-sync-alt"></i> Proses
                            </a>
                            
                        </div>
                    </div>
                </div>
            @endforeach
        @endif
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

@endsection
