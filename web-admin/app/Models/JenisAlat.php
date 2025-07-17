<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class JenisAlat extends Model
{
    use HasFactory;

    protected $fillable = ['nama'];

    public function inventories()
    {
        return $this->hasMany(Inventory::class, 'jenis_id');
    }
}
