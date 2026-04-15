import 'package:aula_extra/features/home/assets/home_assets.dart';
import 'package:flutter/material.dart';

class DisciplinasSearchBar extends StatelessWidget {
  const DisciplinasSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 949.787,
      height: 74.043,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              width: 857.872,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD1D5DC), width: 1.277),
                borderRadius: BorderRadius.circular(25.532),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 61.277, right: 20.426),
                child: Center(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Procurar disciplinas...',
                      hintStyle: TextStyle(
                        fontSize: 20.426,
                        height: 1.0,
                        color: Color.fromRGBO(10, 10, 10, 0.5),
                        fontWeight: FontWeight.w400,
                      ),
                      isCollapsed: true,
                    ),
                    style: const TextStyle(
                      fontSize: 20.426,
                      height: 1.0,
                      color: Color(0xFF0A0A0A),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20.426,
            top: 26.81,
            child: Image.asset(
              HomeAssets.searchIcon,
              width: 20.426,
              height: 20.426,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
