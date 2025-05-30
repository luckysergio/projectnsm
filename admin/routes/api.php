<?php

use App\Http\Controllers\NotificationsController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DeviceTokenController;
use App\Http\Controllers\InventoryController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\OrderDocumentController;
use App\Http\Controllers\PerawatanController;
use App\Http\Controllers\SendNotification;

// ✅ Route untuk Autentikasi
Route::post('/register', [AuthController::class, 'register']); // Register user baru
Route::post('/login', [AuthController::class, 'login']); // Login menggunakan NIK

// ✅ Route API yang membutuhkan autentikasi JWT
Route::middleware('auth:api')->group(function () {
    Route::get('/profile', [AuthController::class, 'profile']); // Menampilkan profil user
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::put('/user/update/{id}', [AuthController::class, 'update']);
});

Route::get('/inventori', [InventoryController::class, 'index']); // Lihat semua alat
Route::get('/inventori/{id}', [InventoryController::class, 'show']); // Lihat detail alat
Route::post('/inventori', [InventoryController::class, 'store']); // Tambah alat (Admin)
Route::put('/inventori/{id}', [InventoryController::class, 'update']); // Update alat (Admin)
Route::delete('/inventori/{id}', [InventoryController::class, 'destroy']); // Hapus alat (Admin)

Route::middleware('auth:api')->group(function () {
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders', [OrderController::class, 'getOrders']); // Order Diterima
    Route::get('/orders/jadwal-pengiriman', [OrderController::class, 'getOrdersJadwalPengiriman']);
    Route::put('/update-order/{id}', [OrderController::class, 'updateOrderStatus']); // Jadwal Pengiriman
    Route::get('/orders/histori', [OrderController::class, 'getOrdersHistori']);
    Route::get('/orders/all', [OrderController::class, 'getAllOrders']); // Histori Order
    Route::get('/orders/pending', [OrderController::class, 'getPendingOrders']);
    Route::get('/orders/completed', [OrderController::class, 'getCompletedOrders']);

    Route::get('/orders', [OrderController::class, 'index']); // Melihat semua order
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::get('/inventori-tersedia', [InventoryController::class, 'getTersedia']);


    Route::get('/inventory/{jenis}', [InventoryController::class, 'getByJenis']);
    
    Route::post('/perawatan', [PerawatanController::class, 'store1']); // Mengajukan perawatan
    Route::get('/perawatan/proses', [PerawatanController::class, 'getInProgressPerawatan']); // Menampilkan yang sedang diproses
    Route::put('/perawatan/{id}', [PerawatanController::class, 'updatePerawatan']);
    Route::get('/perawatan/pending', [PerawatanController::class, 'getPendingOrders']);
    Route::get('/perawatan/proses-selesai', [PerawatanController::class, 'getPerawatanProsesSelesai']);

    Route::get('/count-orders', [OrderController::class, 'countOrders']);
    Route::get('/count-perawatan', [PerawatanController::class, 'countPerawatan']);
    Route::get('/count-orders1', [OrderController::class, 'countOrders1']);
    Route::get('/orders/status-changes', [OrderController::class, 'getStatusChanges']);

    Route::post('/order-documents', [OrderDocumentController::class, 'store']);
    Route::get('/order-documents', [OrderDocumentController::class, 'history']);

});

