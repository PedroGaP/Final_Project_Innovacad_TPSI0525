package com.github.innovacad.mobile_app.data.models

data class TrainerModel(
    override val id: String,
    override val name: String,
    override val email: String,
    override val role: String,
    override val image: String?,
    override val token: String?,
    override val sessionToken: String?,
    val trainerId: String,
    val birthdayDate: String,
    val skills: List<TrainerSkillModel>?,
    val isCoordinator: Boolean,
    val coordinatedClasses: List<String>?
) : User()