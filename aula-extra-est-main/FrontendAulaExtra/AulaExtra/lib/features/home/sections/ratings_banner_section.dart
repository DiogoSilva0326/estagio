import 'package:aula_extra/core/data/professors/dtos/global_professor_rating_summary_dto.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/features/home/assets/home_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RatingsBannerSection extends StatefulWidget {
  const RatingsBannerSection({super.key});

  @override
  State<RatingsBannerSection> createState() => _RatingsBannerSectionState();
}

class _RatingsBannerSectionState extends State<RatingsBannerSection> {
  final ProfessorsService _professorsService = ProfessorsService();
  late final Future<GlobalProfessorRatingSummaryDto> _ratingSummaryFuture =
      _professorsService.getGlobalRatingSummary();

  String _formatRating(double value) =>
      value.toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      width: double.infinity,
      child: FutureBuilder<GlobalProfessorRatingSummaryDto>(
        future: _ratingSummaryFuture,
        builder: (context, snapshot) {
          final summary =
              snapshot.data ??
              const GlobalProfessorRatingSummaryDto(
                avgRating: 0,
                reviewCount: 0,
              );
          final ratingText = _formatRating(summary.avgRating);

          return Stack(
            children: [
              Positioned(
                left: 126,
                top: 90,
                child: Text(
                  ratingText,
                  style: const TextStyle(
                    fontSize: 200,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Gulax',
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
              Positioned(
                left: 433,
                top: 25,
                child: SvgPicture.asset(
                  HomeAssets.star,
                  width: 97.5,
                  height: 97.5,
                ),
              ),
              const Positioned(
                left: 563,
                top: 50,
                child: Text(
                  'em avaliações\nreais',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 128,
                    fontFamily: 'Gulax',
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 0.85,
                  ),
                ),
              ),
              Positioned(
                left: 869,
                top: 180,
                child: SizedBox(
                  width: 450,
                  child: Text(
                    'A qualidade dos nossos explicadores reflete-se nas avaliações: uma média de $ratingText estrelas atribuídas por quem aprende connosco.',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
