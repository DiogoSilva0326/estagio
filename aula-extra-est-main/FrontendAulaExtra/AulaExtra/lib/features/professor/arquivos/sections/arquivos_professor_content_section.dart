import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/arquivos/constants/arquivos_professor_colors.dart';
import 'package:aula_extra/features/professor/arquivos/constants/arquivos_professor_font_sizes.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/arquivo_row.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/arquivos_professor_search_field.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/arquivos_professor_upload_button.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/pasta_tile.dart';
import 'package:flutter/material.dart';

class ArquivosProfessorContentSection extends StatelessWidget {
  const ArquivosProfessorContentSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ArquivosProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 54,
            right: 23.148,
            top: 90,
            bottom: 90,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfessorMenuNav(
                selectedIndex: 3,
                notificationCount: 2,
                aulasEstaSemana: 8,
                ganhosPendentes: '150€',
                alunosAtivos: 12,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28.889, 28.889, 28.889, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 43.333,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Arquivos',
                              style: TextStyle(
                                color: ArquivosProfessorColors.title,
                                fontSize: ArquivosProfessorFontSizes.title,
                                fontWeight: FontWeight.w700,
                                height: 43.333 / ArquivosProfessorFontSizes.title,
                              ),
                            ),
                            ArquivosProfessorUploadButton(onTap: () {}),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28.889),
                      _Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20.463, 20.463, 20.463, 20.463),
                          child: ArquivosProfessorSearchField(onChanged: (_) {}),
                        ),
                      ),
                      const SizedBox(height: 28.889),
                      SizedBox(
                        height: 536.852,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 228.102,
                              child: _Card(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20.463, 20.463, 20.463, 20.463),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Pastas',
                                        style: TextStyle(
                                          color: ArquivosProfessorColors.title,
                                          fontSize: ArquivosProfessorFontSizes.sectionHeading,
                                          fontWeight: FontWeight.w500,
                                          height: 32.5 / ArquivosProfessorFontSizes.sectionHeading,
                                        ),
                                      ),
                                      const SizedBox(height: 19.259),
                                      PastaTile(
                                        icon: Icons.person_rounded,
                                        name: 'João Silva',
                                        countLabel: '12 arquivos',
                                        onTap: () {},
                                      ),
                                      const SizedBox(height: 9.63),
                                      PastaTile(
                                        icon: Icons.person_rounded,
                                        name: 'Maria Santos',
                                        countLabel: '8 arquivos',
                                        onTap: () {},
                                      ),
                                      const SizedBox(height: 9.63),
                                      PastaTile(
                                        icon: Icons.person_rounded,
                                        name: 'Pedro Costa',
                                        countLabel: '15 arquivos',
                                        onTap: () {},
                                      ),
                                      const SizedBox(height: 9.63),
                                      PastaTile(
                                        icon: Icons.calculate_rounded,
                                        name: 'Matemática',
                                        countLabel: '24 arquivos',
                                        onTap: () {},
                                      ),
                                      const SizedBox(height: 9.63),
                                      PastaTile(
                                        icon: Icons.science_rounded,
                                        name: 'Física',
                                        countLabel: '18 arquivos',
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 28.889),
                            Expanded(
                              child: _Card(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.fromLTRB(19.259, 19.259, 19.259, 19.259),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: ArquivosProfessorColors.cardBorder,
                                            width: 1.204,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Todos os Arquivos',
                                        style: TextStyle(
                                          color: ArquivosProfessorColors.title,
                                          fontSize: ArquivosProfessorFontSizes.sectionHeading,
                                          fontWeight: FontWeight.w500,
                                          height: 32.5 / ArquivosProfessorFontSizes.sectionHeading,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: const [
                                            ArquivoRow(
                                              leadingBackground: ArquivosProfessorColors.fileTypeRedBg,
                                              leadingIcon: Icons.picture_as_pdf_rounded,
                                              fileName: 'Exercícios_Algebra.pdf',
                                              sizeLabel: '2.3 MB',
                                              dateLabel: '20 Jan 2026',
                                            ),
                                            ArquivoRow(
                                              leadingBackground: ArquivosProfessorColors.fileTypeOrangeBg,
                                              leadingIcon: Icons.slideshow_rounded,
                                              fileName: 'Slides_Cinematica.pptx',
                                              sizeLabel: '5.1 MB',
                                              dateLabel: '18 Jan 2026',
                                            ),
                                            ArquivoRow(
                                              leadingBackground: ArquivosProfessorColors.fileTypeBlueBg,
                                              leadingIcon: Icons.description_rounded,
                                              fileName: 'Lista_Verbos_Irregulares.docx',
                                              sizeLabel: '156 KB',
                                              dateLabel: '15 Jan 2026',
                                            ),
                                            ArquivoRow(
                                              leadingBackground: ArquivosProfessorColors.fileTypeGreenBg,
                                              leadingIcon: Icons.image_rounded,
                                              fileName: 'Grafico_Funcoes.png',
                                              sizeLabel: '890 KB',
                                              dateLabel: '12 Jan 2026',
                                            ),
                                            ArquivoRow(
                                              leadingBackground: ArquivosProfessorColors.fileTypeRedBg,
                                              leadingIcon: Icons.picture_as_pdf_rounded,
                                              fileName: 'Resolucao_Exercicios.pdf',
                                              sizeLabel: '1.8 MB',
                                              dateLabel: '10 Jan 2026',
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: ArquivosProfessorColors.cardBackground,
        borderRadius: BorderRadius.circular(19.259),
        border: Border.all(
          color: ArquivosProfessorColors.cardBorder,
          width: 1.204,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            offset: Offset(0, 4.815),
            blurRadius: 7.222,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            offset: Offset(0, 2.407),
            blurRadius: 4.815,
          ),
        ],
      ),
      child: child,
    );
  }
}
