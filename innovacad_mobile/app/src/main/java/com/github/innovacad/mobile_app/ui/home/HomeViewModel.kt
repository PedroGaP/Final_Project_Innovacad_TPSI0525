package com.github.innovacad.mobile_app.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.github.innovacad.mobile_app.data.repositories.CourseRepository
import com.github.innovacad.mobile_app.data.repositories.RoomRepository
import com.github.innovacad.mobile_app.data.repositories.TraineeRepository
import com.github.innovacad.mobile_app.data.repositories.TrainerRepository
import com.github.innovacad.mobile_app.data.services.UserService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val _userService: UserService,
    private val _courseRepository: CourseRepository,
    private val _trainerRepository: TrainerRepository,
    private val _traineeRepository: TraineeRepository,
    private val _roomRepository: RoomRepository
): ViewModel() {
    val currentUser = _userService.currentUser
    val courses = _courseRepository.courses
    val trainers = _trainerRepository.trainers
    val trainees = _traineeRepository.trainees
    val rooms = _roomRepository.rooms

    init {
        loadData()
    }

    private fun loadData() {
        viewModelScope.launch {
            _courseRepository.getCourses()
            _trainerRepository.getTrainers()
            _traineeRepository.getTrainees()
            _roomRepository.getRooms()
        }
    }
}
