import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:aula_extra/features/faq/constants/faq_copy.dart';
import 'package:flutter/material.dart';

class FaqMobileGroups extends StatefulWidget {
  const FaqMobileGroups({super.key, required this.groups});

  final List<FaqGroupData> groups;

  @override
  State<FaqMobileGroups> createState() => _FaqMobileGroupsState();
}

class _FaqMobileGroupsState extends State<FaqMobileGroups> {
  String? _expandedTitle;
  final Map<String, int?> _expandedQuestionByGroup = {};

  @override
  void initState() {
    super.initState();
    _syncExpandedGroup();
  }

  @override
  void didUpdateWidget(covariant FaqMobileGroups oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groups != widget.groups) {
      _syncExpandedGroup();
    }
  }

  void _syncExpandedGroup() {
    if (widget.groups.isEmpty) {
      _expandedTitle = null;
      return;
    }

    final stillExists = widget.groups.any(
      (group) => group.title == _expandedTitle,
    );
    if (!stillExists) {
      final initial = widget.groups.cast<FaqGroupData?>().firstWhere(
        (group) => group?.initiallyExpanded ?? false,
        orElse: () => widget.groups.first,
      );
      _expandedTitle = initial?.title;
    }
  }

  void _toggle(String title) {
    setState(() {
      _expandedTitle = _expandedTitle == title ? null : title;
    });
  }

  void _toggleQuestion({
    required String groupTitle,
    required int questionIndex,
  }) {
    setState(() {
      final current = _expandedQuestionByGroup[groupTitle];
      _expandedQuestionByGroup[groupTitle] = current == questionIndex
          ? null
          : questionIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groups.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: FaqColors.borderLight),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 36,
              color: FaqColors.textMuted,
            ),
            SizedBox(height: 14),
            Text(
              'Nenhuma FAQ encontrada.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: FaqColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tenta outra categoria ou ajusta a pesquisa para veres mais resultados.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: FaqColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < widget.groups.length; i++) ...[
          _FaqMobileGroupCard(
            data: widget.groups[i],
            expanded: _expandedTitle == widget.groups[i].title,
            onHeaderTap: () => _toggle(widget.groups[i].title),
            expandedQuestionIndex:
                _expandedQuestionByGroup[widget.groups[i].title],
            onQuestionTap: (qIndex) => _toggleQuestion(
              groupTitle: widget.groups[i].title,
              questionIndex: qIndex,
            ),
          ),
          if (i != widget.groups.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _FaqMobileGroupCard extends StatelessWidget {
  const _FaqMobileGroupCard({
    required this.data,
    required this.expanded,
    required this.onHeaderTap,
    required this.expandedQuestionIndex,
    required this.onQuestionTap,
  });

  final FaqGroupData data;
  final bool expanded;
  final VoidCallback onHeaderTap;
  final int? expandedQuestionIndex;
  final ValueChanged<int> onQuestionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FaqColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onHeaderTap,
            borderRadius: expanded
                ? const BorderRadius.vertical(top: Radius.circular(24))
                : BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: BoxDecoration(
                gradient: FaqGradients.sectionHeader,
                borderRadius: expanded
                    ? const BorderRadius.vertical(top: Radius.circular(24))
                    : BorderRadius.circular(24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: data.accentColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.layers_outlined,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            color: FaqColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: FaqColors.borderLight,
                            borderRadius: BorderRadius.circular(
                              FaqDimens.radiusPill,
                            ),
                          ),
                          child: Text(
                            data.questionCountText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: FaqColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 24,
                    color: FaqColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            Container(height: 1, color: FaqColors.borderLight),
            ...List.generate(
              data.questions.length,
              (index) => _FaqMobileQuestionTile(
                index: index + 1,
                question: data.questions[index].question,
                answer: data.questions[index].answer,
                expanded: expandedQuestionIndex == index,
                showBottomBorder: index != data.questions.length - 1,
                onTap: () => onQuestionTap(index),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FaqMobileQuestionTile extends StatelessWidget {
  const _FaqMobileQuestionTile({
    required this.index,
    required this.question,
    required this.answer,
    required this.expanded,
    required this.showBottomBorder,
    required this.onTap,
  });

  final int index;
  final String question;
  final String answer;
  final bool expanded;
  final bool showBottomBorder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          border: showBottomBorder
              ? const Border(bottom: BorderSide(color: FaqColors.borderLight))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: FaqColors.questionIndexBg,
                    borderRadius: BorderRadius.circular(FaqDimens.radiusPill),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: FaqColors.questionIndexText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: FaqColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 22,
                    color: FaqColors.textMuted,
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: 40,
                        top: 12,
                        right: 8,
                      ),
                      child: Text(
                        answer,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          color: FaqColors.textSecondary,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
