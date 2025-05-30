<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Inventory extends Model
{
    use HasFactory;

    protected $table = 'inventori';

    protected $fillable = [
        'nama_alat',
        'jenis_alat',
        'status',
        'waktu_pemakaian',
        'harga'
    ];

    /**
     * Relasi dengan Orders: Satu alat bisa digunakan dalam banyak order.
     */
    public function orders()
    {
        return $this->hasMany(Order::class, 'inventori_id');
    }

    /**
     * Relasi dengan Perawatan: Satu alat bisa memiliki banyak riwayat perawatan.
     */
    public function perawatan()
    {
        return $this->hasMany(Perawatan::class, 'inventori_id');
    }
}
