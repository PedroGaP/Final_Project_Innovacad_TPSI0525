package com.github.innovacad.mobile_app.ui.rooms

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.github.innovacad.mobile_app.data.models.RoomBusySlotModel
import com.github.innovacad.mobile_app.data.models.RoomModel
import com.github.innovacad.mobile_app.data.repositories.RoomRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class RoomAvailabilityViewModel @Inject constructor(
    private val _roomRepository: RoomRepository
) : ViewModel() {

    val rooms: StateFlow<List<RoomModel>> = _roomRepository.rooms

    private val _busySlots = MutableStateFlow<List<RoomBusySlotModel>>(emptyList())
    val busySlots: StateFlow<List<RoomBusySlotModel>> = _busySlots.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error.asStateFlow()

    init {
        loadRooms()
    }

    private fun loadRooms() {
        viewModelScope.launch {
            _roomRepository.getRooms()
        }
    }

    fun checkAvailability(roomId: Int, dateString: String) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null

            _roomRepository.checkAvailability(roomId, dateString).fold(
                onSuccess = { _busySlots.value = it },
                onFailure = { _error.value = it.message ?: "Failed to fetch availability" }
            )

            _isLoading.value = false
        }
    }
}
