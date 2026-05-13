import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../models/institutional_page_item.dart';

const double _tableWidth = 1066.321;
const double _actionsColumnWidth = 120;

class PaginasInstitucionaisTableSection extends StatelessWidget {
  const PaginasInstitucionaisTableSection({
    required this.items,
    required this.onEdit,
    required this.onPreview,
    super.key,
  });

  final List<InstitutionalPageItem> items;
  final ValueChanged<InstitutionalPageItem> onEdit;
  final ValueChanged<InstitutionalPageItem> onPreview;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: const EdgeInsets.all(1.165),
      borderRadius: 27.955,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(9.318, 9.318, 9.318, 18.637),
        child: items.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(27.955),
                child: Text(
                  'Sem páginas institucionais disponíveis.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15.143,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _TableContent(
                  items: items,
                  onEdit: onEdit,
                  onPreview: onPreview,
                ),
              ),
      ),
    );
  }
}

class _TableContent extends StatelessWidget {
  const _TableContent({
    required this.items,
    required this.onEdit,
    required this.onPreview,
  });

  final List<InstitutionalPageItem> items;
  final ValueChanged<InstitutionalPageItem> onEdit;
  final ValueChanged<InstitutionalPageItem> onPreview;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _tableWidth,
      child: Column(
        children: [
          const _TableHeader(),
          for (var index = 0; index < items.length; index++)
            _TableRow(
              item: items[index],
              isLast: index == items.length - 1,
              onEdit: () => onEdit(items[index]),
              onPreview: () => onPreview(items[index]),
            ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75.712,
      padding: const EdgeInsets.symmetric(horizontal: 27.955),
      alignment: Alignment.centerLeft,
      child: const Row(
        children: [
          SizedBox(width: 302.792, child: _HeaderCell('TÍTULO DA PÁGINA')),
          SizedBox(width: 260.586, child: _HeaderCell('URL (SLUG)')),
          SizedBox(width: 159.167, child: _HeaderCell('ÚLTIMA\nEDIÇÃO')),
          SizedBox(width: 167.866, child: _HeaderCell('ESTADO')),
          SizedBox(width: _actionsColumnWidth, child: _HeaderCell('AÇÕES')),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF99A1AF),
        fontSize: 12.813,
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 1.3563,
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.item,
    required this.isLast,
    required this.onEdit,
    required this.onPreview,
  });

  final InstitutionalPageItem item;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94.348,
      padding: const EdgeInsets.symmetric(horizontal: 27.955),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0x80F9FAFB), width: 1.165),
              ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 302.792,
            child: Row(
              children: [
                Container(
                  width: 46.592,
                  height: 46.592,
                  decoration: BoxDecoration(
                    color: const Color(0x1941A7D7),
                    borderRadius: BorderRadius.circular(16.307),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF41A7D7),
                    size: 23.296,
                  ),
                ),
                const SizedBox(width: 13.978),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Color(0xFF101828),
                      fontSize: 16.307,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.1752,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 260.586,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13.978,
                  vertical: 6.989,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(11.648),
                ),
                child: Text(
                  item.slug,
                  style: const TextStyle(
                    color: Color(0xFF6A7282),
                    fontSize: 16.307,
                    fontFamily: 'Menlo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 159.167,
            child: Text(
              item.updatedAtLabel,
              style: const TextStyle(
                color: Color(0xFF4A5565),
                fontSize: 16.307,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1752,
              ),
            ),
          ),
          SizedBox(
            width: 167.866,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusBadge(status: item.status),
            ),
          ),
          SizedBox(
            width: _actionsColumnWidth,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onPreview,
                    tooltip: 'Pré-visualizar página',
                    icon: const Icon(Icons.visibility_outlined),
                    color: const Color(0xFF98A2B3),
                    splashRadius: 20,
                  ),
                  IconButton(
                    onPressed: onEdit,
                    tooltip: 'Editar página',
                    icon: const Icon(Icons.edit_outlined),
                    color: const Color(0xFF98A2B3),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final InstitutionalPageStatus status;

  @override
  Widget build(BuildContext context) {
    final isPublished = status == InstitutionalPageStatus.published;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13.978, vertical: 5.241),
      decoration: BoxDecoration(
        color: isPublished ? const Color(0x264CAF50) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.uppercaseLabel,
        style: TextStyle(
          color: isPublished
              ? const Color(0xFF4CAF50)
              : const Color(0xFF6A7282),
          fontSize: 12.813,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7157,
          height: 1.5,
        ),
      ),
    );
  }
}
