package com.github.innovacad.mobile_app.data.dtos

import com.github.innovacad.mobile_app.data.models.TraineeModel
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class TraineeResponseDto(
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

    @SerialName("trainee_id")
    val traineeId: String,

    @SerialName("birthday_date")
    val birthdayDate: String,
)

fun TraineeResponseDto.toModel(): TraineeModel {
    return TraineeModel(
        id = this.userId,
        name = this.name,
        email = this.email,
        role = this.role,
        image = this.image,
        token = null,
        sessionToken = null,
        traineeId = this.traineeId,
        birthdayDate = this.birthdayDate,
    )
}