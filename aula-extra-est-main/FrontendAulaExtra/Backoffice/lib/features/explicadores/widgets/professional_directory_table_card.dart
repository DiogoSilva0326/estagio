import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_status_badge.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../models/explicador_item.dart';
import 'explicador_actions_menu.dart';
import 'explicador_profile_cell.dart';
import 'explicadores_filter_chip.dart';

class ProfessionalDirectoryFilter {
  const ProfessionalDirectoryFilter({
    required this.label,
    required this.width,
    this.options = const <String>[],
    this.selectedValue,
    this.onSelected,
  });

  final String label;
  final double width;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String>? onSelected;
}

class ProfessionalDirectoryTableCard extends StatelessWidget {
  const ProfessionalDirectoryTableCard({
    required this.filters,
    required this.secondaryHeaderLabel,
    required this.items,
    super.key,
    this.entityLabel = 'explicador',
    this.reviewDialogEntityLabel = 'explicador',
    this.entityTitle = 'Explicador',
    this.emptyMessage = 'Não existem utilizadores para mostrar.',
    this.showVerifiedColumn = false,
    this.onReviewUpdated,
  });

  final List<ProfessionalDirectoryFilter> filters;
  final String secondaryHeaderLabel;
  final List<ExplicadorItem> items;
  final String entityLabel;
  final String reviewDialogEntityLabel;
  final String entityTitle;
  final String emptyMessage;
  final bool showVerifiedColumn;
  final VoidCallback? onReviewUpdated;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: 27.955,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 90.27,
            padding: const EdgeInsets.symmetric(
              horizontal: 37.273,
              vertical: 23.296,
            ),
            child: _HorizontalScrollRegion(
              physics: const ClampingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < filters.length; index++) ...[
                    ExplicadoresFilterChip(
                      label: filters[index].label,
                      width: filters[index].width,
                      options: filters[index].options,
                      selectedValue: filters[index].selectedValue,
                      onSelected: filters[index].onSelected,
                    ),
                    if (index != filters.length - 1)
                      const SizedBox(width: 18.64),
                  ],
                ],
              ),
            ),
          ),
          Container(height: 1.165, color: AppColors.borderSoft),
          _HorizontalScrollRegion(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: showVerifiedColumn ? 1110 : 960,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(27.955, 20, 27.955, 18),
                child: items.isEmpty
                    ? _EmptyState(message: emptyMessage)
                    : Column(
                        children: [
                          _DirectoryTableHeader(
                            secondaryHeaderLabel: secondaryHeaderLabel,
                            showVerifiedColumn: showVerifiedColumn,
                          ),
                          for (var index = 0; index < items.length; index++)
                            _DirectoryTableRow(
                              item: items[index],
                              showVerifiedColumn: showVerifiedColumn,
                              entityLabel: entityLabel,
                              reviewDialogEntityLabel: reviewDialogEntityLabel,
                              entityTitle: entityTitle,
                              onReviewUpdated: onReviewUpdated,
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

class _DirectoryTableHeader extends StatelessWidget {
  const _DirectoryTableHeader({
    required this.secondaryHeaderLabel,
    required this.showVerifiedColumn,
  });

  final String secondaryHeaderLabel;
  final bool showVerifiedColumn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const _HeaderCell('PERFIL', 292),
          _HeaderCell(secondaryHeaderLabel, 168),
          const _HeaderCell('PREÇO/HORA', 140),
          const _HeaderCell('AVALIAÇÃO', 176),
          const _HeaderCell('ESTADO', 140),
          if (showVerifiedColumn) const _HeaderCell('VERIFICADO', 150),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _HorizontalScrollRegion extends StatefulWidget {
  const _HorizontalScrollRegion({
    required this.child,
    required this.physics,
  });

  final Widget child;
  final ScrollPhysics physics;

  @override
  State<_HorizontalScrollRegion> createState() =>
      _HorizontalScrollRegionState();
}

class _HorizontalScrollRegionState extends State<_HorizontalScrollRegion> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) {
      return;
    }

    final delta = event.scrollDelta.dx != 0 ? event.scrollDelta.dx : event.scrollDelta.dy;
    if (delta == 0) {
      return;
    }

    final position = _controller.position;
    final targetOffset = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    if (targetOffset != position.pixels) {
      _controller.jumpTo(targetOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: widget.physics,
        child: widget.child,
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
        padding: const EdgeInsets.only(bottom: 16),
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

class _DirectoryTableRow extends StatelessWidget {
  const _DirectoryTableRow({
    required this.item,
    required this.showVerifiedColumn,
    required this.entityLabel,
    required this.reviewDialogEntityLabel,
    required this.entityTitle,
    required this.onReviewUpdated,
    required this.showDivider,
  });

  final ExplicadorItem item;
  final bool showVerifiedColumn;
  final String entityLabel;
  final String reviewDialogEntityLabel;
  final String entityTitle;
  final VoidCallback? onReviewUpdated;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final row = SizedBox(
      height: 84.448,
      child: Row(
        children: [
          SizedBox(
            width: 292,
            child: ExplicadorProfileCell(
              initials: item.initials,
              name: item.name,
              email: item.email,
              photoUrl: item.photoUrl,
            ),
          ),
          _BodyCell(item.mainSubject, width: 168),
          _BodyCell(item.priceLabel, width: 140),
          _BodyCell(item.ratingLabel, width: 176),
          SizedBox(
            width: 140,
            child: Align(
              alignment: Alignment.centerLeft,
              child: DashboardStatusBadge(
                label: item.statusLabel,
                color: item.statusColor,
                backgroundColor: item.statusBackgroundColor,
              ),
            ),
          ),
          if (showVerifiedColumn)
            SizedBox(
              width: 150,
              child: Align(
                alignment: Alignment.centerLeft,
                child: DashboardStatusBadge(
                  label: item.verifiedLabel,
                  color: item.isVerified
                      ? const Color(0xFF4CAF50)
                      : AppColors.danger,
                  backgroundColor: item.isVerified
                      ? const Color(0x264CAF50)
                      : const Color(0x26F04438),
                ),
              ),
            ),
          SizedBox(
            width: 44,
            child: ExplicadorActionsMenu(
              item: item,
              entityLabel: entityLabel,
              reviewDialogEntityLabel: reviewDialogEntityLabel,
              entityTitle: entityTitle,
              onReviewUpdated: onReviewUpdated,
            ),
          ),
        ],
      ),
    );

    if (!showDivider) return row;

    return Column(
      children: [
        row,
        const Divider(height: 1.165, color: Color(0x80F9FAFB)),
      ],
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(this.label, {required this.width});

  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4A5565),
          fontSize: 16.307,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1752,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1110,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const Icon(
              Icons.group_outlined,
              size: 32,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
