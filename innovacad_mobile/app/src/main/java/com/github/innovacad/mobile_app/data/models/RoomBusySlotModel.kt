package com.github.innovacad.mobile_app.data.models

data class RoomBusySlotModel(
    val scheduleId: String,
    val startTime: String,
    val endTime: String,
    val moduleName: String?
)
