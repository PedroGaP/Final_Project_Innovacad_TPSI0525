package com.github.innovacad.mobile_app.data.plugins

import com.github.innovacad.mobile_app.data.services.UserService
import io.ktor.client.HttpClient
import io.ktor.client.plugins.HttpClientPlugin
import io.ktor.client.request.HttpRequestPipeline
import io.ktor.client.request.bearerAuth
import io.ktor.util.AttributeKey

class AuthPlugin (
    private val _userService: UserService
) {
    class Config {
        var userService: UserService? = null
    }

    companion object : HttpClientPlugin<Config, AuthPlugin> {
        override val key = AttributeKey<AuthPlugin>("AuthPlugin")

        override fun prepare(block: AuthPlugin.Config.() -> Unit): AuthPlugin {
            val config = Config().apply(block)
            return AuthPlugin(config.userService!!)
        }

        override fun install(plugin: AuthPlugin, scope: HttpClient) {
            scope.requestPipeline.intercept(HttpRequestPipeline.State) {
                plugin._userService.currentUser.value?.let {
                    if (it.token != null) {
                        context.bearerAuth(it.token)
                    }
                }
            }
        }
    }
}