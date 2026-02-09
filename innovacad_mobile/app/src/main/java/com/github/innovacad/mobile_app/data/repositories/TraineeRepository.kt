package com.github.innovacad.mobile_app.data.repositories

import com.github.innovacad.mobile_app.data.models.TraineeModel
import com.github.innovacad.mobile_app.data.services.ApiService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class TraineeRepository @Inject constructor(
    private val _apiService: ApiService
) {
    private val _trainees = MutableStateFlow<List<TraineeModel>>(emptyList())
    val trainees: StateFlow<List<TraineeModel>> = _trainees.asStateFlow()

    suspend fun getTrainees(): Result<Unit> {
        return _apiService.getTrainees().fold(
            onSuccess = { traineeList ->
                _trainees.value = traineeList
                Result.success(Unit)
            },
            onFailure = { exception ->
                Result.failure(exception)
            }
        )
    }
}
