<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\DetailOrder;
use App\Models\DetailPerawatan;

class DashboardController extends Controller
{
    public function index()
    {
        $orderCount = DetailOrder::where('status', 'pending')->count();
        $pengirimanCount = DetailOrder::whereIn('status', ['proses', 'persiapan', 'dikirim'])->count();
        $perawatanCount = DetailPerawatan::whereIn('status', ['pending', 'proses'])->count();

        return view('pages.dashboard', compact('orderCount', 'pengirimanCount','perawatanCount'));
    }
}
