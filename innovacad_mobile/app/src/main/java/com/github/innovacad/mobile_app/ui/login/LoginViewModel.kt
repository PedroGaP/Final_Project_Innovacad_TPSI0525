package com.github.innovacad.mobile_app.ui.login

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.github.innovacad.mobile_app.data.repositories.UserRepository
import com.github.innovacad.mobile_app.data.services.UserService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class LoginViewModel @Inject constructor(
    private val _userRepository: UserRepository,
    private val _userService: UserService
): ViewModel() {
    private val _uiState = MutableStateFlow<LoginUiState>(LoginUiState.Idle)
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    fun login(email: String, password: String) {
        if (email.isBlank() || password.isBlank()) {
            _uiState.value = LoginUiState.Error("Email and Password are required!")
            return
        }

        viewModelScope.launch {
            _uiState.value = LoginUiState.Loading

            _userRepository.login(email, password)
                .onSuccess { user ->
                    _uiState.value = LoginUiState.Success(user)
                    _userService.setUser(user)
                }
                .onFailure { error ->
                   _uiState.value = LoginUiState.Error(error.message ?: "Login Failed!")
                }
        }
    }

    fun logout() {
        _uiState.value = LoginUiState.Idle
        _userService.clearUser()
    }
}