<?php

// app/Events/DokumentasiCreated.php
namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Queue\SerializesModels;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use App\Models\DokumentasiOrder;

class DokumentasiCreated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $dokumentasi;

    public function __construct(DokumentasiOrder $dokumentasi)
    {
        $this->dokumentasi = $dokumentasi->load('order.customer');
    }

    public function broadcastOn()
    {
        return new Channel('dokumentasi');
    }

    public function broadcastAs()
    {
        return 'dokumentasi.created';
    }
}
