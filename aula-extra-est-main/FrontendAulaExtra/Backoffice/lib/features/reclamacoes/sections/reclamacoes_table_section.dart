import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_status_badge.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../models/reclamacao_item.dart';
import '../widgets/reclamacao_detail_dialog.dart';
import '../widgets/reclamacoes_search_field.dart';
import '../widgets/reclamacoes_type_filter_field.dart';

class ReclamacoesTableSection extends StatelessWidget {
  const ReclamacoesTableSection({
    required this.items,
    required this.selectedSource,
    required this.searchController,
    required this.types,
    required this.selectedType,
    required this.isLoading,
    required this.warningMessage,
    required this.onDataChanged,
    required this.onSourceChanged,
    required this.onSearchChanged,
    required this.onTypeChanged,
    super.key,
  });

  final List<ReclamacaoItem> items;
  final ReclamacaoSource selectedSource;
  final TextEditingController searchController;
  final List<String> types;
  final String? selectedType;
  final bool isLoading;
  final String? warningMessage;
  final Future<void> Function() onDataChanged;
  final ValueChanged<ReclamacaoSource> onSourceChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onTypeChanged;

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
                if (constraints.maxWidth < 860) {
                  final title = selectedSource == ReclamacaoSource.utilizadores
                      ? 'Reclamações contra utilizadores'
                      : 'Reclamações de pagamentos';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 32.614,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.512,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ReclamacoesSourceSwitch(
                        selectedSource: selectedSource,
                        onChanged: onSourceChanged,
                      ),
                      const SizedBox(height: 12),
                      ReclamacoesSearchField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                      ),
                      const SizedBox(height: 12),
                      ReclamacoesTypeFilterField(
                        types: types,
                        selectedType: selectedType,
                        onChanged: onTypeChanged,
                      ),
                    ],
                  );
                }

                final title = selectedSource == ReclamacaoSource.utilizadores
                    ? 'Reclamações contra utilizadores'
                    : 'Reclamações de pagamentos';

                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 32.614,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.512,
                        ),
                      ),
                    ),
                    _ReclamacoesSourceSwitch(
                      selectedSource: selectedSource,
                      onChanged: onSourceChanged,
                    ),
                    const SizedBox(width: 12),
                    ReclamacoesSearchField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                    ),
                    const SizedBox(width: 12),
                    ReclamacoesTypeFilterField(
                      types: types,
                      selectedType: selectedType,
                      onChanged: onTypeChanged,
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
              constraints: const BoxConstraints(minWidth: 1120),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  27.955,
                  18.637,
                  27.955,
                  18.637,
                ),
                child: Column(
                  children: [
                    if (warningMessage != null && warningMessage!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFED7AA)),
                        ),
                        child: Text(
                          warningMessage!,
                          style: const TextStyle(
                            color: Color(0xFF9A3412),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    _ReclamacoesTableHeader(selectedSource: selectedSource),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Text(
                          'Sem reclamações que correspondam aos filtros atuais.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15.143,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      for (var index = 0; index < items.length; index++)
                        _ReclamacoesTableRow(
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

class _ReclamacoesTableHeader extends StatelessWidget {
  const _ReclamacoesTableHeader({required this.selectedSource});

  final ReclamacaoSource selectedSource;

  @override
  Widget build(BuildContext context) {
    final profileLabel =
        selectedSource == ReclamacaoSource.utilizadores ? 'PERFIL' : 'RECLAMANTE';

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const _HeaderCell('ID', 130),
          const _HeaderCell('DATA', 110),
          _HeaderCell(profileLabel, 250),
          const _HeaderCell('TIPO', 170),
          const _HeaderCell('ESTADO', 170),
          const _HeaderCell('AÇÕES', 170),
        ],
      ),
    );
  }
}

class _ReclamacoesSourceSwitch extends StatelessWidget {
  const _ReclamacoesSourceSwitch({
    required this.selectedSource,
    required this.onChanged,
  });

  final ReclamacaoSource selectedSource;
  final ValueChanged<ReclamacaoSource> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.307),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SourceButton(
            label: 'Utilizadores',
            selected: selectedSource == ReclamacaoSource.utilizadores,
            onPressed: () => onChanged(ReclamacaoSource.utilizadores),
          ),
          _SourceButton(
            label: 'Pagamentos',
            selected: selectedSource == ReclamacaoSource.pagamentos,
            onPressed: () => onChanged(ReclamacaoSource.pagamentos),
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: selected ? const Color(0xFFFC9039) : Colors.transparent,
        foregroundColor: selected ? Colors.white : AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
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

class _ReclamacoesTableRow extends StatelessWidget {
  const _ReclamacoesTableRow({
    required this.item,
    required this.onDataChanged,
    required this.showDivider,
  });

  final ReclamacaoItem item;
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
          _BodyCell(item.type.toUpperCase(), width: 170),
          SizedBox(
            width: 170,
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
            width: 170,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () async {
                  final changed = await showDialog<bool>(
                    context: context,
                    barrierColor: const Color(0x73000000),
                    builder: (_) => ReclamacaoDetailDialog(item: item),
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
                  'VER RECLAMAÇÃO',
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
