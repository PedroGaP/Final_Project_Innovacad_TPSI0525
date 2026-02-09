package com.github.innovacad.mobile_app.data.models

data class CourseModel(
    val courseId: String,
    val identifier: String,
    val name: String,
    val coursesModules: List<CourseModuleModel>
)