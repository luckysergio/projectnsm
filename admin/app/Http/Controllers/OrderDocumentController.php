<?php

namespace App\Http\Controllers;

use App\Models\OrderDocument;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class OrderDocumentController extends Controller
{
    public function store(Request $request)
    {
        $user = Auth::user();

        $request->validate([
            'order_id' => 'required|exists:orders,id',
            'photo' => 'nullable|array|max:5',
            'photo.*' => 'file|mimes:jpg,png,jpeg|max:5120',
            'note' => 'nullable|string',
        ]);

        $photoPaths = [];
        if ($request->hasFile('photo')) {
            foreach ($request->file('photo') as $photo) {
                $fileName = time() . '_' . uniqid() . '.' . $photo->getClientOriginalExtension();
                $photoPaths[] = $photo->storeAs('orders/photos', $fileName, 'public');
            }
        }

        $orderDocument = OrderDocument::create([
            'user_id' => $user->id,
            'order_id' => $request->order_id,
            'photo' => json_encode($photoPaths),
            'note' => $request->note,
        ]);

        return response()->json([
            'message' => 'Dokumentasi order berhasil disimpan!',
            'data' => $orderDocument,
        ], 201);
    }

    public function history(Request $request)
    {
        $user = Auth::user();

        $documents = OrderDocument::where('user_id', $user->id)
            ->with('order:id,nama_pemesan')
            ->orderBy('created_at', 'desc')
            ->get();

        if ($documents->isEmpty()) {
            return response()->json([
                'message' => 'Histori dokumentasi tidak ditemukan.',
                'data' => [],
            ], 404);
        }

        return response()->json([
            'message' => 'Histori dokumentasi berhasil diambil!',
            'data' => $documents,
        ], 200);
    }

    public function index(Request $request)
    {
        $documents = OrderDocument::with('order:id,nama_pemesan')
            ->orderBy('created_at', 'desc');

        if ($request->has('search') && !empty($request->search)) {
            $search = $request->search;
            $documents = $documents->whereHas('order', function ($q) use ($search) {
                $q->where('nama_pemesan', 'like', "%$search%");
            });
        }
        $documents = $documents->get();
        return view('pages.documents.index', compact('documents'));
    }
}
