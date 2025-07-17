<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('detail_orders', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('id_order');
            $table->unsignedBigInteger('id_alat');
            $table->unsignedBigInteger('id_operator')->nullable();
            $table->text('alamat');
            $table->date('tgl_mulai');
            $table->time('jam_mulai');
            $table->date('tgl_selesai')->nullable();
            $table->time('jam_selesai')->nullable();
            $table->enum('status',['pending','proses','persiapan','dikirim','selesai'])->default('pending');
            $table->text('catatan')->nullable();
            $table->bigInteger('harga_sewa');
            $table->integer('total_sewa');
            $table->timestamps();

            $table->foreign('id_order')->references('id')->on('orders')->onDelete('cascade');
            $table->foreign('id_operator')->references('id')->on('karyawans')->onDelete('cascade');
            $table->foreign('id_alat')->references('id')->on('inventories')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('detail_orders');
    }
};
