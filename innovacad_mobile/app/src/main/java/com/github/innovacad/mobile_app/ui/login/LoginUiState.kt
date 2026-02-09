package com.github.innovacad.mobile_app.ui.login

import com.github.innovacad.mobile_app.data.models.UserModel

sealed class LoginUiState {
    object Idle : LoginUiState()
    object Loading : LoginUiState()
    data class Success(val user: UserModel) : LoginUiState()
    data class Error(val message: String) : LoginUiState()
}