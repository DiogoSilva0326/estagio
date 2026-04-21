import 'package:flutter/material.dart';

class ProcessPayoutsButton extends StatelessWidget {
  const ProcessPayoutsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFC9039),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('A processar payouts pendentes.')),
            );
        },
        borderRadius: BorderRadius.circular(14),
        child: const SizedBox(
          height: 41.933,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.playlist_add_check_circle_outlined,
                  size: 18.637,
                  color: Colors.white,
                ),
                SizedBox(width: 11.647),
                Text(
                  'Processar Payouts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.143,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.15,
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
