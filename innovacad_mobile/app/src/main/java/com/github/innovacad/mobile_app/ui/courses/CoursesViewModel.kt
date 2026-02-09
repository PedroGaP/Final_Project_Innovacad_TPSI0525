package com.github.innovacad.mobile_app.ui.courses

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.github.innovacad.mobile_app.data.repositories.CourseRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class CoursesViewModel @Inject constructor(
    private val _courseRepository: CourseRepository
): ViewModel() {
    val courses = _courseRepository.courses

    init {
        loadCourses()
    }

    private fun loadCourses() {
        viewModelScope.launch {
            _courseRepository.getCourses()
        }
    }
}
