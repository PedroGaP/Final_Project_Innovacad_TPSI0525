package com.github.innovacad.mobile_app.data.models

data class TraineeModel(
    override val id: String,
    override val name: String,
    override val email: String,
    override val role: String,
    override val image: String?,
    override val token: String?,
    override val sessionToken: String?,
    val traineeId: String,
    val birthdayDate: String,
): User()