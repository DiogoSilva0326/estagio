import 'package:flutter/material.dart';

class TutorCard extends StatelessWidget {
  const TutorCard({
    super.key,
    required this.name,
    required this.country,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.lessonsText,
    required this.pricePerHour,
    required this.tags,
     this.onViewProfileTap,
     this.onBookLessonTap,
  });

  final String name;
  final String country;
  final double rating;
  final int reviewCount;
  final String description;
  final String lessonsText;
  final int pricePerHour;
  final List<String> tags;
  final VoidCallback? onViewProfileTap;
  final VoidCallback? onBookLessonTap;

  static const _orange = Color(0xFFFC9039);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 285, 
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(16, 24, 40, 0.05),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, 
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _orange, width: 2),
                    color: const Color(0xFFF9FAFB),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name.trim().characters.first : 'E',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101828),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF667085)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              country,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 18, color: _orange),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF101828)),
                ),
                Text(' ($reviewCount)', style: const TextStyle(fontSize: 13, color: Color(0xFF667085))),
                const Spacer(),
                const Icon(Icons.history_edu_rounded, size: 16, color: Color(0xFF667085)),
                const SizedBox(width: 4),
                Text(lessonsText, style: const TextStyle(fontSize: 13, color: Color(0xFF667085))),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEAECF0)),
            const SizedBox(height: 16),

            Text(
              description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF475467),
              ),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags
                  .take(3)
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF344054),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),

            const SizedBox(height: 24),

            // --- PREÇO ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Desde ', style: TextStyle(fontSize: 12, color: Color(0xFF667085), height: 1.8)),
                Text(
                  '$pricePerHour€',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _orange, height: 1),
                ),
                const Text('/h', style: TextStyle(fontSize: 13, color: Color(0xFF667085), height: 1.6)),
              ],
            ),

            const SizedBox(height: 16),

            // --- BOTÕES ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewProfileTap,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _orange, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Perfil', style: TextStyle(color: _orange, fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onBookLessonTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Marcar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}