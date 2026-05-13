import 'package:flutter/material.dart';

class ExportReportButton extends StatelessWidget {
  const ExportReportButton({
    super.key,
    this.onPressed,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? const Color(0xFFFC9039) : const Color(0xFFF5B37F),
      borderRadius: BorderRadius.circular(16.307),
      child: InkWell(
        onTap: enabled ? onPressed : null,
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
              Icon(Icons.download_rounded, size: 18.637, color: Colors.white),
              SizedBox(width: 13.98),
              Text(
                'Exportar relatório',
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
