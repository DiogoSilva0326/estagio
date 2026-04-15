import 'package:aula_extra/features/register/constants/register_colors.dart';
import 'package:flutter/material.dart';

class RegisterDividerWithLabel extends StatelessWidget {
  const RegisterDividerWithLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16.719,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 7.94,
            child: Container(height: 0.836, color: RegisterColors.stroke),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Text(
                'Ou com email',
                style: TextStyle(
                  fontSize: 11.703,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6A7282),
                  height: 16.719 / 11.703,
                  letterSpacing: -0.1257,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
