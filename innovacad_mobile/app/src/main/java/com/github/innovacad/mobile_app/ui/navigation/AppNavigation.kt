package com.github.innovacad.mobile_app.ui.navigation

import androidx.compose.runtime.Composable
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.github.innovacad.mobile_app.ui.login.LoginScreen
import com.github.innovacad.mobile_app.ui.login.LoginViewModel
import com.github.innovacad.mobile_app.ui.main.MainScreen

@Composable
fun AppNavigation() {
    val navController = rememberNavController()

    NavHost(
        navController = navController,
        startDestination = "login"
    ) {
        composable("login") {
            val loginViewModel: LoginViewModel = hiltViewModel()
            LoginScreen(
                viewModel = loginViewModel,
                onLoginSuccess = {
                    navController.navigate("main") {
                        popUpTo("login") {
                            inclusive = true
                        }
                    }
                }
            )
        }

        composable("main") {
            val loginViewModel: LoginViewModel = hiltViewModel()
            MainScreen(
                onLogout = {
                    loginViewModel.logout()
                    navController.navigate("login") {
                        popUpTo("main") {
                            inclusive = true
                        }
                    }
                }
            )
        }
    }
}