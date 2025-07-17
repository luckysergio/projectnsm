<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Queue\SerializesModels;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use App\Models\Order;

class OrderCountUpdated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $orderCount;
    public $pengirimanCount;
    public $orderData;

    public function __construct($orderCount, $pengirimanCount, $orderData = null)
    {
        $this->orderCount = $orderCount;
        $this->pengirimanCount = $pengirimanCount;
        $this->orderData = $orderData;
    }

    public function broadcastOn()
    {
        return new Channel('orders');
    }

    public function broadcastAs()
    {
        return 'order.count-updated';
    }

    public function broadcastWith()
    {
        return [
            'orderCount' => $this->orderCount,
            'pengirimanCount' => $this->pengirimanCount,
            'orderData' => $this->orderData
        ];
    }
}
