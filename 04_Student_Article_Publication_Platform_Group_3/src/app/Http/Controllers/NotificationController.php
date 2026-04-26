<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    /**
     * Mark a specific notification as read
     */
    public function markAsRead(Request $request)
    {
        $request->validate([
            'notification_id' => 'required|exists:notifications,id'
        ]);

        $user = Auth::user();
        $notification = $user->notifications()->find($request->notification_id);

        if ($notification) {
            $notification->markAsRead();
        }

        return response()->json(['success' => true]);
    }

    /**
     * Mark all notifications as read for the user
     */
    public function markAllAsRead(Request $request)
    {
        $user = Auth::user();
        $user->unreadNotifications->markAsRead();

        return response()->json(['success' => true]);
    }
}
