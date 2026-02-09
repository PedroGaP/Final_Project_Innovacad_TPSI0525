package com.github.innovacad.mobile_app.data.repositories

import com.github.innovacad.mobile_app.data.models.CourseModel
import com.github.innovacad.mobile_app.data.services.ApiService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class CourseRepository @Inject constructor(
    private val _apiService: ApiService
) {
    private val _courses = MutableStateFlow<List<CourseModel>>(emptyList())
    val courses: StateFlow<List<CourseModel>> = _courses.asStateFlow()

    suspend fun getCourses(): Result<Unit> {
        return _apiService.getCourses().fold(
            onSuccess = { courseList ->
                _courses.value = courseList
                Result.success(Unit)
            },
            onFailure = { exception ->
                Result.failure(exception)
            }
        )
    }
}
