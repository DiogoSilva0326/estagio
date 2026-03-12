import 'package:flutter/material.dart';

class FolderCard extends StatelessWidget {
  const FolderCard({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136.538,
      padding: const EdgeInsets.fromLTRB(34.831, 34.831, 34.831, 1.393),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.292),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.393),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            offset: Offset(0, 1.393),
            blurRadius: 4.18,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            offset: Offset(0, 1.393),
            blurRadius: 2.786,
            spreadRadius: -1.393,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 66.876,
            height: 66.876,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(19.505),
            ),
            child: Center(
              child: Icon(icon, size: 33.438, color: Colors.white),
            ),
          ),
          const SizedBox(width: 22.292),
          Expanded(
            child: SizedBox(
              height: 61.303,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22.292,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF101828),
                      height: 33.438 / 22.292,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 19.505,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4A5565),
                      height: 27.865 / 19.505,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
