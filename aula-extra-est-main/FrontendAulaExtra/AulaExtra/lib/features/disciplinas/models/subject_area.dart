import 'package:flutter/material.dart';

class SubjectArea {
  const SubjectArea({
    required this.title,
    required this.tutorsText,
    required this.imageAsset,
    required this.dotColor,
  });

  final String title;
  final String tutorsText;
  final String imageAsset;
  final Color dotColor;
}
