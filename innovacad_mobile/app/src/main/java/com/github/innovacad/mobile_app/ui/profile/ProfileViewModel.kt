package com.github.innovacad.mobile_app.ui.profile

import androidx.lifecycle.ViewModel
import com.github.innovacad.mobile_app.data.services.UserService
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val _userService: UserService
): ViewModel() {
    val currentUser = _userService.currentUser
}
