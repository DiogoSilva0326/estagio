import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliar_professor_dialog.dart';
import 'package:flutter/material.dart';

class AvaliarProfessorCard extends StatelessWidget {
  const AvaliarProfessorCard({super.key, required this.onSubmitted});

  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(35.725, 20.725, 35.725, 20.748),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFF6B00), width: 2.748),
        borderRadius: BorderRadius.circular(21.985),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 1.374),
            blurRadius: 4.122,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 1.374),
            blurRadius: 2.748,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Quer avaliar um professor? ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27.481,
              fontWeight: FontWeight.w500,
              color: Color(0xFF101828),
              height: 38.473 / 27.481,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Só é possível avaliar uma vez por professor',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21.985,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4A5565),
              height: 32.977 / 21.985,
            ),
          ),
          const SizedBox(height: 21.985),
          SizedBox(
            width: 250.237,
            height: 65.954,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF6B00), Color(0xFFFF9966)],
                ),
                borderRadius: BorderRadius.circular(19.237),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19.237),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AvaliarProfessorDialog(),
                  ).then((value) {
                    if (value == true) {
                      onSubmitted();
                    }
                  });
                },
                child: const Text(
                  'Avaliar Professor',
                  style: TextStyle(
                    fontSize: 21.985,
                    fontWeight: FontWeight.w400,
                    height: 32.977 / 21.985,
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
