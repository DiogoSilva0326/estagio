import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.dotColor,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String imageAsset;
  final Color dotColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: 296.17,
      height: 326.809,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.532),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            offset: Offset(0, 5.106),
            blurRadius: 5.106,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30.638, 30.638, 30.638, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(imageAsset, width: 81.702, height: 81.702, fit: BoxFit.contain),
                Container(
                  width: 15.319,
                  height: 15.319,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
              ],
            ),
            const SizedBox(height: 20.426),
            Text(
              title,
              style: const TextStyle(
                fontSize: 30.638,
                height: 1.333,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0A0A),
              ),
            ),
            const SizedBox(height: 20.426),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 20.426,
                height: 1.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6A7282),
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25.532),
      child: card,
    );
  }
}
