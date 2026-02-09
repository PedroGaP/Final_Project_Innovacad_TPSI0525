package com.github.innovacad.mobile_app.data.services

import com.github.innovacad.mobile_app.data.dtos.CourseResponseDto
import com.github.innovacad.mobile_app.data.dtos.LoginRequestDto
import com.github.innovacad.mobile_app.data.dtos.LoginResponseDto
import com.github.innovacad.mobile_app.data.dtos.RoomBusySlotResponseDto
import com.github.innovacad.mobile_app.data.dtos.RoomResponseDto
import com.github.innovacad.mobile_app.data.dtos.TraineeResponseDto
import com.github.innovacad.mobile_app.data.dtos.TrainerResponseDto
import com.github.innovacad.mobile_app.data.dtos.TrainerSkillResponseDto
import com.github.innovacad.mobile_app.data.dtos.toModel
import com.github.innovacad.mobile_app.data.models.CourseModel
import com.github.innovacad.mobile_app.data.models.RoomBusySlotModel
import com.github.innovacad.mobile_app.data.models.RoomModel
import com.github.innovacad.mobile_app.data.models.TraineeModel
import com.github.innovacad.mobile_app.data.models.TrainerModel
import com.github.innovacad.mobile_app.data.models.UserModel
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.plugins.HttpRequestTimeoutException
import io.ktor.client.request.get
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.http.ContentType
import io.ktor.http.HttpStatusCode
import io.ktor.http.contentType
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.net.ConnectException
import java.net.UnknownHostException
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ApiService @Inject constructor(
    private val _client: HttpClient
) {
    private val _baseUrl = "http://10.0.2.2:8080"

    suspend fun login(dto: LoginRequestDto): Result<UserModel> {
        try {
            val response = _client.post("${_baseUrl}/sign/in") {
                contentType(ContentType.Application.Json)
                setBody(dto)
            }
            val statusCode = response.status

            return if (statusCode != HttpStatusCode.OK) {
                Result.failure(Error("Login Failed!"))
            } else {
                Result.success(response.body<LoginResponseDto>().toModel())
            }
        } catch (_: HttpRequestTimeoutException) {
            return Result.failure(Exception("The request timed out!"))
        } catch (_: ConnectException) {
            return Result.failure(Exception("Cannot connect to the api!"))
        } catch (_: UnknownHostException) {
            return Result.failure(Exception("Cannot reach the api!"))
        } catch (e: Exception) {
            return Result.failure(e)
        }
    }

    suspend fun getCourses(): Result<List<CourseModel>> {
        return try {
            val response = _client.get("$_baseUrl/courses")
            val courses = response.body<List<CourseResponseDto>>().map { it.toModel() }
            Result.success(courses)
        } catch (_: HttpRequestTimeoutException) {
            Result.failure(Exception("The request timed out!"))
        } catch (_: ConnectException) {
            Result.failure(Exception("Cannot connect to the api!"))
        } catch (_: UnknownHostException) {
            Result.failure(Exception("Cannot reach the api!"))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getTrainers(): Result<List<TrainerModel>> {
        return try {
            val response = _client.get("$_baseUrl/trainers")
            val responseTrainers = response.body<List<TrainerResponseDto>>()

            val trainers: List<TrainerModel> = coroutineScope {
                responseTrainers.map { trainer ->
                    async {
                        val skillsResponse = _client.get("$_baseUrl/trainers/skills/${trainer.trainerId}")
                        val skills = skillsResponse.body<List<TrainerSkillResponseDto>>()

                        val coordinatedClassesResponse = _client.get("$_baseUrl/trainers/coordinated-classes/${trainer.trainerId}")
                        val coordinatedClasses = coordinatedClassesResponse.body<List<String>>()

                        trainer.toModel(skills, coordinatedClasses)
                    }
                }.awaitAll()
            }

            Result.success(trainers)
        } catch (_: HttpRequestTimeoutException) {
            Result.failure(Exception("The request timed out!"))
        } catch (_: ConnectException) {
            Result.failure(Exception("Cannot connect to the api!"))
        } catch (_: UnknownHostException) {
            Result.failure(Exception("Cannot reach the api!"))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getTrainees(): Result<List<TraineeModel>> {
        return try {
            val response = _client.get("$_baseUrl/trainees")
            val trainees = response.body<List<TraineeResponseDto>>().map { it.toModel() }
            Result.success(trainees)
        } catch (_: HttpRequestTimeoutException) {
            Result.failure(Exception("The request timed out!"))
        } catch (_: ConnectException) {
            Result.failure(Exception("Cannot connect to the api!"))
        } catch (_: UnknownHostException) {
            Result.failure(Exception("Cannot reach the api!"))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getRooms(): Result<List<RoomModel>> {
        return try {
            val response = _client.get("$_baseUrl/rooms")
            val rooms = response.body<List<RoomResponseDto>>().map { it.toModel() }
            Result.success(rooms)
        } catch (_: HttpRequestTimeoutException) {
            Result.failure(Exception("The request timed out!"))
        } catch (_: ConnectException) {
            Result.failure(Exception("Cannot connect to the api!"))
        } catch (_: UnknownHostException) {
            Result.failure(Exception("Cannot reach the api!"))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun checkRoomAvailability(
        roomId: String,
        date: String
    ): Result<List<RoomBusySlotModel>> {
        try {
            val response = _client.get("$_baseUrl/rooms/$roomId/availability/$date")
            
            val statusCode = response.status
            
            return if (statusCode != HttpStatusCode.OK) {
                Result.failure(Error("Failed to fetch room availability"))
            } else {
                val busySlots = response.body<List<RoomBusySlotResponseDto>>()
                Result.success(busySlots.map { it.toModel() })
            }
        } catch (_: HttpRequestTimeoutException) {
            return Result.failure(Exception("The request timed out!"))
        } catch (_: ConnectException) {
            return Result.failure(Exception("Cannot connect to the api!"))
        } catch (_: UnknownHostException) {
            return Result.failure(Exception("Cannot reach the api!"))
        } catch (e: Exception) {
            return Result.failure(e)
        }
    }
}
