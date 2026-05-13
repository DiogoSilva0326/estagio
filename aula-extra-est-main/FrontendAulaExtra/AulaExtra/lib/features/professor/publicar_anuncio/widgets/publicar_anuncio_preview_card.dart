import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/professor_ad_dto.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/tutoring_type_option_dto.dart';
import 'package:aula_extra/features/professor/publicar_anuncio/constants/publicar_anuncio_professor_constants.dart';
import 'package:aula_extra/features/professor/publicar_anuncio/widgets/publicar_anuncio_shared_widgets.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PublicarAnuncioPreviewCard extends StatelessWidget {
  const PublicarAnuncioPreviewCard({
    required this.displayName,
    required this.selectedDisciplina,
    required this.selectedType,
    required this.selectedAd,
    required this.description,
    required this.formattedPrice,
    required this.photoUrl,
    required this.isMobile,
    required this.onViewProfile,
    super.key,
  });

  final String displayName;
  final DisciplinaDto? selectedDisciplina;
  final TutoringTypeOptionDto? selectedType;
  final ProfessorAdDto? selectedAd;
  final String description;
  final String formattedPrice;
  final String? photoUrl;
  final bool isMobile;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);
    final isExplicador = config.roleName == 'Explicador';
    
    // Rótulo Dinâmico para a Área principal
    final defaultSubjectLabel = isExplicador ? 'Disciplina' : 'Especialidade';

    // Determinar se tem Ciclo de Estudos válido para ser mostrado
    final cicloLabel = selectedDisciplina?.cicloEstudosLabel ?? selectedAd?.cicloEstudos ?? '';
    final hasCiclo = isExplicador && cicloLabel.trim().isNotEmpty && !cicloLabel.toLowerCase().contains('não definido');

    return PublicarAnuncioSurfaceCard(
      padding: EdgeInsets.all(
        isMobile ? PublicarAnuncioProfessorLayout.mobileCardPadding : 28,
      ),
      radius: isMobile ? PublicarAnuncioProfessorLayout.mobileCardRadius : 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pré-visualização',
            style: TextStyle(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.w700,
              color: PublicarAnuncioProfessorColors.title,
            ),
          ),
          SizedBox(height: isMobile ? 18 : 22),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: PublicarAnuncioProfessorColors.surface,
              borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
              border: Border.all(
                color: PublicarAnuncioProfessorColors.surfaceBorder,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PublicarAnuncioProfileAvatar(
                      photoUrl: photoUrl,
                      size: isMobile ? 72 : 84,
                    ),
                    SizedBox(width: isMobile ? 14 : 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: isMobile ? 20 : 24,
                              fontWeight: FontWeight.w700,
                              color: PublicarAnuncioProfessorColors.title,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: config.primaryColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              selectedType?.name ??
                                  selectedAd?.tutoringTypeName ??
                                  'Aula particular',
                              style: TextStyle(
                                color: config.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  style: const TextStyle(
                    color: PublicarAnuncioProfessorColors.mutedText,
                    fontSize: 14.5,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    PublicarAnuncioPreviewChip(
                      label: selectedDisciplina?.nome ??
                             selectedAd?.disciplinaNome ??
                             defaultSubjectLabel,
                    ),
                    if (hasCiclo)
                      PublicarAnuncioPreviewChip(
                        label: cicloLabel,
                      ),
                    PublicarAnuncioPreviewChip(
                      label: selectedAd?.status == 'published'
                          ? 'Publicado'
                          : 'Rascunho',
                      color: const Color(0xFFECFDF3),
                      textColor: PublicarAnuncioProfessorColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  height: 1,
                  color: PublicarAnuncioProfessorColors.surfaceBorder,
                ),
                SizedBox(height: isMobile ? 16 : 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedPrice,
                      style: TextStyle(
                        fontSize: isMobile ? 30 : 34,
                        fontWeight: FontWeight.w800,
                        color: PublicarAnuncioProfessorColors.title,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Text(
                        '/aula',
                        style: TextStyle(
                          color: PublicarAnuncioProfessorColors.mutedText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onViewProfile,
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.fromHeight(isMobile ? 46 : 48),
                          side: const BorderSide(
                            color: PublicarAnuncioProfessorColors.surfaceBorder,
                          ),
                        ),
                        child: const Text('Ver Perfil'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: null,
                        style: FilledButton.styleFrom(
                          minimumSize: Size.fromHeight(isMobile ? 46 : 48),
                          backgroundColor: config.primaryColor,
                          disabledBackgroundColor: config.primaryColor,
                        ),
                        child: const Text('Marcar Aula'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}