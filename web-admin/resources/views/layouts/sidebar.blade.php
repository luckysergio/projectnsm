<ul class="navbar-nav bg-gradient-primary sidebar sidebar-dark accordion" id="accordionSidebar">
    <a class="sidebar-brand d-flex align-items-center justify-content-center" href="/dashboard">
        <div class="sidebar-brand-icon">
            <i class="fas fa-home"></i>
        </div>
        <div class="sidebar-brand-text mx-2">NSM</div>
    </a>

    <hr class="sidebar-divider my-0">

    <li class="nav-item {{ request()->is('dashboard') ? 'active' : '' }}">
        <a class="nav-link" href="/dashboard">
            <i class="fas fa-tachometer-alt"></i>
            <span>Dashboard</span>
        </a>
    </li>

    <hr class="sidebar-divider">

    <li class="nav-item {{ request()->is('jabatan') ? 'active' : '' }}">
        <a class="nav-link" href="/jabatan">
            <i class="fas fa-user-tie"></i>
            <span>Jabatan</span>
        </a>
    </li>

    <li class="nav-item {{ request()->is('karyawan*') ? 'active' : '' }}">
        <a class="nav-link" href="/karyawan">
            <i class="fas fa-users-cog"></i>
            <span>Karyawan</span>
        </a>
    </li>

    <li class="nav-item {{ request()->is('jenis') ? 'active' : '' }}">
        <a class="nav-link" href="/jenis">
            <i class="fas fa-tools"></i>
            <span>Jenis Alat</span>
        </a>
    </li>

    <li class="nav-item {{ request()->is('inventori*') ? 'active' : '' }}">
        <a class="nav-link" href="/inventori">
            <i class="fas fa-toolbox"></i>
            <span>Inventory</span>
        </a>
    </li>

    <li class="nav-item {{ request()->is('laporansewa') ? 'active' : '' }}">
        <a class="nav-link" href="/laporansewa">
            <i class="fas fa-file-invoice-dollar"></i>
            <span>Laporan Sewa</span>
        </a>
    </li>

    <li class="nav-item {{ request()->is('perawatan/selesai') ? 'active' : '' }}">
        <a class="nav-link" href="/perawatan/selesai">
            <i class="fas fa-tools"></i>
            <span>Laporan Perawatan</span>
        </a>
    </li>

    <hr class="sidebar-divider d-none d-md-block">

    <div class="text-center d-none d-md-inline">
        <button class="rounded-circle border-0" id="sidebarToggle"></button>
    </div>
</ul>
