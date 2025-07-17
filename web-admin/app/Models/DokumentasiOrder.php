<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class DokumentasiOrder extends Model
{
    use HasFactory;

    protected $fillable = ['id_order', 'catatan', 'foto'];

    protected $casts = [
        'foto' => 'array', // penting agar bisa simpan banyak foto sebagai array
    ];

    public function order()
    {
        return $this->belongsTo(Order::class, 'id_order');
    }
}
