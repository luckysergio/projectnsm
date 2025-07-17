<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Role extends Model
{
    use HasFactory;

    protected $fillable = ['jabatan'];

    public function karyawans()
    {
        return $this->hasMany(Karyawan::class);
    }
}
