<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DetailOrder extends Model
{
    protected $fillable = [
        'id_order',
        'id_alat',
        'id_operator',
        'alamat',
        'tgl_mulai',
        'jam_mulai',
        'tgl_selesai',
        'jam_selesai',
        'status',
        'catatan',
        'harga_sewa',
        'total_sewa',
    ];

    public function alat()
    {
        return $this->belongsTo(Inventory::class, 'id_alat'); 
    }

    public function order()
    {
        return $this->belongsTo(Order::class, 'id_order'); 
    }

    public function operator()
    {
        return $this->belongsTo(Karyawan::class, 'id_operator'); 
    }
}
