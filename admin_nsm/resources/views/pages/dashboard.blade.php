@extends('layouts.app')

@section('content')
<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>

    <style>
        /* Dashboard Layout */
        .dashboard-container {
            margin-top: 40px;
        }

        /* Efek Hover & Shadow */
        .card-custom {
            border-radius: 15px;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            overflow: hidden;
            position: relative;
        }

        .card-custom:hover {
            transform: translateY(-8px);
            box-shadow: 0px 8px 25px rgba(0, 0, 0, 0.2);
        }

        /* Warna & Gradient Cards */
        .card-shipping {
            background: linear-gradient(135deg, #007bff, #0056b3);
            color: white;
        }

        .card-schedule {
            background: linear-gradient(135deg, #6f42c1, #a463f2);
            color: white;
        }

        .card-maintenance {
            background: linear-gradient(135deg, #ff7b00, #ffb600);
            color: white;
        }

        .card-docs {
            background: linear-gradient(135deg, #28a745, #00d36a);
            color: white;
        }

        /* Efek Hover */
        .card-shipping:hover {
            background: linear-gradient(135deg, #0056b3, #004080);
        }

        .card-schedule:hover {
            background: linear-gradient(135deg, #5a34a5, #7a42df);
        }

        .card-maintenance:hover {
            background: linear-gradient(135deg, #d65b00, #ff9800);
        }

        .card-docs:hover {
            background: linear-gradient(135deg, #1e8b38, #00b457);
        }

        /* Badge Notifikasi */
        .notification-badge {
            position: absolute;
            top: 10px;
            right: 15px;
            background: red;
            color: white;
            border-radius: 50%;
            padding: 6px 10px;
            font-size: 14px;
            font-weight: bold;
            display: none;
        }

        /* Ikon & Teks */
        .card i {
            font-size: 40px;
            margin-bottom: 10px;
        }

        .card-title {
            font-size: 18px;
            font-weight: bold;
        }

        .card-text {
            font-size: 14px;
        }

        @media (max-width: 768px) {
    .card-custom {
        margin-bottom: 10px;
    }
}
    </style>
</head>

<body>

    <div class="container-fluid dashboard-container">
        <div class="row justify-content-center g-4">
            <!-- Order Masuk -->
            <div class="col-12 col-sm-6 col-md-3">
                <a href="/order" class="text-decoration-none">
                    <div class="card text-center card-custom card-shipping p-4 shadow-sm hover-shadow-lg">
                        <span id="orderBadge" class="notification-badge">0</span>
                        <div class="card-body">
                            <i class="fas fa-box fa-3x mb-3"></i>
                            <h5 class="card-title">Order Masuk</h5>
                        </div>
                    </div>
                </a>
            </div>
    
            <!-- Jadwal Pengiriman -->
            <div class="col-12 col-sm-6 col-md-3">
                <a href="/pengiriman" class="text-decoration-none">
                    <div class="card text-center card-custom card-schedule p-4 shadow-sm hover-shadow-lg">
                        <span id="pengirimanBadge" class="notification-badge">0</span>
                        <div class="card-body">
                            <i class="fas fa-calendar-alt fa-3x mb-3"></i>
                            <h5 class="card-title">Jadwal Pengiriman</h5>
                        </div>
                    </div>
                </a>
            </div>
    
            <!-- Jadwal Perawatan -->
            <div class="col-12 col-sm-6 col-md-3">
                <a href="/perawatan" class="text-decoration-none">
                    <div class="card text-center card-custom card-maintenance p-4 shadow-sm hover-shadow-lg">
                        <span id="perawatanBadge" class="notification-badge">0</span>
                        <div class="card-body">
                            <i class="fas fa-tools fa-3x mb-3"></i>
                            <h5 class="card-title">Jadwal Perawatan</h5>
                        </div>
                    </div>
                </a>
            </div>
    
            <!-- Dokumentasi Order -->
            <div class="col-12 col-sm-6 col-md-3">
                <a href="/order-documents" class="text-decoration-none">
                    <div class="card text-center card-custom card-docs p-4 shadow-sm hover-shadow-lg">
                        <span id="dokumentasiBadge" class="notification-badge">0</span>
                        <div class="card-body">
                            <i class="fas fa-image fa-3x mb-3"></i>
                            <h5 class="card-title">Dokumentasi Order</h5>
                        </div>
                    </div>
                </a>
            </div>
        </div>
    </div>
    

    <!-- JavaScript untuk Notifikasi -->
    <script>
        function updateBadges() {
            fetch('/order-count')
                .then(response => response.json())
                .then(data => {
                    let orderBadge = document.getElementById('orderBadge');
                    if (data.count > 0) {
                        orderBadge.style.display = 'block';
                        orderBadge.textContent = data.count;
                    } else {
                        orderBadge.style.display = 'none';
                    }
                })
                .catch(error => console.error('Error fetching order count:', error));

            fetch('/pengiriman-count')
                .then(response => response.json())
                .then(data => {
                    let pengirimanBadge = document.getElementById('pengirimanBadge');
                    if (data.count > 0) {
                        pengirimanBadge.style.display = 'block';
                        pengirimanBadge.textContent = data.count;
                    } else {
                        pengirimanBadge.style.display = 'none';
                    }
                })
                .catch(error => console.error('Error fetching pengiriman count:', error));

                fetch('/perawatan-count')
                .then(response => response.json())
                .then(data => {
                    let perawatanBadge = document.getElementById('perawatanBadge');
                    if (data.count > 0) {
                        perawatanBadge.style.display = 'block';
                        perawatanBadge.textContent = data.count;
                    } else {
                        perawatanBadge.style.display = 'none';
                    }
                })
                .catch(error => console.error('Error fetching perawatan count:', error));
        }

        document.addEventListener('DOMContentLoaded', function () {
            updateBadges();
            setInterval(updateBadges, 5000);
        });
    </script>

    <audio id="notifSound">
        <source src="{{ asset('sounds/slick-notification.mp3') }}" type="audio/mpeg">
    </audio>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            let orderBadge = document.getElementById('orderBadge');
            let pengirimanBadge = document.getElementById('pengirimanBadge');
            let perawatanBadge = document.getElementById('perawatanBadge');
            let notifSound = document.getElementById("notifSound");
    
            let lastOrderCount = 0;
            let lastPengirimanCount = 0;
            let lastPerawatanCount = 0;
    
            function updateBadges() {
                fetch('/order-count')
                    .then(response => response.json())
                    .then(data => {
                        if (data.count > 0) {
                            orderBadge.style.display = 'block';
                            orderBadge.textContent = data.count;
                        } else {
                            orderBadge.style.display = 'none';
                        }
    
                        // Jika jumlah order bertambah, putar suara
                        if (data.count > lastOrderCount) {
                            notifSound.play();
                        }
    
                        lastOrderCount = data.count;
                    });
    
                fetch('/pengiriman-count')
                    .then(response => response.json())
                    .then(data => {
                        if (data.count > 0) {
                            pengirimanBadge.style.display = 'block';
                            pengirimanBadge.textContent = data.count;
                        } else {
                            pengirimanBadge.style.display = 'none';
                        }
    
                        // Jika jumlah pengiriman bertambah, putar suara
                        if (data.count > lastPengirimanCount) {
                            notifSound.play();
                        }
    
                        lastPengirimanCount = data.count;
                    });
    
                fetch('/perawatan-count')
                    .then(response => response.json())
                    .then(data => {
                        if (data.count > 0) {
                            perawatanBadge.style.display = 'block';
                            perawatanBadge.textContent = data.count;
                        } else {
                            perawatanBadge.style.display = 'none';
                        }
    
                        // Jika jumlah perawatan bertambah, putar suara
                        if (data.count > lastPerawatanCount) {
                            notifSound.play();
                        }
    
                        lastPerawatanCount = data.count;
                    });
            }
    
            // Jalankan saat halaman dimuat pertama kali
            updateBadges();
            setInterval(updateBadges, 5000); // Update setiap 5 detik
        });
    </script>
    


</body>

</html>
@endsection
