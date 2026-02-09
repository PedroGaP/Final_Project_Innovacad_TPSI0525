package com.github.innovacad.mobile_app.data.dtos

import com.github.innovacad.mobile_app.data.models.TrainerModel
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class TrainerResponseDto(
    @SerialName("id")
    val userId: String,

    @SerialName("name")
    val name: String,

    @SerialName("email")
    val email: String,

    @SerialName("role")
    val role: String,

    @SerialName("image")
    val image: String?,

    @SerialName("trainer_id")
    val trainerId: String,

    @SerialName("birthday_date")
    val birthdayDate: String,

    @SerialName("is_coordinator")
    val isCoordinator: Boolean,
)

fun TrainerResponseDto.toModel(
    skills: List<TrainerSkillResponseDto>?,
    coordinatedClasses: List<String>?
): TrainerModel {
    return TrainerModel(
        id = this.userId,
        name = this.name,
        email = this.email,
        role = this.role,
        image = this.image,
        token = null,
        sessionToken = null,
        trainerId = this.trainerId,
        birthdayDate = this.birthdayDate,
        skills = skills?.map { it.toModel() },
        isCoordinator = this.isCoordinator,
        coordinatedClasses = coordinatedClasses
    )
}