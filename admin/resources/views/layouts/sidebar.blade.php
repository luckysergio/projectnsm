<div class="flex flex-col h-full w-44 bg-gradient-to-b from-blue-700 to-blue-600 shadow-lg text-white">

    <!-- Brand -->
    <a href="/dashboard"
       class="flex items-center gap-3 px-4 py-4 hover:bg-blue-700 transition duration-300 text-white">
        <i class="fas fa-home text-lg"></i>
        <span class="text-sm font-medium">Dashboard</span>
    </a>

    <!-- Navigation -->
    <nav class="flex-1 px-2 py-4 space-y-1">
        @php
            $menus = [
                ['icon' => 'fa-users', 'label' => 'User', 'url' => '/user'],
                ['icon' => 'fa-boxes', 'label' => 'Inventori', 'url' => '/Inventory'],
                ['icon' => 'fa-clipboard-list', 'label' => 'Sewa', 'url' => '/histori'],
                ['icon' => 'fa-tools', 'label' => 'Perawatan', 'url' => '/historiperawatan'],
            ];
        @endphp

        @foreach ($menus as $menu)
        <a href="{{ $menu['url'] }}"
           class="flex items-center gap-3 px-4 py-3 rounded-lg transition-all duration-300 hover:bg-blue-700 text-white
                  {{ request()->is(trim($menu['url'], '/')) ? 'bg-blue-800 font-semibold shadow-inner' : '' }}">
            <i class="fas {{ $menu['icon'] }} text-white text-lg"></i>
            <span class="text-sm">{{ $menu['label'] }}</span>
        </a>
        @endforeach
    </nav>

    <!-- Footer -->
    <div class="px-4 py-4 text-xs text-blue-200 border-t border-blue-500">
        © Niaga Solusi Mandiri
    </div>
</div>
