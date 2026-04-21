import 'package:aula_extra/features/professor/publicar_anuncio/constants/publicar_anuncio_professor_constants.dart';
import 'package:flutter/material.dart';

enum PublicarAnuncioMobileTab { informacoes, preview }

class PublicarAnuncioMobileModeTabs extends StatelessWidget {
  const PublicarAnuncioMobileModeTabs({
    super.key,
    required this.selectedTab,
    required this.onChanged,
  });

  final PublicarAnuncioMobileTab selectedTab;
  final ValueChanged<PublicarAnuncioMobileTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PublicarAnuncioProfessorColors.mobileTabBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PublicarAnuncioProfessorColors.surfaceBorder),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Informações',
            selected: selectedTab == PublicarAnuncioMobileTab.informacoes,
            onTap: () => onChanged(PublicarAnuncioMobileTab.informacoes),
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: 'Pré-visualização',
            selected: selectedTab == PublicarAnuncioMobileTab.preview,
            onTap: () => onChanged(PublicarAnuncioMobileTab.preview),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected
            ? PublicarAnuncioProfessorColors.mobileTabSelected
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: PublicarAnuncioProfessorLayout.mobileTabHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected
                    ? PublicarAnuncioProfessorColors.title
                    : PublicarAnuncioProfessorColors.mutedText,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                height: 20 / 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
