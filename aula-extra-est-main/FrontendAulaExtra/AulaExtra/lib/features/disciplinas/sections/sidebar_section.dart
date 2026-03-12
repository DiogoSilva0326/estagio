import 'package:flutter/material.dart';

class SidebarSection extends StatelessWidget {
  const SidebarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 356,
      height: 1235,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          right: BorderSide(color: Color(0xFFE5E7EB), width: 1.112),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 26.7, right: 44.5, top: 26.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Áreas Gerais',
              style: TextStyle(
                fontSize: 26.7,
                height: 1.33,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0A0A),
              ),
            ),
            SizedBox(height: 26.7),
            _GeneralAreasList(),
            SizedBox(height: 27.812),
            Divider(color: Color(0xFFE5E7EB), thickness: 1.112, height: 1.112),
            SizedBox(height: 27.812),
            _EducationLevel(),
          ],
        ),
      ),
    );
  }
}

class _GeneralAreasList extends StatelessWidget {
  const _GeneralAreasList();

  static const Color _iconCircleGrey = Color.fromRGBO(107, 114, 128, 0.13);

  @override
  Widget build(BuildContext context) {
    Widget item({
      required String text,
      required bool active,
      required Color iconColor,
      required IconData icon,
    }) {
      final content = Row(
        children: [
          Container(
            width: 35.6,
            height: 35.6,
            decoration: const BoxDecoration(color: _iconCircleGrey, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 13.35),
          Text(
            text,
            style: TextStyle(
              fontSize: 17.8,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: active ? const Color(0xFF0A0A0A) : const Color(0xFF0A0A0A),
            ),
          ),
        ],
      );

      return Container(
        height: 62.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11.125),
          gradient: active
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromRGBO(252, 144, 57, 0.20),
                    Color.fromRGBO(241, 92, 100, 0.20),
                  ],
                )
              : null,
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.10),
                    offset: Offset(0, 4.45),
                    blurRadius: 6.675,
                    spreadRadius: -1.112,
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.10),
                    offset: Offset(0, 2.225),
                    blurRadius: 4.45,
                    spreadRadius: -2.225,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 13.35),
          child: Align(alignment: Alignment.centerLeft, child: content),
        ),
      );
    }

    return SizedBox(
      height: 667.5,
      child: Column(
        children: [
          item(text: 'Todas', active: true, iconColor: const Color(0xFF0A0A0A), icon: Icons.grid_view_rounded),
          const SizedBox(height: 13.35),
          item(text: 'Matemática', active: false, iconColor: const Color(0xFF3B94EF), icon: Icons.calculate_rounded),
          const SizedBox(height: 13.35),
          item(text: 'Ciências', active: false, iconColor: const Color(0xFF45AB61), icon: Icons.science_rounded),
          const SizedBox(height: 13.35),
          item(text: 'Línguas', active: false, iconColor: const Color(0xFFFC9039), icon: Icons.language_rounded),
          const SizedBox(height: 13.35),
          item(text: 'Literatura', active: false, iconColor: const Color(0xFF9B59B6), icon: Icons.menu_book_rounded),
          const SizedBox(height: 13.35),
          item(text: 'Programação', active: false, iconColor: const Color(0xFFE74C3C), icon: Icons.code_rounded),
          const SizedBox(height: 13.35),
          item(text: 'Geografia', active: false, iconColor: const Color(0xFFF39C12), icon: Icons.public_rounded),
          const SizedBox(height: 13.35),
          item(text: 'Música', active: false, iconColor: const Color(0xFFF1C40F), icon: Icons.music_note_rounded),
          const SizedBox(height: 13.35),
          item(text: 'Artes', active: false, iconColor: const Color(0xFFE91E63), icon: Icons.palette_rounded),
        ],
      ),
    );
  }
}

class _EducationLevel extends StatelessWidget {
  const _EducationLevel();

  @override
  Widget build(BuildContext context) {
    Widget button({required String text, required bool active}) {
      return Container(
        width: double.infinity,
        height: 44.5,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFC9039) : Colors.transparent,
          borderRadius: BorderRadius.circular(11.125),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 13.35),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 17.8,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : const Color(0xFF0A0A0A),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nível Educacional',
          style: TextStyle(
            fontSize: 20.025,
            height: 1.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 17.8),
        button(text: 'Todos os Níveis', active: true),
        const SizedBox(height: 8.9),
        button(text: '📚 Primária', active: false),
        const SizedBox(height: 8.9),
        button(text: '🎓 Secundária', active: false),
        const SizedBox(height: 8.9),
        button(text: '🏫 Universidade', active: false),
        const SizedBox(height: 17.8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17.8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(11.125),
          ),
          child: Column(
            children: const [
              _StatRow(label: 'Aulas esta semana', value: '4', valueColor: Color(0xFFFC9039)),
              SizedBox(height: 13.35),
              _StatRow(label: 'Tarefas pendentes', value: '2', valueColor: Color(0xFFF15C64)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, required this.valueColor});

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15.575,
            height: 1.43,
            fontWeight: FontWeight.w400,
            color: Color(0xFF4A5565),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 17.8,
            height: 1.5,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
