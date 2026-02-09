package com.github.innovacad.mobile_app.utils

import java.text.SimpleDateFormat
import java.util.*

object DateTimeUtils {
    fun getCurrentDate(): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        return sdf.format(Date())
    }

    fun formatTime(isoTimestamp: String): String {
        return try {
            val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
            val outputFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
            val date = inputFormat.parse(isoTimestamp)
            date?.let { outputFormat.format(it) } ?: isoTimestamp
        } catch (_: Exception) {
            isoTimestamp
        }
    }
}
