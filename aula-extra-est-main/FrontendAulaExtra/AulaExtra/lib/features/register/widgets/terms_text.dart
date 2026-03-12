import 'package:aula_extra/features/register/constants/register_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TermsText extends StatelessWidget {
  const TermsText({
    super.key,
    required this.onChanged,
  });

  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    const linkStyle = TextStyle(
      fontSize: 11.703,
      fontWeight: FontWeight.w500,
      color: RegisterColors.gradientStart,
      height: 16.719 / 11.703,
      letterSpacing: -0.1257,
    );

    const normalStyle = TextStyle(
      fontSize: 11.703,
      fontWeight: FontWeight.w500,
      color: Color(0xFF364153),
      height: 16.719 / 11.703,
      letterSpacing: -0.1257,
    );

    return Text.rich(
      TextSpan(
        style: normalStyle,
        children: [
          const TextSpan(text: 'Aceito os '),
          TextSpan(
            text: 'Termos e Condições',
            style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = onChanged,
          ),
          const TextSpan(text: ' e a '),
          TextSpan(
            text: 'Política de Privacidade',
            style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = onChanged,
          ),
        ],
      ),
    );
  }
}
