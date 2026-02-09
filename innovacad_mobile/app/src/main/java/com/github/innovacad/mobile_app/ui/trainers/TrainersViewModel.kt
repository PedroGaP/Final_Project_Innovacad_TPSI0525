package com.github.innovacad.mobile_app.ui.trainers

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.github.innovacad.mobile_app.data.repositories.TrainerRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class TrainersViewModel @Inject constructor(
    private val _trainerRepository: TrainerRepository
): ViewModel() {
    val trainers = _trainerRepository.trainers

    init {
        loadTrainers()
    }

    private fun loadTrainers() {
        viewModelScope.launch {
            _trainerRepository.getTrainers()
        }
    }
}
