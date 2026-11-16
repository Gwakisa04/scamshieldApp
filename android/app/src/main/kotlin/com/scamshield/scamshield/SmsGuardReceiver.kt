package com.scamshield.scamshield

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.TelephonyManager

/**
 * Triages incoming SMS the instant they arrive, even when the app is closed:
 *
 *  - blocked scam number        -> instant scam alert + history record
 *  - saved contact, clean text  -> trusted, considered safe (silent history record)
 *  - saved contact, scam text   -> instant warning notification
 *  - unknown sender             -> API scan -> verdict notification + history record
 */
class SmsGuardReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (!GuardNative.monitoringEnabled(context)) return
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent) ?: return
        val sender = messages.firstOrNull()?.originatingAddress ?: return
        val body = messages.joinToString("") { it.messageBody ?: "" }.trim()
        if (body.isEmpty()) return

        val pending = goAsync()
        Thread {
            try {
                triage(context, sender, body)
            } catch (e: Exception) {
                // never crash the system broadcast
            } finally {
                pending.finish()
            }
        }.start()
    }

    private fun triage(context: Context, sender: String, body: String) {
        val preview = if (body.length > 80) body.substring(0, 80) + "..." else body

        if (GuardNative.isBlockedNumber(context, sender)) {
            GuardNative.appendScanRecord(context, body, "Scam", 1.0, sender)
            GuardNative.notify(
                context, GuardNative.CHANNEL_SMS, "Scam alerts",
                "Alerts when incoming SMS may be a scam",
                (sender + body).hashCode() and 0x7FFFFFFF,
                "ScamShield: Namba ya ulaghai!",
                "Mtumaji aliyehifadhi kama ulaghai: $sender\n$preview"
            )
            return
        }

        val trusted = GuardNative.contactsAllowed(context) &&
                GuardNative.isSavedContact(context, sender)
        val score = GuardNative.quickScore(body)

        if (trusted && score == 0) {
            GuardNative.appendScanRecord(context, body, "Legitimate", 0.05, sender)
            return
        }

        if (trusted && score > 0) {
            GuardNative.appendScanRecord(context, body, "Scam", 0.75, sender)
            GuardNative.notify(
                context, GuardNative.CHANNEL_SMS, "Scam alerts",
                "Alerts when incoming SMS may be a scam",
                (sender + body).hashCode() and 0x7FFFFFFF,
                "ScamShield: Tahadhari!",
                "Ujumbe kutoka kwa mtumaji uliohifadhiwa una mifumo ya ulaghai. " +
                        "Usitume pesa au PIN: $sender\n$preview"
            )
            return
        }

        val result = GuardNative.analyzeApi(body, sender)
        if (result != null) {
            val label = result.optString("label", "Legitimate")
            val scamPct = result.optInt("scam_percentage", 0)
            val isScam = result.optBoolean(
                "is_scam", label.equals("Scam", ignoreCase = true)
            )
            GuardNative.appendScanRecord(
                context, body, label, scamPct / 100.0, sender
            )
            if (isScam) {
                val title = result.optString("notification_title", "ScamShield: Ulaghai!")
                val text = result.optString("notification_body", preview)
                GuardNative.notify(
                    context, GuardNative.CHANNEL_SMS, "Scam alerts",
                    "Alerts when incoming SMS may be a scam",
                    (sender + body).hashCode() and 0x7FFFFFFF, title, text
                )
            } else {
                GuardNative.notify(
                    context, GuardNative.CHANNEL_SMS, "Scam alerts",
                    "Alerts when incoming SMS may be a scam",
                    (sender + body).hashCode() and 0x7FFFFFFF,
                    "ScamShield: Ujumbe salama",
                    "Ujumbe kutoka $sender haukugundua ulaghai ($scamPct% hatari).\n$preview"
                )
            }
        } else {
            if (score >= 2) {
                GuardNative.appendScanRecord(context, body, "Scam", 0.75, sender)
                GuardNative.notify(
                    context, GuardNative.CHANNEL_SMS, "Scam alerts",
                    "Alerts when incoming SMS may be a scam",
                    (sender + body).hashCode() and 0x7FFFFFFF,
                    "ScamShield: Tahadhari",
                    "Mtandao haupatikani, ujumbe unaonyesha mifumo ya ulaghai: $sender\n$preview"
                )
            } else {
                GuardNative.appendScanRecord(context, body, "Legitimate", 0.1, sender)
            }
        }
    }
}
