<nav class="navbar navbar-expand navbar-light bg-grey-50 topbar mb-4 static-top">
    <button id="sidebarToggleTop" class="btn btn-link d-md-none rounded-circle mr-3">
        <i class="fa fa-bars"></i>
    </button>

    <ul class="navbar-nav ml-auto">
        <div class="topbar-divider d-none d-sm-block"></div>

        <li class="nav-item dropdown no-arrow mx-1">
            <a class="nav-link dropdown-toggle" href="#" id="notificationDropdown" role="button"
                data-toggle="dropdown">
                <i class="fas fa-bell fa-fw"></i>
                <span id="notificationBadge"
                    class="badge badge-danger badge-counter {{ $notificationCount > 0 ? '' : 'd-none' }}">
                    {{ $notificationCount }}
                </span>
            </a>

            <div class="dropdown-menu dropdown-menu-right shadow animated--grow-in"
                aria-labelledby="notificationDropdown" id="notificationMenu">
                <h6 class="dropdown-header">Notifikasi Terbaru</h6>

                @forelse($latestNotifications as $notif)
                    <a class="dropdown-item d-flex align-items-center" href="{{ $notif->url ?? '#' }}">
                        <div>
                            <div class="small text-gray-500">{{ $notif->created_at->diffForHumans() }}</div>
                            <span class="font-weight-bold">{{ $notif->title }}</span>
                            <div>{{ $notif->message }}</div>
                        </div>
                    </a>
                @empty
                    <span class="dropdown-item text-center small text-gray-500">Belum ada notifikasi</span>
                @endforelse

            </div>
        </li>

        <div class="topbar-divider d-none d-sm-block"></div>

        <li class="nav-item dropdown no-arrow">
            <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button" data-toggle="dropdown">
                <span class="mr-2 d-none d-lg-inline text-gray-600 small">{{ Auth::user()->karyawan->nama }}</span>
            </a>

            <div class="dropdown-menu dropdown-menu-right shadow animated--grow-in" aria-labelledby="userDropdown">
                <form action="{{ route('logout') }}" method="POST">
                    @csrf
                    <button type="submit" class="dropdown-item">
                        <i class="fas fa-sign-out-alt fa-sm fa-fw mr-2 text-gray-400"></i> Logout
                    </button>
                </form>
            </div>
        </li>
    </ul>
</nav>

<script>
    document.getElementById('notificationDropdown').addEventListener('click', function() {
        fetch("{{ route('notifications.markAsRead') }}", {
                method: 'POST',
                headers: {
                    'X-CSRF-TOKEN': "{{ csrf_token() }}",
                    'Content-Type': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                console.log("Marked as read");

                const badge = document.getElementById('notificationBadge');

                if (data.unreadCount !== undefined) {
                    if (data.unreadCount > 0) {
                        badge.textContent = data.unreadCount;
                        badge.classList.remove('d-none');
                    } else {
                        badge.classList.add('d-none');
                        badge.textContent = '0';
                    }
                } else {
                    // fallback
                    badge.classList.add('d-none');
                    badge.textContent = '0';
                }
            })
            .catch(error => {
                console.error("Error marking notifications as read:", error);
            });
    });
</script>
