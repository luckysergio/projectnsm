<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class DetailPerawatan extends Model
{
    use HasFactory;

    protected $fillable = ['id_perawatan', 'id_alat', 'tgl_mulai', 'tgl_selesai', 'catatan', 'status'];

    public function perawatan()
    {
        return $this->belongsTo(Perawatan::class, 'id_perawatan');
    }

    public function alat()
    {
        return $this->belongsTo(Inventory::class, 'id_alat');
    }

    public function operator()
    {
        return $this->belongsTo(Karyawan::class, 'id_operator');
    }
}
