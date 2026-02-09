package com.github.innovacad.mobile_app.data.models

data class RoomModel(
    val roomId: Int,
    val roomName: String,
    val capacity: Int,
    val hasComputers: Boolean,
    val hasProjector: Boolean,
    val hasWhiteboard: Boolean,
    val hasSmartboard: Boolean
)
