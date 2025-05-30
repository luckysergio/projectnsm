<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>NSM - Login</title>
    <link rel="icon" href="{{ asset('images/logo.png') }}" type="image/png">

    <link href="{{ asset('template/vendor/bootstrap/css/bootstrap.min.css') }}" rel="stylesheet">
    <link href="{{ asset('template/vendor/fontawesome-free/css/all.min.css') }}" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Nunito:200,300,400,600,700,800,900" rel="stylesheet">
    <link href="{{ asset('template/css/sb-admin-2.min.css') }}" rel="stylesheet">

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        body {
            background: linear-gradient(135deg, #4e73df, #1e40af);
            font-family: 'Nunito', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        .login-container {
            width: 100%;
            max-width: 450px;
            margin: 0 auto;
            padding: 20px;
        }

        .card {
            border-radius: 16px;
            padding: 30px;
            box-shadow: 0px 8px 30px rgba(0, 0, 0, 0.1);
            background: white;
            animation: fadeIn 0.8s ease-in-out;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-30px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .form-control {
            border-radius: 10px;
            padding: 14px;
            font-size: 15px;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        .form-control:focus {
            border-color: #2563eb;
            box-shadow: 0 0 5px rgba(37, 99, 235, 0.5);
        }

        .btn-primary {
            border-radius: 10px;
            padding: 12px;
            font-size: 16px;
            transition: all 0.3s ease-in-out;
            background: #2563eb;
            border: none;
            width: 100%;
        }

        .btn-primary:hover {
            background: #1d4ed8;
            box-shadow: 0px 4px 15px rgba(0, 0, 0, 0.2);
        }

        .password-wrapper {
            position: relative;
        }

        .password-wrapper .toggle-password {
            position: absolute;
            top: 50%;
            right: 15px;
            transform: translateY(-50%);
            cursor: pointer;
            color: gray;
            transition: color 0.3s ease;
        }

        .password-wrapper .toggle-password:hover {
            color: #2563eb;
        }

        .form-floating {
            position: relative;
        }

        .form-floating input:focus~label,
        .form-floating input:not(:placeholder-shown)~label {
            top: -12px;
            left: 12px;
            font-size: 13px;
            color: #2563eb;
            background: white;
            padding: 0 5px;
        }

        .form-floating label {
            position: absolute;
            top: 50%;
            left: 12px;
            transform: translateY(-50%);
            transition: all 0.3s ease;
            color: #aaa;
            font-size: 14px;
            pointer-events: none;
        }

        .card-header {
            font-size: 22px;
            font-weight: bold;
            color: #4e73df;
            margin-bottom: 20px;
        }

        .card-footer {
            text-align: center;
            font-size: 14px;
            color: #555;
            margin-top: 20px;
        }
    </style>
</head>

<body>

    @if(session('success'))
        <script>
            Swal.fire({
                icon: 'success',
                title: 'Berhasil!',
                text: @json(session('success')),
                didClose: () => {
                    window.location.href = "/dashboard";
                }
            });
        </script>
    @endif
    @if ($errors->any())
        <script>
            Swal.fire({
                title: "Terjadi Kesalahan",
                html: "{!! implode('<br>', $errors->all()) !!}",
                icon: "error"
            });
        </script>
    @endif

    <div class="container">
        <div class="login-container">
            <div class="card shadow-lg">
                <div class="card-body">
                    <div class="text-center">
                        <h1 class="h4 text-gray-900 mb-4 fw-bold">Niaga Solusi Mandiri</h1>
                    </div>
                    <form class="user" action="/login1" method="POST">
                        @csrf
                        @method('POST')

                        <div class="form-floating mb-4">
                            <input type="text" class="form-control" id="nik" name="nik" placeholder=" " required>
                            <label for="nik">Nomor Induk Karyawan</label>
                        </div>

                        <div class="form-floating mb-3 password-wrapper">
                            <input type="password" class="form-control" id="password" name="password" placeholder=" "
                                required>
                            <label for="password">Password</label>
                            <i class="fas fa-eye toggle-password" id="togglePassword"></i>
                        </div>

                        <button type="submit" class="btn btn-primary btn-user btn-block w-100">
                            Masuk
                        </button>
                    </form>
                </div>
                <div class="card-footer">
                    <small>© 2025 Niaga Solusi Mandiri</small>
                </div>
            </div>
        </div>
    </div>

    <script src="{{ asset('template/vendor/jquery/jquery.min.js') }}"></script>
    <script src="{{ asset('template/vendor/bootstrap/js/bootstrap.bundle.min.js') }}"></script>

    <script>
        document.getElementById('togglePassword').addEventListener('click', function () {
            let passwordField = document.getElementById('password');
            let type = passwordField.type === 'password' ? 'text' : 'password';
            passwordField.type = type;
            this.classList.toggle('fa-eye-slash');
        });
    </script>

</body>

</html>