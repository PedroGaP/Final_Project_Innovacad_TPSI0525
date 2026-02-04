class StatisticsDto {
  final int totalFinishedClasses;
  final int totalOngoingClasses;
  final int totalActiveTrainees;
  final List<Map<String, dynamic>> coursesByArea;
  final List<Map<String, dynamic>> topTrainers;

  StatisticsDto({
    required this.totalFinishedClasses,
    required this.totalOngoingClasses,
    required this.totalActiveTrainees,
    required this.coursesByArea,
    required this.topTrainers,
  });

  Map<String, dynamic> toJson() => {
    'total_finished_classes': totalFinishedClasses,
    'total_ongoing_classes': totalOngoingClasses,
    'total_active_trainees': totalActiveTrainees,
    'courses_by_area': coursesByArea,
    'top_trainers': topTrainers,
  };
}
