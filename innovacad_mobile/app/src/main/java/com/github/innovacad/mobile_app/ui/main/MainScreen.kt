package com.github.innovacad.mobile_app.ui.main

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.MenuBook
import androidx.compose.material.icons.automirrored.outlined.MenuBook
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.MeetingRoom
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.School
import androidx.compose.material.icons.outlined.AccountCircle
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.MeetingRoom
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.School
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import com.github.innovacad.mobile_app.ui.courses.CoursesScreen
import com.github.innovacad.mobile_app.ui.home.HomeScreen
import com.github.innovacad.mobile_app.ui.profile.ProfileScreen
import com.github.innovacad.mobile_app.ui.rooms.RoomAvailabilityScreen
import com.github.innovacad.mobile_app.ui.trainees.TraineesScreen
import com.github.innovacad.mobile_app.ui.trainers.TrainersScreen

data class BottomNavItem(
    val title: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector
)

@Composable
fun MainScreen(
    onLogout: () -> Unit
) {
    var selectedItemIndex by remember { mutableIntStateOf(0) }

    val items = listOf(
        BottomNavItem(
            title = "Home",
            selectedIcon = Icons.Filled.Home,
            unselectedIcon = Icons.Outlined.Home
        ),
        BottomNavItem(
            title = "Courses",
            selectedIcon = Icons.AutoMirrored.Filled.MenuBook,
            unselectedIcon = Icons.AutoMirrored.Outlined.MenuBook
        ),
        BottomNavItem(
            title = "Trainers",
            selectedIcon = Icons.Filled.School,
            unselectedIcon = Icons.Outlined.School
        ),
        BottomNavItem(
            title = "Trainees",
            selectedIcon = Icons.Filled.Person,
            unselectedIcon = Icons.Outlined.Person
        ),
        BottomNavItem(
            title = "Rooms",
            selectedIcon = Icons.Filled.MeetingRoom,
            unselectedIcon = Icons.Outlined.MeetingRoom
        ),
        BottomNavItem(
            title = "Profile",
            selectedIcon = Icons.Filled.AccountCircle,
            unselectedIcon = Icons.Outlined.AccountCircle
        )
    )

    Scaffold(
        bottomBar = {
            NavigationBar {
                items.forEachIndexed { index, item ->
                    NavigationBarItem(
                        selected = selectedItemIndex == index,
                        onClick = { selectedItemIndex = index },
                        label = { Text(text = item.title) },
                        icon = {
                            Icon(
                                imageVector = if (selectedItemIndex == index) {
                                    item.selectedIcon
                                } else {
                                    item.unselectedIcon
                                },
                                contentDescription = item.title
                            )
                        }
                    )
                }
            }
        }
    ) { paddingValues ->
        Box(modifier = Modifier.padding(paddingValues)) {
            when (selectedItemIndex) {
                0 -> HomeScreen()
                1 -> CoursesScreen()
                2 -> TrainersScreen()
                3 -> TraineesScreen()
                4 -> RoomAvailabilityScreen()
                5 -> ProfileScreen(onLogout = onLogout)
            }
        }
    }
}
