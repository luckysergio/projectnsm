<?php

namespace App\Providers;

use App\Models\DetailOrder;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\View;
use App\Models\Notification;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot()
    {
        View::composer('*', function ($view) {
            $notificationCount = Notification::where('is_read', false)->count();
            $latestNotifications = Notification::orderBy('created_at', 'desc')->take(5)->get();

            $view->with([
                'notificationCount' => $notificationCount,
                'latestNotifications' => $latestNotifications,
            ]);
        });
    }
}
