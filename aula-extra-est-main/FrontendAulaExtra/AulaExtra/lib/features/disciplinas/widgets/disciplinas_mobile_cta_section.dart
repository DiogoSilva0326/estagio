import 'package:aula_extra/core/navigation/become_teacher_navigation.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class DisciplinasMobileCtaSection extends StatelessWidget {
  const DisciplinasMobileCtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CtaCard(
          title: 'Queres Aprender?',
          description:
              'Encontra explicadores especialistas em qualquer disciplina e começa a aprender hoje.',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFC9039), Color(0xFFFAA31B)],
          ),
          buttonText: 'Começar',
          buttonTextColor: const Color(0xFFFC9039),
          onPressed: () => Navigator.of(context).pushNamed(Routes.explicadores),
        ),
        const SizedBox(height: 16),
        _CtaCard(
          title: 'Queres Ensinar?',
          description:
              'Junta-te à nossa comunidade de explicadores e partilha o teu conhecimento.',
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF15C64), Color(0xFFFC9039)],
          ),
          buttonText: 'Inscrever',
          buttonTextColor: const Color(0xFFF15C64),
          onPressed: () => navigateToBecomeTeacherFlow(context),
        ),
      ],
    );
  }
}

class _CtaCard extends StatelessWidget {
  const _CtaCard({
    required this.title,
    required this.description,
    required this.gradient,
    required this.buttonText,
    required this.buttonTextColor,
    required this.onPressed,
  });

  final String title;
  final String description;
  final Gradient gradient;
  final String buttonText;
  final Color buttonTextColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              height: 1.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: buttonTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: buttonTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
