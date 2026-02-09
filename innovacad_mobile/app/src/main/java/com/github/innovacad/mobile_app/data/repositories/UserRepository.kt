package com.github.innovacad.mobile_app.data.repositories

import com.github.innovacad.mobile_app.data.dtos.LoginRequestDto
import com.github.innovacad.mobile_app.data.models.UserModel
import com.github.innovacad.mobile_app.data.services.ApiService
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class UserRepository @Inject constructor(
    private val _apiService: ApiService
) {
    suspend fun login(email: String, password: String): Result<UserModel> {
        return _apiService.login(LoginRequestDto(email, password))
    }
}