package com.github.innovacad.mobile_app.data.dtos

import com.github.innovacad.mobile_app.data.models.CourseModuleModel
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class CourseModuleResponseDto(
    @SerialName("module_name")
    val name: String,

    @SerialName("duration")
    val duration: String,

    @SerialName("sequence_course_module_id")
    val sequenceId: String?
)

fun CourseModuleResponseDto.toModel(): CourseModuleModel {
    return CourseModuleModel(
        name = this.name,
        duration = this.duration,
        sequenceId = this.sequenceId
    )
}