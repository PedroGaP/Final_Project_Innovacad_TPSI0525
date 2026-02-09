package com.github.innovacad.mobile_app.ui.trainees

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.github.innovacad.mobile_app.data.repositories.TraineeRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class TraineesViewModel @Inject constructor(
    private val _traineeRepository: TraineeRepository
): ViewModel() {
    val trainees = _traineeRepository.trainees

    init {
        loadTrainees()
    }

    private fun loadTrainees() {
        viewModelScope.launch {
            _traineeRepository.getTrainees()
        }
    }
}
