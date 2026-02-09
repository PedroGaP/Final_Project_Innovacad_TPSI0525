package com.github.innovacad.mobile_app.data.dtos

import com.github.innovacad.mobile_app.data.models.RoomBusySlotModel
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class RoomBusySlotResponseDto(
    @SerialName("schedule_id")
    val scheduleId: String,

    @SerialName("start_time")
    val startTime: String,

    @SerialName("end_time")
    val endTime: String,

    @SerialName("module_name")
    val moduleName: String?
)

fun RoomBusySlotResponseDto.toModel(): RoomBusySlotModel {
    return RoomBusySlotModel(
        scheduleId = this.scheduleId,
        startTime = this.startTime,
        endTime = this.endTime,
        moduleName = this.moduleName
    )
}
