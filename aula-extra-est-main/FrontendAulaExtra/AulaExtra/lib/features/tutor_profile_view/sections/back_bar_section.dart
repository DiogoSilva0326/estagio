import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class BackBarSection extends StatelessWidget {
  const BackBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72.766,
      padding: const EdgeInsets.only(left: 40.851, top: 20.426),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.277),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.766),
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }
            Navigator.of(context).pushNamed(Routes.explicadores);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.213, vertical: 5.106),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, size: 25.532, color: Color(0xFF4A5565)),
                SizedBox(width: 10.213),
                Text(
                  'Voltar aos Explicadores',
                  style: TextStyle(
                    fontSize: 20.426,
                    height: 30.638 / 20.426,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A5565),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
