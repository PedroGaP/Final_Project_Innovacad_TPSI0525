package com.github.innovacad.mobile_app.data.repositories

import com.github.innovacad.mobile_app.data.models.TrainerModel
import com.github.innovacad.mobile_app.data.services.ApiService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class TrainerRepository @Inject constructor(
    private val _apiService: ApiService
) {
    private val _trainers = MutableStateFlow<List<TrainerModel>>(emptyList())
    val trainers: StateFlow<List<TrainerModel>> = _trainers.asStateFlow()

    suspend fun getTrainers(): Result<Unit> {
        return _apiService.getTrainers().fold(
            onSuccess = { trainerList ->
                _trainers.value = trainerList
                Result.success(Unit)
            },
            onFailure = { exception ->
                Result.failure(exception)
            }
        )
    }
}
