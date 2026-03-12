import 'package:flutter/material.dart';

class AreaOverview {
  const AreaOverview({
    required this.idArea,
    required this.name,
    required this.imageAsset,
    required this.selectedDisciplinaNames,
    required this.scheduledLessons,
    required this.pendingTasks,
    required this.nextLessonText,
    required this.nextLessonColor,
  });

  final String idArea;
  final String name;
  final String imageAsset;

  final List<String> selectedDisciplinaNames;

  final int scheduledLessons;
  final int pendingTasks;
  final String nextLessonText;
  final Color nextLessonColor;
}
