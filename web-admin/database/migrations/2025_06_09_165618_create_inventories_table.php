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
        Schema::create('inventories', function (Blueprint $table) {
            $table->id();
            $table->string('nama',50);
            $table->unsignedBigInteger('jenis_id');
            $table->enum('status',['tersedia', 'disewa', 'perawatan'])->default('tersedia');
            $table->decimal('harga', 20,2);
            $table->integer('pemakaian');
            $table->timestamps();

            $table->foreign('jenis_id')->references('id')->on('jenis_alats')->onDelete('cascade');

        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('inventories');
    }
};
