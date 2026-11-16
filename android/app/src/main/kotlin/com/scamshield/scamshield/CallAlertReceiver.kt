package com.scamshield.scamshield

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager

/**
 * Reminds the user instantly when a call rings from an unsaved number.
 * Runs even when the app is closed (manifest-registered system receiver).
 */
class CallAlertReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (!GuardNative.monitoringEnabled(context)) return
        val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE) ?: return
        if (state != TelephonyManager.EXTRA_STATE_RINGING) return
        val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
        if (number.isNullOrBlank()) return

        if (GuardNative.isSavedContact(context, number)) return

        val flagged = GuardNative.isBlockedNumber(context, number)

        val pending = goAsync()
        Thread {
            try {
                if (flagged) {
                    GuardNative.notify(
                        context, GuardNative.CHANNEL_CALLS, "Call reminders",
                        "Reminders about unknown callers",
                        GuardNative.digits(number).hashCode() and 0x7FFFFFFF,
                        "ScamShield: Namba ya ulaghai inapiga!",
                        "Wito kutoka kwa namba iliyoripotiwa na jamii: $number.\n" +
                                "Usitoe PIN, OTP au pesa kwa wito huu."
                    )
                } else {
                    GuardNative.notify(
                        context, GuardNative.CHANNEL_CALLS, "Call reminders",
                        "Reminders about unknown callers",
                        GuardNative.digits(number).hashCode() and 0x7FFFFFFF,
                        "ScamShield: Unknown caller",
                        "Wito kutoka kwa namba isiyohifadhiwa: $number.\n" +
                                "Usitoe PIN au msimbo kwa wito huu. Kuwa makini."
                    )
                }
            } catch (e: Exception) {
                // ignore
            } finally {
                pending.finish()
            }
        }.start()
    }
}
