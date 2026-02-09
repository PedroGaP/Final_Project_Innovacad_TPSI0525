package com.github.innovacad.mobile_app.data.repositories

import com.github.innovacad.mobile_app.data.models.RoomBusySlotModel
import com.github.innovacad.mobile_app.data.models.RoomModel
import com.github.innovacad.mobile_app.data.services.ApiService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class RoomRepository @Inject constructor(
    private val _apiService: ApiService
) {
    private val _rooms = MutableStateFlow<List<RoomModel>>(emptyList())
    val rooms: StateFlow<List<RoomModel>> = _rooms.asStateFlow()

    suspend fun getRooms(): Result<Unit> {
        return _apiService.getRooms().fold(
            onSuccess = { roomList ->
                _rooms.value = roomList
                Result.success(Unit)
            },
            onFailure = { exception ->
                Result.failure(exception)
            }
        )
    }

    suspend fun checkAvailability(
        roomId: Int,
        dateString: String
    ): Result<List<RoomBusySlotModel>> {
        return _apiService.checkRoomAvailability(roomId.toString(), dateString)
    }
}
