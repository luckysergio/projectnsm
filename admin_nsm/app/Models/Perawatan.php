<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Perawatan extends Model
{
    use HasFactory;

    protected $table = 'perawatan';

    protected $fillable = [
        'inventori_id',
        'tanggal_mulai',
        'tanggal_selesai',
        'status_perawatan',
        'operator_name',
        'catatan',
    ];

    protected $appends = ['inventori_name'];

    // Relasi ke Inventori
    public function inventori()
    {
        return $this->belongsTo(Inventory::class, 'inventori_id');
    }

    // **Accessor untuk Nama Inventori (Alat) dengan Fallback**
    public function getInventoriNameAttribute() {
        return $this->inventori?->nama_alat ?? 'Unknown Alat';
    }

}
