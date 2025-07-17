<?php

use App\Http\Controllers\InventoryController;
use App\Http\Controllers\JabatanJenisController;
use App\Http\Controllers\KaryawanController;
use App\Http\Controllers\Web\PerawatanController;
use App\Http\Controllers\RoleController;
use App\Http\Controllers\Web\DashboardController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\web\DokumentasiOrderController;
use App\Http\Controllers\Web\OrderController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Web\AuthController;

Route::get('/', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [AuthController::class, 'login'])->name('login.process');
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

Route::middleware('admin')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

    Route::get('/order', [OrderController::class, 'index'])->name('order.index');

    Route::get('/pengiriman', [OrderController::class, 'pengiriman'])->name('order.pengiriman');

    Route::put('/order/proses/{orderId}', [OrderController::class, 'prosesPengiriman'])->name('order.proses');

    Route::delete('/order/{id}', [OrderController::class, 'destroy'])->name('order.destroy');

    Route::post('/notifications/read', [NotificationController::class, 'markAsRead'])->name('notifications.read');
    Route::post('/notifications/mark-as-read', [NotificationController::class, 'markAsRead'])->name('notifications.markAsRead');

    Route::get('/order/{id}', [OrderController::class, 'editorder']);
    Route::post('/order/{id}', [OrderController::class, 'prosesorder']);
    Route::get('/laporansewa', [OrderController::class, 'selesai'])->name('order.selesai');
    Route::get('/order/selesai/export', [OrderController::class, 'exportSelesai'])->name('order.selesai.export');

    Route::get('/pengiriman', [OrderController::class, 'pengiriman'])->name('pengiriman.index');
    Route::get('/pengiriman/{id}/edit', [OrderController::class, 'editpengiriman'])->name('pengiriman.edit');
    Route::put('/pengiriman/{id}/proses', [OrderController::class, 'prosespengiriman'])->name('pengiriman.proses');

    Route::get('/dokumentasi', [DokumentasiOrderController::class, 'index'])->name('dokumentasi.index');

    Route::prefix('perawatan')->name('perawatan.')->group(function () {
        Route::get('/', [PerawatanController::class, 'index'])->name('index');
        Route::get('/selesai', [PerawatanController::class, 'selesai'])->name('selesai');
        Route::get('/create', [PerawatanController::class, 'create'])->name('create');
        Route::post('/', [PerawatanController::class, 'store'])->name('store');
        Route::get('/{id}/edit', [PerawatanController::class, 'edit'])->name('edit');
        Route::put('/{id}', [PerawatanController::class, 'update'])->name('update');
        Route::delete('/{id}', [PerawatanController::class, 'destroy'])->name('destroy');
        Route::get('/selesai/export', [PerawatanController::class, 'exportSelesai'])->name('selesai.export');
    });

    Route::get('/karyawan', [KaryawanController::class, 'index']);
    Route::get('/karyawan/create', [KaryawanController::class, 'create']);
    Route::get('/karyawan/{id}', [KaryawanController::class, 'edit']);
    Route::post('/karyawan', [KaryawanController::class, 'store']);
    Route::put('/karyawan/{id}', [KaryawanController::class, 'update']);
    Route::delete('/karyawan/{id}', [KaryawanController::class, 'destroy']);

    Route::get('/inventori', [InventoryController::class, 'index']);
    Route::get('/inventori/create', [InventoryController::class, 'create']);
    Route::get('/inventori/{id}', [InventoryController::class, 'edit']);
    Route::post('/inventori', [InventoryController::class, 'store']);
    Route::put('/inventori/{id}', [InventoryController::class, 'update']);
    Route::delete('/inventori/{id}', [InventoryController::class, 'destroy']);

    Route::get('/jabatan', [JabatanJenisController::class, 'jabatanIndex'])->name('jabatan.index');
    Route::get('/jenis', [JabatanJenisController::class, 'jenisIndex'])->name('jenis.index');
    Route::post('/data', [JabatanJenisController::class, 'store'])->name('data.store');
    Route::put('/data/{type}/{id}', [JabatanJenisController::class, 'update'])->name('data.update');
    Route::delete('/data/{type}/{id}', [JabatanJenisController::class, 'destroy'])->name('data.destroy');
});
