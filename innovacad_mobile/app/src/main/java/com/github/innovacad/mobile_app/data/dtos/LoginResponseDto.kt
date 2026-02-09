package com.github.innovacad.mobile_app.data.dtos

import com.github.innovacad.mobile_app.data.models.UserModel
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class LoginResponseDto(
    @SerialName("id")
    val id: String,

    @SerialName("name")
    val name: String,

    @SerialName("email")
    val email: String,

    @SerialName("role")
    val role: String,

    @SerialName("image")
    val image: String?,

    @SerialName("token")
    val token: String?,

    @SerialName("session_token")
    val sessionToken: String?,
)

fun LoginResponseDto.toModel(): UserModel {
    return UserModel(
        id = this.id,
        name = this.name,
        email = this.email,
        role = this.role,
        image = this.image,
        token = this.token,
        sessionToken = this.sessionToken
    )
}