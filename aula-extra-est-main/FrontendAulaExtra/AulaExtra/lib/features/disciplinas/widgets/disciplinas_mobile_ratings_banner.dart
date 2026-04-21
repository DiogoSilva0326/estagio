import 'package:aula_extra/core/data/professors/dtos/global_professor_rating_summary_dto.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/features/disciplinas/constants/disciplinas_mobile_layout.dart';
import 'package:flutter/material.dart';

class DisciplinasMobileRatingsBanner extends StatefulWidget {
  const DisciplinasMobileRatingsBanner({super.key});

  @override
  State<DisciplinasMobileRatingsBanner> createState() =>
      _DisciplinasMobileRatingsBannerState();
}

class _DisciplinasMobileRatingsBannerState
    extends State<DisciplinasMobileRatingsBanner> {
  final ProfessorsService _professorsService = ProfessorsService();
  late final Future<GlobalProfessorRatingSummaryDto> _ratingSummaryFuture =
      _professorsService.getGlobalRatingSummary();

  String _formatRating(double value) =>
      value.toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GlobalProfessorRatingSummaryDto>(
      future: _ratingSummaryFuture,
      builder: (context, snapshot) {
        final summary =
            snapshot.data ??
            const GlobalProfessorRatingSummaryDto(avgRating: 0, reviewCount: 0);
        final ratingText = _formatRating(summary.avgRating);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: DisciplinasMobileLayout.ratingsGradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ratingText,
                    style: const TextStyle(
                      fontFamily: 'Gulax',
                      fontSize: 72,
                      height: 0.9,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Icon(
                      Icons.star_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'em avaliações reais',
                style: TextStyle(
                  fontFamily: 'Gulax',
                  fontSize: 34,
                  height: 0.95,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A qualidade dos nossos explicadores reflete-se nas avaliações: uma média de $ratingText estrelas atribuídas por quem aprende connosco.',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Color.fromRGBO(255, 255, 255, 0.92),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
