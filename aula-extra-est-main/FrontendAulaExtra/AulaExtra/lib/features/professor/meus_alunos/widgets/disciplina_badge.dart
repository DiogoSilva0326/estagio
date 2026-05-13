import 'package:flutter/material.dart';

class DisciplinaBadge extends StatelessWidget {
  const DisciplinaBadge({
    super.key, 
    required this.label, 
    required this.color,
    this.backgroundColor, 
    this.textColor,      
  });

  final String label;
  final Color color;
  final Color? backgroundColor; 
  final Color? textColor;      

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9.85, vertical: 2.44),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: backgroundColor ?? color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17.23),
        ),
      ),
      child: Text(
        label,
        strutStyle: const StrutStyle(
          fontSize: 14.77,
          height: 1.33,
          forceStrutHeight: true,
        ),
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 14.77,
          fontWeight: FontWeight.w500,
          height: 1.33,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }
}