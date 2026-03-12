import 'package:flutter/material.dart';

class MainContentHeaderSection extends StatelessWidget {
  const MainContentHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.38),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 63.83,
            child: Row(
              children: [
                const Expanded(child: _SearchInput()),
                const SizedBox(width: 20.426),
                SizedBox(
                  width: 355.532,
                  child: const _Dropdown(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.426),
          const Text(
            'Explore todos os nossos Explicadores',
            style: TextStyle(
              fontSize: 30.638,
              height: 40.851 / 30.638,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A0A0A),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 63.83,
          padding: const EdgeInsets.only(left: 61.277, right: 20.426),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD1D5DC), width: 1.277),
            borderRadius: BorderRadius.circular(12.766),
          ),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Procura por nome ou especialidade...',
              style: TextStyle(
                fontSize: 20.426,
                color: Color.fromRGBO(10, 10, 10, 0.5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        const Positioned(
          left: 20.43,
          top: 19.15,
          child: Icon(Icons.search, size: 25.532, color: Color(0xFF0A0A0A)),
        ),
      ],
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 63.83,
      padding: const EdgeInsets.only(left: 20.426, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD1D5DC), width: 1.277),
        borderRadius: BorderRadius.circular(12.766),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Todos',
                style: TextStyle(
                  fontSize: 20,
                  height: 35.557 / 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8F8F8F),
                ),
              ),
            ),
          ),
          Icon(Icons.expand_more, size: 25.532, color: Color(0xFF0A0A0A)),
        ],
      ),
    );
  }
}
