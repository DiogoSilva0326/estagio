import 'package:aula_extra/features/login/constants/login_colors.dart';
import 'package:flutter/material.dart';

class LoginMobileStatCard extends StatelessWidget {
  const LoginMobileStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.circleColor,
    this.circleGradient,
    this.width,
  });

  final String value;
  final String label;
  final Widget icon;
  final Color? circleColor;
  final Gradient? circleGradient;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
              gradient: circleGradient,
            ),
            alignment: Alignment.center,
            child: icon,
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: LoginColors.textPrimary,
                  letterSpacing: -0.45,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: LoginColors.textSecondary,
                  letterSpacing: -0.15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
