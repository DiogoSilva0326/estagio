import 'package:aula_extra/core/widgets/asset_picture.dart';
import 'package:aula_extra/features/become_teacher/assets/become_teacher_assets.dart';
import 'package:flutter/material.dart';

class BecomeTeacherMobileHeroSection extends StatelessWidget {
  const BecomeTeacherMobileHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: BecomeTeacherMobileLayout.maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _BecomeTeacherMobileStatCard(
              width: 188,
              value: '100% online',
              label: 'Ensina a partir de qualquer lugar',
              icon: const Icon(
                Icons.cast_for_education_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 272,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      BecomeTeacherMobileLayout.heroCardRadius,
                    ),
                    child: ImageFiltered(
                      imageFilter: BecomeTeacherMobileLayout.heroBlur,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.fromRGBO(252, 144, 57, 0.22),
                              Color.fromRGBO(241, 92, 100, 0.22),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      BecomeTeacherMobileLayout.heroCardRadius,
                    ),
                    child: const AssetPicture(
                      BecomeTeacherAssets.heroImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        BecomeTeacherMobileLayout.heroCardRadius,
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(15, 23, 42, 0.10),
                          Color.fromRGBO(15, 23, 42, 0.68),
                        ],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ensina na Aula Extra',
                        style: TextStyle(
                          fontSize: 28,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Cria o teu perfil, recebe pedidos de alunos e gere a tua disponibilidade com flexibilidade total.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: _BecomeTeacherMobileStatCard(
              width: 172,
              value: 'Apoio dedicado',
              label: 'Acompanhamento na candidatura',
              accentColor: Color(0xFF00C950),
              icon: Icon(Icons.check_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BecomeTeacherMobileLayout.surfaceShadow],
            ),
            child: const Column(
              children: [
                _BecomeTeacherBenefitRow(
                  icon: Icons.schedule_outlined,
                  title: 'Define os teus horários',
                  subtitle:
                      'Escolhe quando estás disponível para dar explicações.',
                ),
                SizedBox(height: 16),
                _BecomeTeacherBenefitRow(
                  icon: Icons.payments_outlined,
                  title: 'Recebe pagamentos',
                  subtitle:
                      'Configura o teu IBAN e gere os teus recebimentos com segurança.',
                ),
                SizedBox(height: 16),
                _BecomeTeacherBenefitRow(
                  icon: Icons.verified_outlined,
                  title: 'Mostra as tuas credenciais',
                  subtitle:
                      'Adiciona certificados, apresentação e vídeo para destacar o teu perfil.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BecomeTeacherMobileStatCard extends StatelessWidget {
  const _BecomeTeacherMobileStatCard({
    required this.width,
    required this.value,
    required this.label,
    required this.icon,
    this.accentColor,
  });

  final double width;
  final String value;
  final String label;
  final Widget icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final gradient = accentColor == null
        ? BecomeTeacherMobileLayout.actionGradient
        : null;

    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BecomeTeacherMobileLayout.surfaceShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor,
              gradient: gradient,
              shape: BoxShape.circle,
            ),
            child: Center(child: icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BecomeTeacherBenefitRow extends StatelessWidget {
  const _BecomeTeacherBenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: BecomeTeacherMobileLayout.actionGradient,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
