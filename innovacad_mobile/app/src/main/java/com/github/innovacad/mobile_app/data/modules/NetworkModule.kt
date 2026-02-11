package com.github.innovacad.mobile_app.data.modules

import android.util.Log
import com.github.innovacad.mobile_app.data.plugins.AuthPlugin
import com.github.innovacad.mobile_app.data.plugins.CookiesPlugin
import com.github.innovacad.mobile_app.data.services.ApiService
import com.github.innovacad.mobile_app.data.services.UserService
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import io.ktor.client.HttpClient
import io.ktor.client.engine.cio.CIO
import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.logging.LogLevel
import javax.inject.Singleton
import io.ktor.client.plugins.logging.Logging
import io.ktor.client.plugins.logging.Logger
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json


@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {
    @Provides
    @Singleton
    fun provideHttpClient(
        userService: UserService
    ): HttpClient {
        return HttpClient(CIO) {
            install(ContentNegotiation) {
                json(Json {
                    ignoreUnknownKeys = true
                    prettyPrint = true
                    isLenient = true
                })
            }

            install(HttpTimeout) {
                requestTimeoutMillis = 30_000
                connectTimeoutMillis = 15_000
                socketTimeoutMillis = 15_000
            }

            install(Logging) {
                logger = object : Logger {
                    override fun log(message: String) {
                        Log.d("KtorClient", message)
                    }
                }
                level = LogLevel.ALL
            }

            install(CookiesPlugin) {
                this.userService = userService
            }

            install(AuthPlugin) {
                this.userService = userService
            }
        }
    }

    @Provides
    @Singleton
    fun provideApiService(client: HttpClient): ApiService {
        return ApiService(client)
    }
}