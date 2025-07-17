<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    protected $fillable = ['user_id', 'title', 'message', 'is_read', 'url'];

    protected $casts = [
        'is_read' => 'boolean',
    ];
}
