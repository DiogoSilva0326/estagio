import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_colors.dart';
import 'package:flutter/material.dart';

class PagamentosProfessorPagination extends StatelessWidget {
  const PagamentosProfessorPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PaginationIconButton(
          icon: Icons.chevron_left_rounded,
          onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        const SizedBox(width: 12),
        ...List.generate(totalPages, (index) {
          final page = index + 1;
          final isActive = page == currentPage;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onPageChanged(page),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive
                      ? PagamentosProfessorColors.withdrawGradientTop
                      : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: PagamentosProfessorColors.cardBorder,
                  ),
                ),
                child: Text(
                  '$page',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? Colors.white
                        : PagamentosProfessorColors.title,
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 12),
        _PaginationIconButton(
          icon: Icons.chevron_right_rounded,
          onTap: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
      ],
    );
  }
}

class _PaginationIconButton extends StatelessWidget {
  const _PaginationIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: onTap == null ? const Color(0xFFF2F4F7) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: PagamentosProfessorColors.cardBorder),
          ),
          child: Icon(
            icon,
            size: 18,
            color: onTap == null
                ? const Color(0xFF98A2B3)
                : PagamentosProfessorColors.title,
          ),
        ),
      ),
    );
  }
}
