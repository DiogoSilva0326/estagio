import 'package:flutter/material.dart';

class AreasDisciplinasAddButton extends StatelessWidget {
  const AreasDisciplinasAddButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFC9039),
      borderRadius: BorderRadius.circular(16.307),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16.307),
        child: Container(
          height: 46.592,
          padding: const EdgeInsets.symmetric(horizontal: 23.296),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.307),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40FC9039),
                blurRadius: 16.307,
                offset: Offset(0, 4.659),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 18.637, color: Colors.white),
              SizedBox(width: 13.98),
              Text(
                'Nova Área',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.307,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
