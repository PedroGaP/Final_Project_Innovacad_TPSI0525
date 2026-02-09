package com.github.innovacad.mobile_app.data.plugins

import com.github.innovacad.mobile_app.data.services.UserService
import io.ktor.client.HttpClient
import io.ktor.client.plugins.HttpClientPlugin
import io.ktor.client.request.HttpRequestPipeline
import io.ktor.client.request.cookie
import io.ktor.util.AttributeKey

class CookiesPlugin(
    private val _userService: UserService
) {
    class Config {
        var userService: UserService? = null
    }

    companion object : HttpClientPlugin<Config, CookiesPlugin> {
        override val key = AttributeKey<CookiesPlugin>("CookiesPlugin")

        override fun prepare(block: Config.() -> Unit): CookiesPlugin {
            val config = Config().apply(block)
            return CookiesPlugin(config.userService!!)
        }

        override fun install(plugin: CookiesPlugin, scope: HttpClient) {
            scope.requestPipeline.intercept(HttpRequestPipeline.State) {
                plugin._userService.currentUser.value?.let {
                    if (it.token != null && it.sessionToken != null) {
                        context.cookie(name="better-auth.session_token", value = it.sessionToken)
                        context.cookie(name="better-auth.session_data", value = it.token)
                    }
                }
            }
        }
    }
}