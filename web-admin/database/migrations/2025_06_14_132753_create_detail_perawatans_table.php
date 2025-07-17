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
        Schema::create('detail_perawatans', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('id_perawatan');
            $table->unsignedBigInteger('id_alat');
            $table->date('tgl_mulai');
            $table->date('tgl_selesai')->nullable();
            $table->text('catatan')->nullable();
            $table->enum('status',['pending','proses','selesai'])->default('pending');
            $table->timestamps();

            $table->foreign('id_perawatan')->references('id')->on('perawatans')->onDelete('cascade');
            $table->foreign('id_alat')->references('id')->on('inventories')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('detail_perawatans');
    }
};
