<nav class="navbar navbar-expand-lg">

    <div class="container">
        <!-- Logo atau Brand -->
        <a class="navbar-brand text-black font-weight-bold" href="#"></a>

        <!-- Sidebar Toggle (Mobile) -->
        <button id="sidebarToggleTop" class="btn btn-link d-lg-none rounded-circle text-white">
            <i class="fa fa-bars"></i>
        </button>

        <!-- User Dropdown -->
        <ul class="navbar-nav ms-3">
            <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle text-warning" href="#" id="userDropdown" role="button"
                    data-bs-toggle="dropdown" aria-expanded="false">
                    {{ Auth::user()->name ?? 'Guest' }}
                </a>
                <ul class="dropdown-menu dropdown-menu-end shadow" aria-labelledby="userDropdown">
                    <li>
                        <form action="/logout1" method="post" class="dropdown-item p-0">
                            @csrf
                            <button type="submit" class="btn btn-link dropdown-item text-dark">
                                <i class="fas fa-sign-out-alt"></i> Keluar
                            </button>
                        </form>
                    </li>
                </ul>
            </li>
        </ul>

    </div>
</nav>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        let currentPage = window.location.pathname.split("/").pop();
        let navLinks = document.querySelectorAll(".nav-link");

        navLinks.forEach(link => {
            if (link.getAttribute("href") === currentPage) {
                link.classList.add("active", "fw-bold", "text-warning");
            }
        });
    });
</script>