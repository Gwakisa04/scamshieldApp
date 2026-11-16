package com.scamshield.scamshield

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.provider.ContactsContract
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import org.json.JSONArray
import org.json.JSONObject

object GuardNative {
    const val CHANNEL_SMS = "sms_alerts"
    const val CHANNEL_CALLS = "call_alerts"
    private const val PREFS_NAME = "FlutterSharedPreferences"
    private const val API_URL = "https://swahbert.qecure.online/api/v1/analyze"
    private const val KEY_HISTORY = "flutter.scan_history"
    private const val KEY_NUMBERS = "flutter.scam_numbers"
    private const val KEY_MONITORING = "flutter.sms_monitoring_enabled"
    private const val KEY_CONTACTS = "flutter.contacts_allowed"

    private val patterns = listOf(
        Regex("tuma\\s*hela", RegexOption.IGNORE_CASE),
        Regex("tuma\\s*pesa", RegexOption.IGNORE_CASE),
        Regex("m[- ]?pesa", RegexOption.IGNORE_CASE),
        Regex("airtel\\s*money", RegexOption.IGNORE_CASE),
        Regex("tigo\\s*pesa", RegexOption.IGNORE_CASE),
        Regex("halipesi", RegexOption.IGNORE_CASE),
        Regex("kwa\\s*wakala", RegexOption.IGNORE_CASE),
        Regex("pin\\s*yako", RegexOption.IGNORE_CASE),
        Regex("otp|msimbo\\s*wa\\s*uthibitisho", RegexOption.IGNORE_CASE),
        Regex("hongera\\s*umes(hinda|hindi)", RegexOption.IGNORE_CASE),
        Regex("ushinde|umefuzu|zawadi\\s*ya", RegexOption.IGNORE_CASE),
        Regex("congratulations.*won", RegexOption.IGNORE_CASE),
        Regex("you\\s*(have\\s*)?won", RegexOption.IGNORE_CASE),
        Regex("claim\\s*(your|the)\\s*prize", RegexOption.IGNORE_CASE),
        Regex("gift\\s*card", RegexOption.IGNORE_CASE),
        Regex("send\\s*money", RegexOption.IGNORE_CASE),
        Regex("verify\\s*your\\s*account", RegexOption.IGNORE_CASE),
        Regex("account\\s*(is\\s*)?(blocked|suspended|frozen)", RegexOption.IGNORE_CASE),
        Regex("urgent.{0,20}(action|response)", RegexOption.IGNORE_CASE),
        Regex("click\\s*(this|the)\\s*link", RegexOption.IGNORE_CASE)
    )

    fun monitoringEnabled(context: Context): Boolean =
        prefs(context).getString(KEY_MONITORING, "false") == "true"

    fun contactsAllowed(context: Context): Boolean =
        prefs(context).getString(KEY_CONTACTS, "false") == "true"

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun digits(number: String): String = number.filter { it.isDigit() }

    fun isBlockedNumber(context: Context, number: String): Boolean {
        val raw = prefs(context).getString(KEY_NUMBERS, null) ?: return false
        val digits = digits(number)
        if (digits.isEmpty()) return false
        return try {
            val arr = JSONArray(raw)
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                val normalized = digits(obj.optString("normalizedNumber"))
                val display = digits(obj.optString("displayNumber"))
                if ((normalized.length >= 5 && digits.endsWith(normalized)) ||
                    (display.length >= 5 && digits.endsWith(display)) ||
                    (digits.length >= 5 && (normalized.endsWith(digits) || display.endsWith(digits)))
                ) return true
            }
            false
        } catch (e: Exception) {
            false
        }
    }

    fun isSavedContact(context: Context, number: String): Boolean {
        if (context.checkSelfPermission(Manifest.permission.READ_CONTACTS)
            != PackageManager.PERMISSION_GRANTED
        ) return false
        val digits = digits(number)
        if (digits.length < 5) return false
        val uri = ContactsContract.CommonDataKinds.Phone.CONTENT_URI
        context.contentResolver.query(
            uri,
            arrayOf(ContactsContract.CommonDataKinds.Phone.NUMBER),
            null, null, null
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                val saved = cursor.getString(0)?.let { digits(it) } ?: continue
                if (saved.length < 5) continue
                if (saved.endsWith(digits) || digits.endsWith(saved)) return true
            }
        }
        return false
    }

    fun quickScore(body: String): Int {
        var count = 0
        for (p in patterns) {
            if (p.containsMatchIn(body)) count++
        }
        return count
    }

    fun notify(
        context: Context,
        channelId: String,
        channelName: String,
        channelDesc: String,
        id: Int,
        title: String,
        body: String
    ) {
        if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) return
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE)
            as NotificationManager
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O &&
            manager.getNotificationChannel(channelId) == null
        ) {
            manager.createNotificationChannel(
                NotificationChannel(
                    channelId,
                    channelName,
                    NotificationManager.IMPORTANCE_MAX
                ).apply { description = channelDesc }
            )
        }
        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setAutoCancel(true)
            .build()
        NotificationManagerCompat.from(context).notify(id, notification)
    }

    fun appendScanRecord(
        context: Context,
        message: String,
        label: String,
        confidence: Double,
        phoneNumber: String?
    ) {
        try {
            val prefs = prefs(context)
            val arr = JSONArray(prefs.getString(KEY_HISTORY, "[]") ?: "[]")
            var nextId = 1
            for (i in 0 until arr.length()) {
                nextId = maxOf(nextId, arr.getJSONObject(i).optInt("id", 0) + 1)
            }
            val record = JSONObject()
                .put("id", nextId)
                .put("message", message)
                .put("label", label)
                .put("confidence", confidence)
                .put("timestamp", System.currentTimeMillis())
                .put("phoneNumber", phoneNumber ?: JSONObject.NULL)
            arr.put(record)
            val trimmed = JSONArray()
            val start = if (arr.length() > 200) arr.length() - 200 else 0
            for (i in start until arr.length()) trimmed.put(arr.getJSONObject(i))
            prefs.edit().putString(KEY_HISTORY, trimmed.toString()).apply()
        } catch (e: Exception) {
            // ignore persistence failures
        }
    }

    /** Calls the SwahBERT API. Blocking — call from a background thread. */
    fun analyzeApi(message: String, phoneNumber: String?): JSONObject? {
        return try {
            val url = java.net.URL(API_URL)
            val conn = url.openConnection() as java.net.HttpURLConnection
            conn.requestMethod = "POST"
            conn.connectTimeout = 30000
            conn.readTimeout = 90000
            conn.doOutput = true
            conn.setRequestProperty("Content-Type", "application/json; charset=utf-8")
            val body = JSONObject().put("message", message)
            if (!phoneNumber.isNullOrBlank()) body.put("phoneNumber", phoneNumber.trim())
            conn.outputStream.use { it.write(body.toString().toByteArray()) }
            val code = conn.responseCode
            val stream = if (code in 200..299) conn.inputStream else conn.errorStream
            val raw = stream.bufferedReader().use { it.readText() }
            if (code in 200..299) JSONObject(raw) else null
        } catch (e: Exception) {
            null
        }
    }
}
