<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::create('inventori', function (Blueprint $table) {
            $table->id();
            $table->string('nama_alat');
            $table->enum('jenis_alat', ['pompa_standart', 'pompa_longboom', 'pompa_superlong', 'pompa_kodok', 'pompa_mini']);
            $table->enum('status', ['tersedia', 'sedang_disewa', 'sedang_perawatan'])->default('tersedia');
            $table->decimal('harga', 10, 2);
            $table->integer('waktu_pemakaian')->default(0);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('inventori');
    }
};
