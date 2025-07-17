<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Perawatan extends Model
{
    use HasFactory;

    protected $fillable = ['id_operator'];

    public function operator()
    {
        return $this->belongsTo(Karyawan::class, 'id_operator');
    }

    public function detailPerawatans()
    {
        return $this->hasMany(DetailPerawatan::class, 'id_perawatan');
    }
}
