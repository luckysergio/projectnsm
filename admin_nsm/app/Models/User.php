<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use PHPOpenSourceSaver\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'nik',
        'role',
        'email',
        'phone', // Tambahkan kolom phone
        'profile_photo', // Tambahkan kolom foto profil
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    public function isSales(): bool
    {
        return $this->role === 'sales';
    }

    public function isPjAlat(): bool
    {
        return $this->role === 'pj_alat';
    }

    // Relasi dengan order sebagai Sales
    public function salesOrders()
    {
        return $this->hasMany(Order::class, 'sales_id');
    }


    // JWT Functions
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims()
    {
        return [];
    }

    public function orderDocuments()
    {
        return $this->hasMany(OrderDocument::class);
    }


}
