import 'package:flutter/material.dart';

class AreaOverview {
  const AreaOverview({
    required this.idArea,
    required this.name,
    required this.imageAsset,
    required this.targetRole,
    required this.selectedDisciplinaIds,
    required this.selectedDisciplinaNames,
    required this.scheduledLessons,
    required this.pendingTasks,
    required this.nextLessonText,
    required this.nextLessonColor,
  });

  final String idArea;
  final String name;
  final String imageAsset;
  final String targetRole; 

  final List<String> selectedDisciplinaIds;
  final List<String> selectedDisciplinaNames;

  final int scheduledLessons;
  final int pendingTasks;
  final String nextLessonText;
  final Color nextLessonColor;
}