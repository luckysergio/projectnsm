<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Karyawan extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'role_id',
        'nama',
        'nik',
    ];

    public function role()
    {
        return $this->belongsTo(Role::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class, 'id_sales');
    }

    public function perawatans()
    {
        return $this->hasMany(Perawatan::class, 'id_operator');
    }
}
