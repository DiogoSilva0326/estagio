import 'package:flutter/material.dart';

class AvaliacoesStatsRow extends StatelessWidget {
  const AvaliacoesStatsRow({
    super.key,
    required this.media,
    required this.realizadas,
  });

  final double media;
  final int realizadas;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(34.351, 20.351, 34.351, 20.374),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFEFCE8), Color(0xFFFEF9C2)],
              ),
              borderRadius: BorderRadius.circular(21.985),
              border: Border.all(color: const Color(0xFFFFF085), width: 1.374),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 65.954,
                  color: Color(0xFFA65F00),
                ),
                const SizedBox(width: 21.985),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      media.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 41.221,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFA65F00),
                        height: 49.466 / 41.221,
                      ),
                    ),
                    const SizedBox(height: 5.496),
                    const Text(
                      'Média das suas avaliações',
                      style: TextStyle(
                        fontSize: 19.237,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFA65F00),
                        height: 27.481 / 19.237,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 32.977),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(34.351, 20.351, 34.351, 20.374),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
              ),
              borderRadius: BorderRadius.circular(21.985),
              border: Border.all(color: const Color(0xFFBEDBFF), width: 1.374),
            ),
            child: Row(
              children: [
                Container(
                  width: 65.954,
                  height: 65.954,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2B7FFF),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$realizadas',
                    style: const TextStyle(
                      fontSize: 32.977,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 43.969 / 32.977,
                    ),
                  ),
                ),
                const SizedBox(width: 21.985),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$realizadas',
                      style: const TextStyle(
                        fontSize: 41.221,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF155DFC),
                        height: 49.466 / 41.221,
                      ),
                    ),
                    const SizedBox(height: 5.496),
                    const Text(
                      'Avaliações realizadas',
                      style: TextStyle(
                        fontSize: 19.237,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1447E6),
                        height: 27.481 / 19.237,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
