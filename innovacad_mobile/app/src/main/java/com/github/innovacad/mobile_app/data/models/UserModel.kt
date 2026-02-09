package com.github.innovacad.mobile_app.data.models

abstract class User {
    abstract val id: String
    abstract val name: String
    abstract val email: String
    abstract val role: String
    abstract val image: String?
    abstract val token: String?
    abstract val sessionToken: String?
}

data class UserModel(
    override val id: String,
    override val name: String,
    override val email: String,
    override val role: String,
    override val image: String?,
    override val token: String?,
    override val sessionToken: String?,
) : User()