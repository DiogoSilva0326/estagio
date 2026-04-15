import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/features/disciplinas/utils/area_visuals.dart';
import 'package:flutter/material.dart';

class SidebarSection extends StatelessWidget {
  const SidebarSection({
    super.key,
    required this.areas,
    required this.selectedAreaId,
    required this.onAreaSelected,
  });

  final List<AreaDto> areas;
  final String? selectedAreaId;
  final ValueChanged<String?> onAreaSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 356,
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Áreas Gerais',
              style: TextStyle(
                fontSize: 26.7,
                height: 1.33,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0A0A),
              ),
            ),
            const SizedBox(height: 26.7),
            _GeneralAreasList(
              areas: areas,
              selectedAreaId: selectedAreaId,
              onAreaSelected: onAreaSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneralAreasList extends StatelessWidget {
  const _GeneralAreasList({
    required this.areas,
    required this.selectedAreaId,
    required this.onAreaSelected,
  });

  static const Color _iconCircleGrey = Color.fromRGBO(107, 114, 128, 0.13);

  final List<AreaDto> areas;
  final String? selectedAreaId;
  final ValueChanged<String?> onAreaSelected;

  @override
  Widget build(BuildContext context) {
    Widget item({
      required String text,
      required bool active,
      required Color iconColor,
      required IconData icon,
      required VoidCallback onTap,
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

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11.125),
        child: Container(
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
            padding: const EdgeInsets.only(left: 13.35, right: 13.35),
            child: Align(alignment: Alignment.centerLeft, child: content),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        item(
          text: 'Todas',
          active: selectedAreaId == null,
          iconColor: const Color(0xFF0A0A0A),
          icon: Icons.grid_view_rounded,
          onTap: () => onAreaSelected(null),
        ),
        for (final area in areas) ...[
          const SizedBox(height: 13.35),
          Builder(
            builder: (context) {
              final visuals = getAreaVisuals(area.nome);
              return item(
                text: area.nome,
                active: selectedAreaId == area.idArea,
                iconColor: visuals.dotColor,
                icon: visuals.icon,
                onTap: () => onAreaSelected(area.idArea),
              );
            },
          ),
        ],
      ],
    );
  }
}
