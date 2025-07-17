<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Order extends Model
{
    use HasFactory;

    protected $fillable = ['id_sales', 'id_pemesan'];

    public function sales()
    {
        return $this->belongsTo(Karyawan::class, 'id_sales');
    }

    public function customer()
    {
        return $this->belongsTo(Customer::class, 'id_pemesan');
    }

    public function detailOrders()
    {
        return $this->hasMany(DetailOrder::class, 'id_order');
    }

    public function pembayaran()
    {
        return $this->hasOne(Pembayaran::class, 'id_order');
    }

    public function dokumentasiOrders()
    {
        return $this->hasMany(DokumentasiOrder::class, 'id_order');
    }
}
