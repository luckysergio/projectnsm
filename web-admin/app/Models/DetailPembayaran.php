<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class DetailPembayaran extends Model
{
    use HasFactory;

    protected $fillable = ['id_pembayaran', 'jml_dibayar', 'bukti'];

    public function pembayaran()
    {
        return $this->belongsTo(Pembayaran::class, 'id_pembayaran');
    }
}
