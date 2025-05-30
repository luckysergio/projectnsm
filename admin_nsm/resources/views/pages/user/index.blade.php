@extends('layouts.app')

@section('content')
<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Data User</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome -->
    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.15/dist/sweetalert2.min.css" rel="stylesheet">

    <style>
        /* Global Styles */
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f8f9fa;
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
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
        }

        .page-header h1 {
            font-size: 2.5rem;
            margin: 0;
        }

        /* Search Box Styling */
        .search-box {
            display: flex;
            align-items: center;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            margin-top: 20px;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }

        .search-box input {
            border: none;
            padding: 12px 20px;
            width: 100%;
            outline: none;
            font-size: 1rem;
        }

        .search-box button {
            border: none;
            background: #007bff;
            padding: 12px 20px;
            cursor: pointer;
            color: white;
            transition: 0.3s ease;
        }

        .search-box button:hover {
            background: #0056b3;
        }

        /* Button Styling */
        .btn-custom {
            background-color: #28a745;
            color: white;
            border-radius: 8px;
            padding: 10px 15px;
            font-size: 14px;
            transition: 0.3s;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
        }

        .btn-custom:hover {
            background-color: #218838;
        }

        /* Table Styling */
        .table-custom {
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            margin-top: 20px;
        }

        .table th {
            background-color: #007bff;
            color: white;
            text-transform: uppercase;
            padding: 12px;
        }

        .table tbody tr:hover {
            background-color: #f8f9fa;
        }

        .table td {
            vertical-align: middle;
        }

        /* Badge Styling */
        .badge-role {
            font-size: 14px;
            padding: 6px 10px;
            border-radius: 6px;
        }

        .badge-admin {
            background-color: #dc3545;
            color: white;
        }

        .badge-staff {
            background-color: #17a2b8;
            color: white;
        }

        /* Footer Styling */
        .footer {
            text-align: center;
            margin-top: 20px;
            font-size: 14px;
            color: #555;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .page-header {
                flex-direction: column;
                text-align: center;
            }

            .search-container {
                width: 100%;
            }

            .search-box {
                width: 100%;
                max-width: 350px;
            }

            .search-box input {
                width: 100%;
            }

            .btn-custom {
                width: 100%;
                margin-top: 10px;
            }
        }
    </style>
</head>

<body>

    <div class="container mt-4">
        <!-- Header -->
        <div class="page-header">
            <h1 class="h3 mb-0">Data User</h1>
            <a href="/user/create1" class="btn btn-custom">
                <i class="fas fa-user-plus me-2"></i> Tambah User
            </a>
        </div>

        <!-- Search Form -->
        <div class="search-container">
            <form action="{{ url('/user') }}" method="GET" class="search-box">
                <input type="text" name="search" placeholder="Cari nama atau nik.." value="{{ request('search') }}">
                <button type="submit">
                    <i class="fas fa-search"></i>
                </button>
            </form>
        </div>

        <!-- Table -->
        <div class="row">
            <div class="col">
                <div class="card table-custom">
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

                        <table class="table table-bordered text-center">
                            <thead>
                                <tr>
                                    <th>Nama Lengkap</th>
                                    <th>NIK</th>
                                    <th>Jabatan</th>
                                    <th>Email</th>
                                    <th>Aksi</th>
                                </tr>
                            </thead>
                            @if (count($user) < 1)
                                <tbody>
                                    <tr>
                                        <td colspan="6" class="text-center py-4">
                                            <p class="m-0">Tidak ada data</p>
                                        </td>
                                    </tr>
                                </tbody>
                            @else
                                <tbody>
                                    @foreach ($user as $item)
                                        <tr>
                                            <td>{{ $item->name }}</td>
                                            <td>{{ $item->nik }}</td>
                                            <td>
                                                <span class="badge badge-role {{ $item->role == 'admin' ? 'badge-admin' : 'badge-staff' }}">
                                                    {{ ucfirst($item->role) }}
                                                </span>
                                            </td>
                                            <td>{{ $item->email }}</td>
                                            <td>
                                                <a href="/user/{{ $item->id }}" class="btn btn-sm btn-warning">
                                                    <i class="fas fa-edit"></i>
                                                </a>
                                                <button type="button" class="btn btn-sm btn-danger" data-bs-toggle="modal" data-bs-target="#confirmationDelete-{{ $item->id }}">
                                                    <i class="fas fa-trash-alt"></i>
                                                </button>
                                            </td>                                           
                                        </tr>
                                        @include('pages.user.confirmation-delete')
                                    @endforeach
                                </tbody>
                            @endif
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>

</html>
@endsection
