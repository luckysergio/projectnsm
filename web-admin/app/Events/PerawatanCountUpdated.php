<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Queue\SerializesModels;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;

class PerawatanCountUpdated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $perawatanCount;
    public $perawatanData;

    public function __construct($perawatanCount, $perawatanData = null)
    {
        $this->perawatanCount = $perawatanCount;
        $this->perawatanData = $perawatanData;
    }

    public function broadcastOn()
    {
        return new Channel('perawatans');
    }

    public function broadcastAs()
    {
        return 'perawatan.count-updated';
    }

    public function broadcastWith()
    {
        return [
            'perawatanCount' => $this->perawatanCount,
            'perawatanData' => $this->perawatanData
        ];
    }
}
