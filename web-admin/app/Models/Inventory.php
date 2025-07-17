<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Inventory extends Model
{
    use HasFactory;

    protected $fillable = ['nama', 'jenis_id', 'status', 'harga', 'pemakaian'];

    public function jenisAlat()
    {
        return $this->belongsTo(JenisAlat::class, 'jenis_id');
    }

    public function detailOrders()
    {
        return $this->hasMany(DetailOrder::class, 'id_alat');
    }

    public function detailPerawatans()
    {
        return $this->hasMany(DetailPerawatan::class, 'id_alat');
    }
}
