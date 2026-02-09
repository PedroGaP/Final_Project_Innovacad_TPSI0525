package com.github.innovacad.mobile_app.data.dtos

import com.github.innovacad.mobile_app.data.models.CourseModel
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class CourseResponseDto(
    @SerialName("course_id")
    val courseId: String,

    @SerialName("identifier")
    val identifier: String,

    @SerialName("name")
    val name: String,

    @SerialName("modules")
    val coursesModules: List<CourseModuleResponseDto>
)

fun CourseResponseDto.toModel(): CourseModel {
    return CourseModel(
        courseId = this.courseId,
        identifier = this.identifier,
        name = this.name,
        coursesModules = this.coursesModules.map { it.toModel() }
    )
}

