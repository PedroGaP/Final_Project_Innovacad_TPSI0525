package com.github.innovacad.mobile_app.ui.rooms

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import com.github.innovacad.mobile_app.data.models.RoomBusySlotModel
import com.github.innovacad.mobile_app.data.models.RoomModel
import com.github.innovacad.mobile_app.utils.DateTimeUtils

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RoomAvailabilityScreen(
    viewModel: RoomAvailabilityViewModel = hiltViewModel()
) {
    val rooms by viewModel.rooms.collectAsState()
    val busySlots by viewModel.busySlots.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val error by viewModel.error.collectAsState()

    var selectedRoom by remember { mutableStateOf<RoomModel?>(null) }
    var selectedDate by remember { mutableStateOf(DateTimeUtils.getCurrentDate()) }
    var showDatePicker by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Room Availability") }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp)
        ) {
            // Room Selector
            RoomDropdown(
                rooms = rooms,
                selectedRoom = selectedRoom,
                onRoomSelected = { selectedRoom = it }
            )

            Spacer(modifier = Modifier.height(16.dp))

            OutlinedButton(
                onClick = { showDatePicker = true },
                modifier = Modifier.fillMaxWidth()
            ) {
                Icon(Icons.Default.DateRange, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text(selectedDate)
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Check Availability Button
            Button(
                onClick = {
                    selectedRoom?.let { room ->
                        viewModel.checkAvailability(room.roomId, selectedDate)
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                enabled = selectedRoom != null && !isLoading
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(20.dp),
                        color = MaterialTheme.colorScheme.onPrimary
                    )
                } else {
                    Text("Check Availability")
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Error Message
            error?.let {
                Card(
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.errorContainer
                    ),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier.padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            Icons.Default.Warning,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.error
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(it, color = MaterialTheme.colorScheme.error)
                    }
                }
                Spacer(modifier = Modifier.height(16.dp))
            }

            // Results
            if (selectedRoom != null && busySlots.isNotEmpty()) {
                Text(
                    "Busy Time Slots",
                    style = MaterialTheme.typography.titleMedium
                )
                Spacer(modifier = Modifier.height(8.dp))

                LazyColumn(
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    items(busySlots) { slot ->
                        BusySlotCard(slot)
                    }
                }
            } else if (selectedRoom != null && !isLoading && error == null) {
                Card(
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.primaryContainer
                    ),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier.padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            Icons.Default.CheckCircle,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.primary
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            "Room is available all day!",
                            color = MaterialTheme.colorScheme.onPrimaryContainer
                        )
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RoomDropdown(
    rooms: List<RoomModel>,
    selectedRoom: RoomModel?,
    onRoomSelected: (RoomModel) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }

    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = it }
    ) {
        OutlinedTextField(
            value = selectedRoom?.roomName ?: "Select a room",
            onValueChange = {},
            readOnly = true,
            trailingIcon = {
                ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded)
            },
            modifier = Modifier
                .fillMaxWidth()
                .menuAnchor(),
            label = { Text("Room") }
        )

        ExposedDropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            rooms.forEach { room ->
                DropdownMenuItem(
                    text = {
                        Column {
                            Text(room.roomName, style = MaterialTheme.typography.bodyLarge)
                            Text(
                                "Capacity: ${room.capacity}",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    },
                    onClick = {
                        onRoomSelected(room)
                        expanded = false
                    }
                )
            }
        }
    }
}

@Composable
fun BusySlotCard(slot: RoomBusySlotModel) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Default.Schedule,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    DateTimeUtils.formatTime(slot.startTime) + " - " + DateTimeUtils.formatTime(slot.endTime),
                    style = MaterialTheme.typography.titleMedium
                )
            }

            slot.moduleName?.let {
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Default.Book,
                        contentDescription = null,
                        modifier = Modifier.size(20.dp),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        it,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }
    }
}
