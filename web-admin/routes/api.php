<?php

use App\Http\Controllers\api\CustomerController;
use App\Http\Controllers\api\DokumentasiOrderController;
use App\Http\Controllers\Api\InventoryController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\api\PembayaranController;
use App\Http\Controllers\Api\PerawatanController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\AuthController;

Route::prefix('auth')->group(function () {
    Route::post('login', [AuthController::class, 'login']);
    Route::post('logout', [AuthController::class, 'logout'])->middleware('jwt.verify');
    Route::post('refresh', [AuthController::class, 'refresh'])->middleware('jwt.verify');
    Route::get('me', [AuthController::class, 'me'])->middleware('jwt.verify');
    Route::get('check', [AuthController::class, 'checkAuth'])->middleware('jwt.verify');
    Route::post('change-password', [AuthController::class, 'changePassword'])->middleware('jwt.verify');
});

Route::middleware('jwt.verify')->group(function () {
    Route::post('order', [OrderController::class, 'store']);
    Route::get('orders/completed', [OrderController::class, 'getCompletedOrders']);
    Route::get('inventories', [InventoryController::class, 'index']);
    Route::get('/inventory/{kategori}', [InventoryController::class, 'filterByCategory']);
    Route::get('/jenis-alat', [InventoryController::class, 'getJenisAlat']);
    Route::get('/inventory-tersedia', [InventoryController::class, 'tersedia']);
    Route::get('customer', [CustomerController::class, 'index']);

    Route::get('/orders/active', [OrderController::class, 'getActiveOrders']);
    Route::get('/orders/all', [OrderController::class, 'getAllOrders']);

    Route::get('/orders/completed/public', [OrderController::class, 'getCompletedOrdersPublic']);
    Route::get('/orders/active/public', [OrderController::class, 'getActiveOrdersPublic']);
    Route::get('/orders/all/public', [OrderController::class, 'getAllOrdersPublic']);
    Route::get('/orders/active/operator/{id_operator}', [OrderController::class, 'getActiveOrdersByOperator']);

    Route::get('/order-documents', [DokumentasiOrderController::class, 'getDokumentasiBySales']);
    Route::post('/dokumentasi', [DokumentasiOrderController::class, 'store']);

    Route::get('/{orderId}', [PembayaranController::class, 'getPembayaran']);
    Route::post('/', [PembayaranController::class, 'storePembayaran']);
    Route::post('/detail', [PembayaranController::class, 'storeDetailPembayaran']);

    Route::post('/perawatan', [PerawatanController::class, 'store']);
    Route::put('/perawatan/{id}', [PerawatanController::class, 'update']);
    Route::get('/perawatan/count', [PerawatanController::class, 'count']);
    Route::get('/perawatan/all', [PerawatanController::class, 'all']);
    Route::get('/perawatan/active/public', [PerawatanController::class, 'getActivePerawatanPublic']);
    Route::get('/perawatan/active/operator/{id_operator}', [PerawatanController::class, 'getActivePerawatanByOperator']);
    Route::get('/karyawan/operator-maintenance', [PerawatanController::class, 'getOperators']);
    Route::get('/perawatan/selesai', [PerawatanController::class, 'getSelesai']);

    Route::put('/detail-order/{id}', [OrderController::class, 'updateDetailOrder']);

    Route::get('/karyawan/operator-alat', [OrderController::class, 'getOperators']);
});
