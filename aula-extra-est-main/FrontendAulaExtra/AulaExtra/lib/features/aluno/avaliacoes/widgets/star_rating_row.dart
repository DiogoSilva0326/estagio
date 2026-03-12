import 'package:flutter/material.dart';

class StarRatingRow extends StatelessWidget {
  const StarRatingRow({
    super.key,
    required this.rating,
    this.starSize = 27.481,
    this.spacing = 5.496,
    this.filledColor = const Color(0xFFFFB800),
    this.emptyColor = const Color(0xFF9CA3AF),
  });

  final double rating;
  final double starSize;
  final double spacing;
  final Color filledColor;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    final filledCount = rating.floor().clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++) ...[
          Icon(
            i <= filledCount ? Icons.star_rounded : Icons.star_border_rounded,
            size: starSize,
            color: i <= filledCount ? filledColor : emptyColor,
          ),
          if (i != 5) SizedBox(width: spacing),
        ],
      ],
    );
  }
}
