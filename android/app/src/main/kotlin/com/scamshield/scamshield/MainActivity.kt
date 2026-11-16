package com.scamshield.scamshield

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onResume() {
        super.onResume()
        createChannels()
    }

    private fun createChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(GuardNative.CHANNEL_CALLS) == null) {
            manager.createNotificationChannel(
                NotificationChannel(
                    GuardNative.CHANNEL_CALLS,
                    "Call reminders",
                    NotificationManager.IMPORTANCE_MAX
                ).apply {
                    description = "Reminders about unknown callers"
                }
            )
        }
        if (manager.getNotificationChannel(GuardNative.CHANNEL_SMS) == null) {
            manager.createNotificationChannel(
                NotificationChannel(
                    GuardNative.CHANNEL_SMS,
                    "Scam alerts",
                    NotificationManager.IMPORTANCE_MAX
                ).apply {
                    description = "Alerts when incoming SMS may be a scam"
                }
            )
        }
    }
}
