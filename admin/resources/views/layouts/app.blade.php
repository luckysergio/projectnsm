<!DOCTYPE html>
<html lang="en" class="overflow-x-hidden">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Niaga Solusi Mandiri</title>
    <link rel="icon" href="{{ asset('images/logo.png') }}" type="image/png">

    @vite('resources/css/app.css')

    <link href="{{ asset('template/vendor/fontawesome-free/css/all.min.css') }}" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@200;400;600;700;900&display=swap" rel="stylesheet">
</head>

<body class="bg-white-100 font-sans text-gray-900 overflow-x-hidden">

    <div class="flex h-screen overflow-hidden">
        <!-- Sidebar -->
        <aside id="sidebar" class="bg-blue-600 text-white w-44 fixed top-0 left-0 h-full z-40 overflow-y-auto">
            @include('layouts.sidebar')
        </aside>

        <div id="mainContent" class="flex-1 flex flex-col ml-44 h-full">
            
            <header class="bg-white shadow sticky top-0 z-30">
                @include('layouts.navbar')
            </header>

            <div class="flex-1 overflow-y-auto">
                <main class="p-6 md:p-8 lg:p-10">
                    <div class="max-w-screen-xl mx-auto">
                        @yield('content')
                    </div>
                </main>

                <footer class="bg-white text-center text-sm p-4 border-t border-gray-200">
                    @include('layouts.footer')
                </footer>
            </div>

        </div>
    </div>

    <!-- Scripts -->
    <script src="{{ asset('template/vendor/jquery/jquery.min.js') }}"></script>
    <script src="{{ asset('template/vendor/chart.js/Chart.min.js') }}"></script>
    <script src="{{ asset('template/js/demo/chart-area-demo.js') }}"></script>
    <script src="{{ asset('template/js/demo/chart-pie-demo.js') }}"></script>
</body>

</html>
