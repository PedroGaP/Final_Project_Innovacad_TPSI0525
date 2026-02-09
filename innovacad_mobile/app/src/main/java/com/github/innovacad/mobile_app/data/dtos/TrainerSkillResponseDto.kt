package com.github.innovacad.mobile_app.data.dtos

import com.github.innovacad.mobile_app.data.models.TrainerSkillModel
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class TrainerSkillResponseDto(
    @SerialName("name")
    val name: String,

    @SerialName("competence_level")
    val competenceLevel: String
)

fun TrainerSkillResponseDto.toModel(): TrainerSkillModel {
    return TrainerSkillModel(
        name = this.name,
        competenceLevel = this.competenceLevel
    )
}
