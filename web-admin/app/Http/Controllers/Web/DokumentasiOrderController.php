<?php

namespace App\Http\Controllers\web;

use App\Http\Controllers\Controller;
use App\Models\DokumentasiOrder;
use Illuminate\Http\Request;

class DokumentasiOrderController extends Controller
{
    public function index(Request $request)
    {
        $query = DokumentasiOrder::with('order.customer');

        if ($request->has('search') && $request->search != '') {
            $search = $request->search;

            $query->whereHas('order.customer', function ($q) use ($search) {
                $q->where('nama', 'like', "%{$search}%")
                    ->orWhere('instansi', 'like', "%{$search}%");
            });
        }

        $dokumentasi = $query->latest()->paginate(6);

        return view('pages.dokumentasi.index', compact('dokumentasi'));
    }
}
