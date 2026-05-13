import 'package:flutter/material.dart';

import '../../explicadores/widgets/professional_directory_notice_card.dart';
import '../models/avaliacao_item.dart';
import '../services/backoffice_avaliacoes_service.dart';
import 'avaliacoes_header_section.dart';
import 'avaliacoes_metrics_section.dart';
import 'avaliacoes_table_section.dart';

enum _AvaliacaoView { aulas, professor }

class AvaliacoesOverviewSection extends StatefulWidget {
  const AvaliacoesOverviewSection({super.key});

  @override
  State<AvaliacoesOverviewSection> createState() =>
      _AvaliacoesOverviewSectionState();
}

class _AvaliacoesOverviewSectionState extends State<AvaliacoesOverviewSection> {
  late final TextEditingController _searchController;
  late final BackofficeAvaliacoesService _service;
  final Set<String> _submittingIds = <String>{};

  BackofficeAvaliacoesViewData _data =
      BackofficeAvaliacoesViewData.empty();
  bool _loading = true;
  String _searchQuery = '';
  _AvaliacaoView _currentView = _AvaliacaoView.aulas;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _service = BackofficeAvaliacoesService();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    final data = await _service.fetch();
    if (!mounted) {
      return;
    }

    setState(() {
      _data = data;
      _loading = false;
    });
  }

  Future<void> _moderate(AvaliacaoItem item, bool approved) async {
    if (_submittingIds.contains(item.id)) {
      return;
    }

    setState(() {
      _submittingIds.add(item.id);
    });

    try {
      await _service.moderate(item: item, approved: approved);
      if (!mounted) {
        return;
      }

      final nextStatus = approved
          ? AvaliacaoStatus.aprovada
          : AvaliacaoStatus.rejeitada;

      setState(() {
        _data = _data.updateItem(item.id, nextStatus);
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'A avaliação ${item.code} foi ${approved ? 'aprovada' : 'rejeitada'} com sucesso.',
            ),
          ),
        );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Nao foi possivel atualizar o estado da avaliacao.'),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _submittingIds.remove(item.id);
        });
      }
    }
  }

  List<AvaliacaoItem> _applySearch(List<AvaliacaoItem> items) {
    final query = _normalize(_searchQuery);
    if (query.isEmpty) {
      return items;
    }

    return items.where((item) {
      return <String>[
        item.code,
        item.aluno,
        item.explicador,
        item.disciplina,
        item.comment,
        item.dateLabel,
        item.statusLabel,
        item.sectionLabel,
      ].map(_normalize).any((value) => value.contains(query));
    }).toList(growable: false);
  }

  String _normalize(String value) {
    const accented = 'áàâãäåéèêëíìîïóòôõöúùûüçñ';
    const plain = 'aaaaaaeeeeiiiiooooouuuucn';

    final buffer = StringBuffer();
    for (final rune in value.toLowerCase().trim().runes) {
      final char = String.fromCharCode(rune);
      final index = accented.indexOf(char);
      buffer.write(index >= 0 ? plain[index] : char);
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final lessonItems = _applySearch(_data.lessonEvaluations);
    final professorItems = _applySearch(_data.professorEvaluations);
  final isLessonView = _currentView == _AvaliacaoView.aulas;
  final activeItems = isLessonView ? lessonItems : professorItems;
  final activeSummary = isLessonView ? _data.lessonSummary : _data.professorSummary;
  final activeScopeLabel = isLessonView ? 'das Aulas' : 'dos Professores';
  final activeTitle = isLessonView
    ? 'Avaliações submetidas às aulas (${activeItems.length})'
    : 'Avaliações submetidas ao professor (${activeItems.length})';
  final activeEmptyMessage = isLessonView
    ? 'Nao existem avaliacoes submetidas as aulas para mostrar.'
    : 'Nao existem avaliacoes submetidas ao professor para mostrar.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvaliacoesHeaderSection(
          searchController: _searchController,
          onSearchChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        if (_data.warningMessage != null) ...[
          const SizedBox(height: 24),
          ProfessionalDirectoryNoticeCard(
            message: _data.warningMessage!,
            onRetry: _load,
          ),
        ],
        const SizedBox(height: 37.273),
        _AvaliacaoSwitch(
          currentView: _currentView,
          onChanged: (view) {
            setState(() {
              _currentView = view;
            });
          },
        ),
        const SizedBox(height: 24),
        AvaliacoesMetricsSection(
          summary: activeSummary,
          scopeLabel: activeScopeLabel,
        ),
        const SizedBox(height: 37.273),
        AvaliacoesTableSection(
          title: activeTitle,
          items: activeItems,
          submittingIds: _submittingIds,
          onModerate: _moderate,
          emptyMessage: activeEmptyMessage,
        ),
      ],
    );
  }
}

class _AvaliacaoSwitch extends StatelessWidget {
  const _AvaliacaoSwitch({
    required this.currentView,
    required this.onChanged,
  });

  final _AvaliacaoView currentView;
  final ValueChanged<_AvaliacaoView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SwitchButton(
            label: 'Avaliações de Aula',
            selected: currentView == _AvaliacaoView.aulas,
            onTap: () => onChanged(_AvaliacaoView.aulas),
          ),
          const SizedBox(width: 8),
          _SwitchButton(
            label: 'Avaliações ao Professor',
            selected: currentView == _AvaliacaoView.professor,
            onTap: () => onChanged(_AvaliacaoView.professor),
          ),
        ],
      ),
    );
  }
}

class _SwitchButton extends StatelessWidget {
  const _SwitchButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF101828) : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF475467),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
