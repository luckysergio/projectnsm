<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sales_id')->constrained('users')->onDelete('cascade');
            $table->string('nama_pemesan');
            $table->string('alamat_pemesan');
            $table->foreignId('inventori_id')->constrained('inventori')->onDelete('cascade');
            $table->integer('total_sewa');
            $table->integer('overtime')->default(0); 
            $table->decimal('harga_sewa', 12, 2);
            $table->decimal('denda', 12, 2)->default(0); 
            $table->decimal('total_harga', 12, 2)->nullable();
            $table->enum('status_pembayaran', ['belum dibayar', 'dp', 'lunas'])->default('belum dibayar');
            $table->enum('status_order', ['belum diproses', 'diproses','persiapan', 'dikirim', 'selesai'])->nullable();
            $table->date('tgl_pemakaian')->nullable();
            $table->time('jam_mulai')->nullable();
            $table->time('jam_selesai')->nullable();
            $table->string('operator_name')->nullable();
            $table->text('catatan')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void {
        Schema::dropIfExists('orders');
    }
};
