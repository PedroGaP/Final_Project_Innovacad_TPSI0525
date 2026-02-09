package com.github.innovacad.mobile_app.data.dtos

import com.github.innovacad.mobile_app.data.models.RoomModel
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class RoomResponseDto(
    @SerialName("room_id")
    val roomId: Int,

    @SerialName("room_name")
    val roomName: String,

    @SerialName("capacity")
    val capacity: Int,

    @SerialName("has_computers")
    val hasComputers: Boolean,

    @SerialName("has_projector")
    val hasProjector: Boolean,

    @SerialName("has_whiteboard")
    val hasWhiteboard: Boolean,

    @SerialName("has_smartboard")
    val hasSmartboard: Boolean
)

fun RoomResponseDto.toModel(): RoomModel {
    return RoomModel(
        roomId = this.roomId,
        roomName = this.roomName,
        capacity = this.capacity,
        hasComputers = this.hasComputers,
        hasProjector = this.hasProjector,
        hasWhiteboard = this.hasWhiteboard,
        hasSmartboard = this.hasSmartboard
    )
}
