<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Customer extends Model
{
    use HasFactory;

    protected $fillable = ['nama', 'instansi'];

    public function orders()
    {
        return $this->hasMany(Order::class, 'id_pemesan');
    }
}
