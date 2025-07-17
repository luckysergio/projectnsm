<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Notification;

class NotificationController extends Controller
{
    public function markAsRead(Request $request)
    {
        Notification::where('is_read', false)->update(['is_read' => true]);

        $unreadCount = Notification::where('is_read', false)->count();

        return response()->json([
            'success' => true,
            'unreadCount' => $unreadCount
        ]);
    }
}
