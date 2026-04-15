import 'package:aula_extra/core/navigation/become_teacher_navigation.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class CtaSection extends StatelessWidget {
  const CtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Para mobile, você precisará mudar este Row para Column. 
    // Uma forma simples é usar o LayoutBuilder que discutimos antes.
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 40, // Espaço horizontal entre os cards
          runSpacing: 40, // Espaço vertical quando um card for para baixo do outro
          children: [
            _CtaCard(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF48086), Color(0xFFF15C64)],
              ),
              title: 'Queres Aprender?',
              description: 'Encontra o explicador perfeito para ti e começa a melhorar as tuas notas hoje mesmo.',
              buttonColor: const Color(0xFFF15C64),
              onPressed: () => Navigator.of(context).pushNamed(Routes.registerStudent),
            ),
            _CtaCard(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFDB571), Color(0xFFFC9039)],
              ),
              title: 'Queres Ensinar?',
              description: 'Junta-te à nossa equipa de explicadores e partilha o teu conhecimento com milhares de estudantes.',
              buttonColor: const Color(0xFFFC9039),
              buttonLabel: 'Tornar-me Explicador',
              onPressed: () => navigateToBecomeTeacherFlow(context),
            ),
          ],
        ),
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
    this.buttonLabel = 'Registar-me',
    required this.onPressed,
  });

  final Gradient gradient;
  final String title;
  final String description;
  final Color buttonColor;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // DICA PARA MOBILE: Em telas pequenas, o ideal é que o width seja MediaQuery.of(context).size.width * 0.9
    return Container(
      width: 516.25,
      height: 295,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(29.5),
      ),
      child: Stack(
        children: [
          // TÍTULO COM A FONTE GULAX
          Positioned(
            left: 0,
            right: 0,
            top: 34,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Gulax', // Aplicando a fonte Gulax
                fontSize: 48,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
          // DESCRIÇÃO
          Positioned(
            left: 54,
            right: 54,
            top: 120,
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19.175,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.2, // Melhora a leitura em textos multi-linha
              ),
            ),
          ),
          // BOTÃO
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(29.5),
                  ),
                ),
                onPressed: onPressed,
                child: Text(
                  buttonLabel,
                  style: const TextStyle(
                    fontSize: 23.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}