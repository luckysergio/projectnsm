<?php

use App\Http\Controllers\InventoryController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\OrderDocumentController;
use App\Http\Controllers\PerawatanController;
use Illuminate\Support\Facades\Route;


Route::get('/', [AuthController::class, 'login1']);
Route::post('/login1', [AuthController::class, 'authenticate']);
Route::post('/logout1', [AuthController::class, 'logout1']);

Route::get('/dashboard', function () {
    return view('pages.dashboard');
})->middleware(\App\Http\Middleware\middleware1::class);

Route::get('/Inventory', [InventoryController::class, 'index1'])->middleware(\App\Http\Middleware\middleware1::class);
Route::get('/Inventory/create1', [InventoryController::class, 'create1'])->middleware(\App\Http\Middleware\middleware1::class);
Route::get('/Inventory/{id}', [InventoryController::class, 'edit1'])->middleware(\App\Http\Middleware\middleware1::class);
Route::post('/Inventory', [InventoryController::class, 'store1'])->middleware(\App\Http\Middleware\middleware1::class);
Route::put('/Inventory/{id}', [InventoryController::class, 'update1'])->middleware(\App\Http\Middleware\middleware1::class);
Route::delete('/Inventory/{id}', [InventoryController::class, 'destroy1'])->middleware(\App\Http\Middleware\middleware1::class);

Route::get('/user', [AuthController::class, 'index'])->middleware(\App\Http\Middleware\middleware1::class);
Route::get('/user/create1', [AuthController::class, 'create1'])->middleware(\App\Http\Middleware\middleware1::class);
Route::get('/user/{id}', [AuthController::class, 'edit1'])->middleware(\App\Http\Middleware\middleware1::class);
Route::post('/user', [AuthController::class, 'create1'])->middleware(\App\Http\Middleware\middleware1::class);
Route::put('/user/{id}', [AuthController::class, 'update1'])->middleware(\App\Http\Middleware\middleware1::class);
Route::delete('/user/{id}', [AuthController::class, 'destroy1'])->middleware(\App\Http\Middleware\middleware1::class);
Route::put('/user/{id}', [AuthController::class, 'update'])->middleware(\App\Http\Middleware\middleware1::class);
Route::post('/register', [AuthController::class, 'register1'])->middleware(\App\Http\Middleware\middleware1::class);

Route::get('/order', [OrderController::class, 'index1'])->middleware(\App\Http\Middleware\middleware1::class);
Route::get('/pengiriman', [OrderController::class, 'index2'])->middleware(\App\Http\Middleware\middleware1::class);
Route::get('/histori', [OrderController::class, 'index3'])->middleware(\App\Http\Middleware\middleware1::class);
Route::get('/order-count', [OrderController::class, 'getOrderCount'])->middleware(\App\Http\Middleware\middleware1::class);
Route::get('/pengiriman-count', [OrderController::class, 'getPengirimanCount'])->middleware(\App\Http\Middleware\middleware1::class);

Route::get('/order/{id}', [OrderController::class, 'prosesorder'])->middleware(\App\Http\Middleware\middleware1::class);
Route::put('/order/{id}', [OrderController::class, 'update1'])->middleware(\App\Http\Middleware\middleware1::class);
Route::get('/jadwal/{id}', [OrderController::class, 'jadwal'])->middleware(\App\Http\Middleware\middleware1::class);
Route::put('/jadwal/{id}', [OrderController::class, 'update2'])->middleware(\App\Http\Middleware\middleware1::class);

Route::delete('/order/{id}', [OrderController::class, 'destroy1'])->middleware(\App\Http\Middleware\middleware1::class);

Route::get('/perawatan', [PerawatanController::class, 'index1'])->middleware(\App\Http\Middleware\middleware1::class);
Route::get('/perawatan/create', [PerawatanController::class, 'create'])->middleware(\App\Http\Middleware\middleware1::class);
Route::post('/perawatan', [PerawatanController::class, 'store'])->middleware(\App\Http\Middleware\middleware1::class);
Route::get('/perawatan-count', [PerawatanController::class, 'getPerawatanCount'])->middleware(\App\Http\Middleware\middleware1::class);
Route::get('/perawatan/{id}', [PerawatanController::class, 'edit'])->middleware(\App\Http\Middleware\middleware1::class);
Route::put('/perawatan/{id}', [PerawatanController::class, 'update'])->middleware(\App\Http\Middleware\middleware1::class);
Route::get('/historiperawatan', [PerawatanController::class, 'history'])->middleware(\App\Http\Middleware\middleware1::class);
Route::get('/inventory/tersedia', [InventoryController::class, 'getTersedia']);


Route::get('/order-documents', [OrderDocumentController::class, 'index'])->middleware(\App\Http\Middleware\middleware1::class);
Route::get('/search', [OrderDocumentController::class, 'index'])->middleware(\App\Http\Middleware\middleware1::class);

Route::get('/histori/pdf', [OrderController::class, 'exportPdf'])->name('histori.exportPdf');
Route::get('/historiperawatan/pdf', [PerawatanController::class, 'exportPdf'])->name('perawatan.exportPdf');
