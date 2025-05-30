<?php

namespace App\Http\Controllers;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\RegistrationToken;
use Illuminate\Http\Request;

class SendNotification extends Controller
{
    public function sendNotification(Request $request)
    {
        try {
            // Ambil token FCM dari parameter request
            $fcmToken = $request->input('fcm_token'); 

            // Pastikan token FCM ada
            if (!$fcmToken) {
                return response()->json(['error' => 'FCM Token is required'], 400);
            }

            // Konfigurasi Firebase untuk mengirimkan notifikasi
            $firebase = (new Factory)->withServiceAccount(storage_path('app/firebase/firebase-credentials.json'));
            $messaging = $firebase->createMessaging();

            // Membuat pesan FCM
            $message = CloudMessage::new()
                ->withNotification([
                    'title' => 'Test Notification',
                    'body' => 'This is a test notification from Laravel.'
                ])
                ->withData([
                    'key' => 'value' // Data tambahan yang bisa Anda kirimkan
                ]);

            // Mengirimkan pesan menggunakan send(), bukan sendToDevice
            $response = $messaging->send($message, $fcmToken);

            return response()->json(['success' => true, 'message' => 'Notification sent!']);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Error sending notification: ' . $e->getMessage()], 500);
        }
    }
}
