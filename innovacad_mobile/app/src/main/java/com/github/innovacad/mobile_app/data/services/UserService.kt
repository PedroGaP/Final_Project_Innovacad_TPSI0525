package com.github.innovacad.mobile_app.data.services

import com.github.innovacad.mobile_app.data.models.UserModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class UserService @Inject constructor() {
    private val _currentUser = MutableStateFlow<UserModel?>(null)
    val currentUser: StateFlow<UserModel?> = _currentUser.asStateFlow()

    fun setUser(user: UserModel) {
        _currentUser.value = user
    }

    fun clearUser() {
        _currentUser.value = null
    }
}