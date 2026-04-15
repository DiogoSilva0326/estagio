import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:aula_extra/features/faq/constants/faq_copy.dart';
import 'package:aula_extra/features/faq/widgets/faq_question_row.dart';
import 'package:flutter/material.dart';

class FaqGroups extends StatefulWidget {
  const FaqGroups({super.key, required this.groups});

  final List<FaqGroupData> groups;

  @override
  State<FaqGroups> createState() => _FaqGroupsState();
}

class _FaqGroupsState extends State<FaqGroups> {
  String? _expandedTitle;
  final Map<String, int?> _expandedQuestionByGroup = {};

  @override
  void initState() {
    super.initState();
    _syncExpandedGroup();
  }

  @override
  void didUpdateWidget(covariant FaqGroups oldWidget) {
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

    final stillExists = widget.groups.any((group) => group.title == _expandedTitle);
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

  void _toggleQuestion({required String groupTitle, required int questionIndex}) {
    setState(() {
      final current = _expandedQuestionByGroup[groupTitle];
      _expandedQuestionByGroup[groupTitle] = current == questionIndex ? null : questionIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groups.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(FaqDimens.radiusCard),
          border: Border.all(color: FaqColors.borderLight, width: FaqDimens.borderThin),
        ),
        child: const Column(
          children: [
            Icon(Icons.search_off_outlined, size: 42, color: FaqColors.textMuted),
            SizedBox(height: 16),
            Text(
              'Nenhuma FAQ encontrada.',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: FaqColors.textPrimary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Tenta outra categoria ou ajusta a pesquisa para veres mais resultados.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                height: 1.5,
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
          _FaqGroupCard(
            data: widget.groups[i],
            expanded: _expandedTitle == widget.groups[i].title,
            onHeaderTap: () => _toggle(widget.groups[i].title),
            expandedQuestionIndex: _expandedQuestionByGroup[widget.groups[i].title],
            onQuestionTap: (qIndex) => _toggleQuestion(
              groupTitle: widget.groups[i].title,
              questionIndex: qIndex,
            ),
          ),
          if (i != widget.groups.length - 1) const SizedBox(height: 30.626),
        ],
      ],
    );
  }
}

class _FaqGroupCard extends StatelessWidget {
  const _FaqGroupCard({
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
        borderRadius: BorderRadius.circular(FaqDimens.radiusCard),
        border: Border.all(color: FaqColors.borderLight, width: FaqDimens.borderThin),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            blurRadius: 3.828,
            offset: Offset(0, 1.276),
          ),
        ],
      ),
      child: Column(
        children: [
          _FaqGroupHeader(
            accentColor: data.accentColor,
            title: data.title,
            questionCountText: data.questionCountText,
            expanded: expanded,
            onTap: onHeaderTap,
          ),
          if (expanded) ...[
            Container(height: FaqDimens.borderThin, color: FaqColors.borderLight),
            ...List.generate(
              data.questions.length,
              (index) {
                final q = data.questions[index];
                return FaqQuestionRow(
                  index: index + 1,
                  question: q.question,
                  answer: q.answer,
                  showBottomBorder: index != data.questions.length - 1,
                  expanded: expandedQuestionIndex == index,
                  onTap: () => onQuestionTap(index),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _FaqGroupHeader extends StatelessWidget {
  const _FaqGroupHeader({
    required this.accentColor,
    required this.title,
    required this.questionCountText,
    required this.expanded,
    required this.onTap,
  });

  final Color accentColor;
  final String title;
  final String questionCountText;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FaqDimens.radiusCard),
      child: Container(
        height: 112.295,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30.626),
        decoration: BoxDecoration(
          gradient: FaqGradients.sectionHeader,
          borderRadius: expanded
              ? const BorderRadius.vertical(top: Radius.circular(FaqDimens.radiusCard))
              : BorderRadius.circular(FaqDimens.radiusCard),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 51.043,
                  height: 51.043,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(FaqDimens.radiusButton),
                  ),
                  child: const Center(
                    child: Icon(Icons.layers_outlined, size: 25.522, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 15.313),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 25.522,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: FaqColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 15.313),
                Container(
                  height: 35.73,
                  padding: const EdgeInsets.symmetric(horizontal: 15.313),
                  decoration: BoxDecoration(
                    color: FaqColors.borderLight,
                    borderRadius: BorderRadius.circular(FaqDimens.radiusPill),
                  ),
                  child: Center(
                    child: Text(
                      questionCountText,
                      style: const TextStyle(
                        fontSize: 17.865,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                        color: FaqColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 30.626,
              color: FaqColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
