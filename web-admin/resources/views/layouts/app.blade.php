<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Web Admin - NSM</title>

    <link href="{{ asset('template/vendor/fontawesome-free/css/all.min.css') }}" rel="stylesheet" type="text/css">
    <link
        href="https://fonts.googleapis.com/css?family=Nunito:200,200i,300,300i,400,400i,600,600i,700,700i,800,800i,900,900i"
        rel="stylesheet">
    <link href="{{ asset('template/css/sb-admin-2.min.css') }}" rel="stylesheet">


    @vite(['resources/css/app.css'])

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://js.pusher.com/7.2/pusher.min.js"></script>
    <script src="https://unpkg.com/alpinejs" defer></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

</head>

<body id="page-top">

    <div id="wrapper">
        @include('layouts.sidebar')
        <div id="content-wrapper" class="d-flex flex-column">
            <div id="content">
                @include('layouts.navbar')
                <div class="container-fluid">
                    @yield('content')
                </div>
            </div>
            @include('layouts.footer')
        </div>
    </div>

    <a class="scroll-to-top rounded" href="#page-top">
        <i class="fas fa-angle-up"></i>
    </a>

    <script src="{{ asset('template/vendor/jquery/jquery.min.js') }}"></script>
    <script src="{{ asset('template/vendor/bootstrap/js/bootstrap.bundle.min.js') }}"></script>
    <script src="{{ asset('template/vendor/jquery-easing/jquery.easing.min.js') }}"></script>
    <script src="{{ asset('template/js/sb-admin-2.min.js') }}"></script>
    <script src="{{ asset('template/vendor/chart.js/Chart.min.js') }}"></script>
    {{-- <script src="{{ asset('template/js/demo/chart-area-demo.js') }}"></script>
    <script src="{{ asset('template/js/demo/chart-pie-demo.js') }}"></script> --}}

    @stack('scripts')

    <script>
        Pusher.logToConsole = true;

        const pusher = new Pusher("{{ env('PUSHER_APP_KEY') }}", {
            cluster: "{{ env('PUSHER_APP_CLUSTER') }}",
            forceTLS: true
        });

        const orderChannel = pusher.subscribe('orders');
        orderChannel.bind('order.count-updated', function(data) {
            console.log("Order count updated:", data);
            updateOrderCount(data.orderCount);
            updatePengirimanCount(data.pengirimanCount);

            if (data.orderData) {
                insertNewOrderCard(data.orderData);
            }
        });

        const pengirimanChannel = pusher.subscribe('pengiriman');
        pengirimanChannel.bind('pengiriman.updated', function(data) {
            console.log("Pengiriman updated:", data);
            insertNewPengirimanCard(data.order);
        });

        const notificationChannel = pusher.subscribe('notifications');
        notificationChannel.bind('notification.created', function(data) {
            console.log("Notifikasi Baru:", data);
            updateNotificationUI(data);
        });

        const perawatanChannel = pusher.subscribe('perawatans');
        perawatanChannel.bind('perawatan.count-updated', function(data) {
            console.log("Perawatan updated:", data);
            updatePerawatanCount(data.perawatanCount);
            insertNewPerawatanCard(data.perawatanData);
        });

        const dokumentasiChannel = pusher.subscribe('dokumentasi');
        dokumentasiChannel.bind('dokumentasi.created', function(data) {
            console.log("Dokumentasi baru:", data);
            insertNewDokumentasiCard(data.dokumentasi);
        });

        function updateOrderCount(value) {
            let el = document.getElementById('orderCount');
            if (el) {
                el.innerText = value;
                el.classList.toggle('hidden', value <= 0);
            }
        }

        function updatePengirimanCount(value) {
            let el = document.getElementById('pengirimanCount');
            if (el) {
                el.innerText = value;
                el.classList.toggle('hidden', value <= 0);
            }
        }

        function updatePerawatanCount(value) {
            let el = document.getElementById('perawatanCount');
            if (el) {
                el.innerText = value;
                el.classList.toggle('hidden', value <= 0);
            }
        }

        function updateNotificationUI(notification) {
            const badge = document.getElementById('notificationBadge');
            if (badge) {
                let count = parseInt(badge.textContent.trim()) || 0;
                badge.textContent = count + 1;
                badge.classList.remove('d-none');
            }

            const dropdown = document.getElementById('notificationMenu');
            if (!dropdown) return;

            const item = document.createElement('a');
            item.classList.add('dropdown-item', 'd-flex', 'align-items-center');
            item.href = notification.url ? new URL(notification.url, window.location.origin).href : '#';
            item.innerHTML = `
            <div class="w-100">
                <div class="small text-gray-500">Baru saja</div>
                <span class="font-weight-bold">${escapeHtml(notification.title)}</span>
                <div>${escapeHtml(notification.message)}</div>
            </div>
        `;

            dropdown.insertBefore(item, dropdown.children[1]);
            const items = dropdown.querySelectorAll('.dropdown-item');
            if (items.length > 5) items[items.length - 1].remove();
        }

        function insertNewOrderCard(order) {
            const container = document.querySelector('#orderCardContainer');
            if (!container)
                return;


            const emptyMessage = container.querySelector('.empty-message');
            if (emptyMessage) {
                emptyMessage.remove();
            }

            if (document.getElementById(`order-card-${order.id}`)) {
                console.warn(`Order SEWA-${order.id} sudah ada`);
                return;
            }

            const card = document.createElement('div');
            card.id = `order-card-${order.id}`;
            card.className =
                'bg-white rounded-3xl shadow-md border border-gray-100 p-6 transition-all duration-300 hover:shadow-xl';

            const sisaBayar = (order.tagihan ?? 0) - (order.total_bayar ?? 0);

            let buktiHtml = '';
            if (order.detail_pembayarans && order.detail_pembayarans.length > 0) {
                buktiHtml += `<div class="grid grid-cols-2 gap-3 mt-2">`;
                for (const dp of order.detail_pembayarans) {
                    if (dp.bukti) {
                        buktiHtml += `
                    <div class="relative border rounded-xl overflow-hidden">
                        <img src="/storage/${escapeHtml(dp.bukti)}" alt="Bukti Pembayaran"
                            class="w-full h-40 object-contain bg-white border border-gray-200">
                        <div class="absolute bottom-0 left-0 right-0 bg-white bg-opacity-70 text-center text-xs text-gray-600 py-1">
                            Dibayar: Rp ${formatRupiah(dp.jml_dibayar ?? 0)}
                        </div>
                    </div>
                `;
                    }
                }
                buktiHtml += `</div>`;
            } else {
                buktiHtml = `<p class="italic text-gray-400">Belum ada bukti pembayaran</p>`;
            }

            card.innerHTML = `
        <div class="text-center mb-4">
            <h2 class="text-blue-600 font-bold text-lg">SEWA-${String(order.id).padStart(3, '0')}</h2>
            <div class="text-sm text-gray-500">
                <i class="fas fa-clock mr-1"></i> ${escapeHtml(order.created_at_human ?? 'Baru saja')}
            </div>
        </div>

        <div class="text-sm text-gray-600 space-y-1 mb-4">
            <p><strong>Pemesan:</strong> ${escapeHtml(order.customer ?? '-')}</p>
            <p><strong>Sales:</strong> ${escapeHtml(order.sales ?? '-')}</p>
            <p><strong>Jumlah Item:</strong> ${escapeHtml(order.jumlah_item?.toString() ?? '0')}</p>
        </div>

        <div class="bg-gray-50 rounded-xl p-4 mb-4 text-sm text-gray-700 space-y-1">
            <p><strong>Total Tagihan:</strong> Rp ${formatRupiah(order.tagihan ?? 0)}</p>
            <p><strong>Jumlah Bayar:</strong> Rp ${formatRupiah(order.total_bayar ?? 0)}</p>
            <p><strong>Sisa Bayar:</strong> Rp ${formatRupiah(sisaBayar)}</p>

            <div class="mt-3">
                <p><strong>Bukti:</strong></p>
                ${buktiHtml}
            </div>
        </div>

        <div class="flex gap-3 mt-4">
            <button onclick="window.location.href='/order/${order.id}'"
                class="w-full py-2 rounded-xl bg-gradient-to-tr from-blue-500 to-blue-600 text-white font-semibold shadow hover:from-blue-600 hover:to-blue-700 transition-all">
                Proses
            </button>

            <button onclick="confirmReject(${order.id})"
                class="w-full py-2 rounded-xl bg-gradient-to-tr from-red-500 to-red-600 text-white font-semibold shadow hover:from-red-600 hover:to-red-700 transition-all">
                Reject
            </button>

            <form id="reject-form-${order.id}" action="/order/${order.id}" method="POST" class="hidden">
                <input type="hidden" name="_method" value="DELETE">
                <input type="hidden" name="_token" value="${document.querySelector('meta[name=csrf-token]')?.content ?? ''}">
            </form>
        </div>
    `;

            container.prepend(card);
        }

        function insertNewPerawatanCard(perawatan) {
            const container = document.getElementById('perawatanCardContainer');
            if (!container) return;

            const cardId = `perawatan-card-${perawatan.id}`;
            const existingCard = document.getElementById(cardId);

            const card = document.createElement('div');
            card.className =
                "bg-white rounded-3xl shadow-md border border-gray-100 p-6 transition-all duration-300 hover:shadow-xl";
            card.id = cardId;

            const idFormatted = `PRW-${String(perawatan.id).padStart(3, '0')}`;
            const operator = escapeHtml(perawatan.operator ?? '-');
            const createdAt = escapeHtml(perawatan.created_at_human ?? 'Baru saja');

            let detailHtml = '';
            if (Array.isArray(perawatan.detail_perawatans) && perawatan.detail_perawatans.length > 0) {
                for (const detail of perawatan.detail_perawatans) {
                    let statusClass = 'bg-gray-200 text-gray-600';
                    if (detail.status === 'selesai') statusClass = 'bg-green-100 text-green-700';
                    else if (detail.status === 'proses') statusClass = 'bg-yellow-100 text-yellow-800';

                    detailHtml += `
                <div class="border rounded-md p-3 bg-white">
                    <p><strong>Alat:</strong> ${escapeHtml(detail.alat)}</p>
                    <p><strong>Tgl Mulai:</strong> ${escapeHtml(detail.tgl_mulai)}</p>
                    <p><strong>Tgl Selesai:</strong> ${escapeHtml(detail.tgl_selesai ?? '-')}</p>
                    <p>
                        <strong>Status:</strong>
                        <span class="inline-block px-2 py-1 rounded-full text-xs font-medium ${statusClass}">
                            ${escapeHtml(detail.status.charAt(0).toUpperCase() + detail.status.slice(1))}
                        </span>
                    </p>
                    <p><strong>Catatan:</strong> ${escapeHtml(detail.catatan ?? '-')}</p>
                </div>
            `;
                }
            } else {
                detailHtml = `<p class="italic text-gray-400">Tidak ada detail perawatan</p>`;
            }

            card.innerHTML = `
        <div class="text-center mb-4">
            <h2 class="text-blue-600 font-bold text-lg">${idFormatted}</h2>
            <div class="text-sm text-gray-500">
                <i class="fas fa-clock mr-1"></i> ${createdAt}
            </div>
        </div>

        <div class="text-sm text-gray-600 space-y-1 mb-4">
            <p><strong>Operator:</strong> ${operator}</p>
        </div>

        <div class="bg-gray-50 rounded-xl p-4 mb-4 text-sm text-gray-700 space-y-2">
            ${detailHtml}
        </div>

        <div class="flex gap-3 mt-4">
            <form action="/perawatan/${perawatan.id}/edit" method="GET" class="w-full">
                <button type="submit"
                    class="w-full py-2 rounded-xl bg-gradient-to-tr from-blue-500 to-blue-600 text-white font-semibold shadow hover:from-blue-600 hover:to-blue-700 transition-all">
                    Proses
                </button>
            </form>

            <button onclick="confirmDelete(${perawatan.id})"
                class="w-full py-2 rounded-xl bg-gradient-to-tr from-red-500 to-red-600 text-white font-semibold shadow hover:from-red-600 hover:to-red-700 transition-all">
                Delete
            </button>

            <form id="delete-form-${perawatan.id}" action="/perawatan/${perawatan.id}" method="POST" class="hidden">
                <input type="hidden" name="_method" value="DELETE">
                <input type="hidden" name="_token" value="${document.querySelector('meta[name=csrf-token]')?.content ?? ''}">
            </form>
        </div>
    `;

            if (existingCard) {
                existingCard.replaceWith(card);
            } else {
                container.prepend(card);
            }
        }

        function insertNewDokumentasiCard(item) {
            const container = document.querySelector("#dokumentasiCardContainer");
            if (!container) return;

            const emptyMessage = document.getElementById('empty-dokumentasi-message');
            if (emptyMessage) emptyMessage.remove();

            let fotoHtml = '';
            if (Array.isArray(item.foto) && item.foto.length > 0) {
                fotoHtml = `<div class="grid grid-cols-2 gap-2 mt-2">` +
                    item.foto.map(foto => `
                <a href="/storage/${foto}" target="_blank" class="group relative overflow-hidden rounded-lg hover:shadow-md transition">
                    <img src="/storage/${foto}" alt="Foto"
                    class="w-full h-28 object-contain bg-gray-50 rounded-md group-hover:scale-105 transition">
                </a>
            `).join('') +
                    `</div>`;
            } else {
                fotoHtml = `<p class="italic text-sm text-gray-400">Tidak ada foto dokumentasi</p>`;
            }

            const card = document.createElement('div');
            card.className = "bg-white border border-gray-200 rounded-2xl shadow-sm p-6 transition hover:shadow-md";

            card.innerHTML = `
        <div class="mb-3 space-y-1">
            <p class="text-xs text-gray-500">Nama Pemesan</p>
            <p class="font-semibold text-gray-800">${escapeHtml(item.order.customer.nama)}</p>

            <p class="text-xs text-gray-500">Instansi</p>
            <p class="text-sm text-gray-800">${escapeHtml(item.order.customer.instansi ?? '-')}</p>

            <p class="text-xs text-gray-500">Tanggal Dokumentasi</p>
            <p class="text-sm text-gray-700">${new Date(item.created_at).toLocaleString()}</p>
        </div>

        ${item.catatan ? `
                    <div class="mb-3">
                        <p class="text-xs text-gray-500">Catatan</p>
                        <p class="text-sm text-gray-700">${escapeHtml(item.catatan)}</p>
                    </div>` : ''}

        ${fotoHtml}
    `;

            container.prepend(card);
        }

        function insertNewPengirimanCard(order) {
            const container = document.querySelector('#pengirimanCardContainer');
            const emptyMessage = document.getElementById('empty-order-message');

            if (!container) return;

            const orderId = String(order.id).trim();
            const cardId = `pengiriman-card-${orderId}`;

            const existingCard = document.getElementById(cardId);
            if (existingCard) {
                existingCard.remove();
            }

            if (emptyMessage) {
                emptyMessage.remove();
            }

            const sisaBayar = (order.tagihan ?? 0) - (order.total_bayar ?? 0);

            const card = document.createElement('div');
            card.id = cardId;
            card.className =
                'bg-white rounded-3xl shadow-md border border-gray-100 p-6 transition-all duration-300 hover:shadow-xl';

            let detailHtml = '';
            if (Array.isArray(order.details) && order.details.length > 0) {
                order.details.forEach(detail => {
                    let statusClass = 'bg-gray-200 text-gray-600';
                    if (detail.status === 'proses') statusClass = 'bg-yellow-100 text-yellow-800';
                    else if (detail.status === 'persiapan') statusClass = 'bg-blue-100 text-blue-700';
                    else if (detail.status === 'dikirim') statusClass = 'bg-green-100 text-green-700';

                    detailHtml += `
                <div class="border border-gray-200 rounded-md p-3 bg-white mb-2">
                    <p><strong>Alat:</strong> ${escapeHtml(detail.alat)}</p>
                    <p><strong>Kirim:</strong> ${escapeHtml(detail.tgl_mulai ?? '-')}</p>
                    <p><strong>Jam Mulai:</strong> ${escapeHtml(detail.jam_mulai ?? '-')}</p>
                    <p>
                        <strong>Status:</strong>
                        <span class="inline-block px-2 py-1 rounded-full text-xs font-medium ${statusClass}">
                            ${escapeHtml(detail.status)}
                        </span>
                    </p>
                </div>
            `;
                });
            } else {
                detailHtml = `<p class="italic text-gray-400">Belum ada detail order</p>`;
            }

            let buktiHtml = '';
            if (Array.isArray(order.bukti_list) && order.bukti_list.length > 0) {
                buktiHtml = `<div class="grid grid-cols-2 gap-3 mt-2">` +
                    order.bukti_list.map(bukti => `
                <div class="relative border rounded-xl overflow-hidden">
                    <a href="/storage/${escapeHtml(bukti)}" target="_blank">
                        <img src="/storage/${escapeHtml(bukti)}" alt="Bukti Pembayaran"
                            class="w-full h-40 object-contain bg-white border border-gray-200">
                    </a>
                </div>
            `).join('') + `</div>`;
            } else {
                buktiHtml = `<p class="italic text-gray-400">Belum ada bukti pembayaran</p>`;
            }

            card.innerHTML = `
        <div class="text-center mb-4">
            <h2 class="text-blue-600 font-bold text-lg">SEWA-${orderId.padStart(3, '0')}</h2>
            <div class="text-sm text-gray-500">
                <i class="fas fa-clock mr-1"></i> ${escapeHtml(order.created_at_human ?? 'Baru saja')}
            </div>
        </div>

        <div class="text-sm text-gray-600 space-y-1 mb-4 text-center">
            <p>${escapeHtml(order.customer ?? '-')}</p>
        </div>

        <div class="bg-gray-50 rounded-xl p-4 mb-4 text-sm text-gray-700 space-y-2">
            ${detailHtml}
        </div>

        <div class="bg-gray-50 rounded-xl p-4 mb-4 text-sm text-gray-700 space-y-1">
            <p><strong>Total Tagihan:</strong> Rp ${formatRupiah(order.tagihan ?? 0)}</p>
            <p><strong>Jumlah Bayar:</strong> Rp ${formatRupiah(order.total_bayar ?? 0)}</p>
            <p><strong>Sisa Bayar:</strong> Rp ${formatRupiah(sisaBayar)}</p>

            <div class="mt-3 text-center">
                <p><strong>Bukti:</strong></p>
                ${buktiHtml}
            </div>
        </div>

        <div class="flex gap-3 mt-4">
            <form action="/pengiriman/${order.id}/edit" method="GET" class="w-full">
                <button type="submit"
                    class="w-full py-2 rounded-xl bg-gradient-to-tr from-blue-500 to-blue-600 text-white font-semibold shadow hover:from-blue-600 hover:to-blue-700 transition-all">
                    Proses
                </button>
            </form>
        </div>
    `;

            container.prepend(card);
        }

        function escapeHtml(text) {
            const div = document.createElement("div");
            div.innerText = text ?? '';
            return div.innerHTML;
        }

        function formatRupiah(angka) {
            return (angka ?? 0).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
        }
    </script>

</body>

</html>
