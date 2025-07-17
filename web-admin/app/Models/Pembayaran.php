<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Pembayaran extends Model
{
    use HasFactory;

    protected $fillable = ['id_order', 'tagihan'];

    public function order()
    {
        return $this->belongsTo(Order::class, 'id_order');
    }

    public function detailPembayarans()
    {
        return $this->hasMany(DetailPembayaran::class, 'id_pembayaran');
    }
}
