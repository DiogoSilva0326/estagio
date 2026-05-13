import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_status_badge.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../models/formulario_item.dart';
import '../widgets/formulario_detail_dialog.dart';
import '../widgets/formularios_search_field.dart';

class FormulariosTableSection extends StatelessWidget {
  const FormulariosTableSection({
    required this.items,
    required this.searchController,
    required this.onSearchChanged,
    required this.onDataChanged,
    required this.isLoading,
    required this.warningMessage,
    super.key,
  });

  final List<FormularioItem> items;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onDataChanged;
  final bool isLoading;
  final String? warningMessage;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: 27.955,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(37.273, 23.296, 37.273, 22),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 720) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gestão',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 32.614,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.512,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FormulariosSearchField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Gestão',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 32.614,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.512,
                        ),
                      ),
                    ),
                    FormulariosSearchField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                    ),
                  ],
                );
              },
            ),
          ),
          Container(height: 1.165, color: AppColors.borderSoft),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 1030),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  27.955,
                  18.637,
                  27.955,
                  18.637,
                ),
                child: Column(
                  children: [
                    const _FormulariosTableHeader(),
                    if (warningMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4E5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFD39A)),
                          ),
                          child: Text(
                            warningMessage!,
                            style: const TextStyle(
                              color: Color(0xFFB54708),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Text(
                          'Sem formulários que correspondam à pesquisa.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15.143,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      for (var index = 0; index < items.length; index++)
                        _FormulariosTableRow(
                          item: items[index],
                          onDataChanged: onDataChanged,
                          showDivider: index != items.length - 1,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormulariosTableHeader extends StatelessWidget {
  const _FormulariosTableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _HeaderCell('ID', 130),
          _HeaderCell('DATA', 110),
          _HeaderCell('PERFIL', 250),
          _HeaderCell('FORMULÁRIO', 220),
          _HeaderCell('ESTADO', 150),
          _HeaderCell('AÇÕES', 140),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, this.width);

  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12.813,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3563,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

class _FormulariosTableRow extends StatelessWidget {
  const _FormulariosTableRow({
    required this.item,
    required this.onDataChanged,
    required this.showDivider,
  });

  final FormularioItem item;
  final Future<void> Function() onDataChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final row = SizedBox(
      height: 82,
      child: Row(
        children: [
          _BodyCell(item.id, width: 130, fontWeight: FontWeight.w700),
          _BodyCell(item.dateLabel, width: 110),
          SizedBox(
            width: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.profileName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.143,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.profileEmail,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.978,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _BodyCell(item.formName, width: 220),
          SizedBox(
            width: 150,
            child: Align(
              alignment: Alignment.centerLeft,
              child: DashboardStatusBadge(
                label: item.statusLabel,
                color: item.statusColor,
                backgroundColor: item.statusBackgroundColor,
              ),
            ),
          ),
          SizedBox(
            width: 140,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () async {
                  final changed = await showDialog<bool>(
                    context: context,
                    barrierColor: const Color(0x73000000),
                    builder: (_) => FormularioDetailDialog(item: item),
                  );
                  if (changed == true) {
                    await onDataChanged();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFC9039),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'VER FORMULÁRIO',
                  style: TextStyle(
                    color: Color(0xFFFC9039),
                    fontSize: 12.81,
                    fontFamily: 'Helvetica Neue',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                    letterSpacing: 0.72,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!showDivider) {
      return row;
    }

    return Column(
      children: [
        row,
        const Divider(height: 1.165, color: Color(0x80F3F4F6)),
      ],
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(
    this.label, {
    required this.width,
    this.fontWeight = FontWeight.w600,
  });

  final String label;
  final double width;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF4A5565),
          fontSize: 16.307,
          fontWeight: fontWeight,
          letterSpacing: -0.1752,
        ),
      ),
    );
  }
}
