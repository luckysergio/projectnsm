<ul class="navbar-nav sidebar sidebar-dark accordion custom-sidebar toggled" id="accordionSidebar">

    <!-- Sidebar - Brand -->
    <a class="sidebar-brand d-flex align-items-center justify-content-center" href="/dashboard">
        <div class="sidebar-brand-icon">
            <i class="fas fa-home"></i>
        </div>
    </a>

    <!-- Divider -->
    <hr class="sidebar-divider my-0">

    <hr class="sidebar-divider">

    <li class="nav-item">
        <a class="nav-link" href="/user">
            <i class="fas fa-users"></i>
            <span>Data</span>
            <span>User</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="/Inventory">
            <i class="fas fa-boxes"></i>
            <span>Data</span>
            <span>Inventori</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="/histori">
            <i class="fas fa-clipboard-list"></i>
            <span>Data</span>
            <span>Sewa</span>
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="/historiperawatan">
            <i class="fas fa-clipboard-list"></i>
            <span>Data</span>
            <span>Perawatan</span>
        </a>
    </li>

    <!-- Divider -->
    <hr class="sidebar-divider d-none d-md-block">

</ul>

<!-- Sidebar Styling -->
<style>
    /* Sidebar Styling */
    .custom-sidebar {
        background: #007bff;
        /* Warna Biru Tabel */
        min-height: 100vh;
        width: 80px;
        transition: all 0.3s ease-in-out;
        overflow: hidden;
    }

    .custom-sidebar .nav-link {
        color: rgba(255, 255, 255, 0.85);
        font-size: 15px;
        padding: 12px 20px;
        transition: all 0.3s ease-in-out;
        white-space: nowrap;
    }

    .custom-sidebar .nav-link i {
        font-size: 18px;
        margin-right: 10px;
    }

    /* Hover Effect */
    .custom-sidebar .nav-link:hover {
        background: rgba(255, 255, 255, 0.2);
        color: #fff;
        transform: scale(1.05);
    }

    /* Active Link */
    .custom-sidebar .nav-item.active {
        background: rgba(255, 255, 255, 0.3);
        border-left: 4px solid #fff;
    }

    .custom-sidebar .nav-item.active .nav-link {
        font-weight: bold;
        color: #fff;
    }

    /* Sidebar Toggle */
    .sidebar.toggled {
        width: 250px;
    }

    .sidebar.toggled .nav-link span {
        display: inline;
    }

    .sidebar.toggled .nav-link i {
        margin-right: 10px;
    }

    .sidebar .nav-link span {
        display: none;
    }

    /* Sidebar Toggle Button */
    .sidebar-toggle-btn {
        background: none;
        color: white;
        font-size: 18px;
        transition: all 0.3s ease;
    }

    .sidebar-toggle-btn:hover {
        color: #fff;
    }

    .sidebar.toggled .sidebar-toggle-btn i {
        transform: rotate(180deg);
    }
</style>

<!-- Sidebar Active State & Toggler Script -->
<script>
    document.addEventListener("DOMContentLoaded", function () {
        let currentPath = window.location.pathname.toLowerCase();
        let navLinks = document.querySelectorAll(".nav-item a.nav-link");
        let sidebar = document.getElementById("accordionSidebar");
        let toggleButton = document.getElementById("sidebarToggle");

        // Menentukan halaman aktif
        navLinks.forEach(link => {
            let linkPath = new URL(link.href, window.location.origin).pathname.toLowerCase();
            if (currentPath === linkPath) {
                link.parentElement.classList.add("active");
            }
        });

        toggleButton.addEventListener("click", function () {
            sidebar.classList.toggle("toggled");
            updateToggleIcon();
        });

        function updateToggleIcon() {
            let icon = toggleButton.querySelector("i");
            if (sidebar.classList.contains("toggled")) {
                icon.classList.remove("fa-angle-right");
                icon.classList.add("fa-angle-left");
            } else {
                icon.classList.remove("fa-angle-left");
                icon.classList.add("fa-angle-right");
            }
        }

        updateToggleIcon();
    });
</script>