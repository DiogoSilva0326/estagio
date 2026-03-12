import 'package:aula_extra/features/login/constants/login_colors.dart';
import 'package:flutter/material.dart';

class DividerWithLabel extends StatelessWidget {
  const DividerWithLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16.715,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 7.94,
            child: Container(
              height: 0.836,
              color: LoginColors.stroke,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Text(
                'Ou com email',
                style: TextStyle(
                  fontSize: 11.7,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6A7282),
                  height: 16.715 / 11.7,
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
