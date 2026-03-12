import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class CtaSection extends StatelessWidget {
  const CtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 465,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CtaCard(
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF48086), Color(0xFFF15C64)]),
            title: 'Queres Aprender?',
            description: 'Encontra o explicador perfeito para ti e começa a melhorar as tuas notas hoje mesmo.',
            buttonColor: const Color(0xFFF15C64),
            onPressed: () => Navigator.of(context).pushNamed(Routes.registerStudent),
          ),
          const SizedBox(width: 172),
          _CtaCard(
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFDB571), Color(0xFFFC9039)]),
            title: 'Queres Ensinar?',
            description: 'Junta-te à nossa equipa de explicadores e partilha o teu conhecimento com milhares de estudantes.',
            buttonColor: const Color(0xFFFC9039),
            onPressed: () => Navigator.of(context).pushNamed(Routes.registerStudent),
          ),
        ],
      ),
    );
  }
}

class _CtaCard extends StatelessWidget {
  const _CtaCard({
    required this.gradient,
    required this.title,
    required this.description,
    required this.buttonColor,
    required this.onPressed,
  });

  final Gradient gradient;
  final String title;
  final String description;
  final Color buttonColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 516.25,
      height: 295,
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(29.5)),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 34,
            child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w400, color: Colors.white)),
          ),
          Positioned(
            left: 54,
            right: 54,
            top: 120,
            child: Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19.175, fontWeight: FontWeight.w400, color: Colors.white)),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 88,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29.5)),
                ),
                onPressed: onPressed,
                child: const Text('Registar-me', style: TextStyle(fontSize: 23.6, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
