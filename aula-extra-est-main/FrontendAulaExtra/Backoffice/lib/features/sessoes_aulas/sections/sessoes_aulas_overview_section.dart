import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/csv_exporter.dart';
import '../../explicadores/widgets/professional_directory_notice_card.dart';
import '../models/sessao_aula_item.dart';
import '../services/backoffice_sessoes_aulas_service.dart';
import 'sessoes_aulas_header_section.dart';
import 'sessoes_aulas_table_section.dart';

class SessoesAulasOverviewSection extends StatefulWidget {
  const SessoesAulasOverviewSection({super.key});

  @override
  State<SessoesAulasOverviewSection> createState() =>
      _SessoesAulasOverviewSectionState();
}

class _SessoesAulasOverviewSectionState extends State<SessoesAulasOverviewSection> {
  late Future<BackofficeSessoesAulasViewData> _future;
  late final TextEditingController _searchController;
  final Set<String> _selectedIds = <String>{};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _future = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<BackofficeSessoesAulasViewData> _load() {
    return BackofficeSessoesAulasService().fetch();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  List<SessaoAulaItem> _applySearch(List<SessaoAulaItem> items) {
    final query = _normalize(_searchQuery);
    if (query.isEmpty) {
      return items;
    }

    return items.where((item) {
      return <String>[
        item.codigo,
        item.aluno,
        item.explicador,
        item.disciplina,
        item.dataHora,
        item.statusLabel,
        item.channelName ?? '',
        item.reservationId,
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

  Future<void> _exportSelectedCsv(List<SessaoAulaItem> allItems) async {
    final selectedItems = allItems
        .where((item) => _selectedIds.contains(item.id))
        .toList(growable: false);

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Selecione pelo menos uma sessão para exportar.'),
          ),
        );
      return;
    }

    final content = _buildCsv(selectedItems);
    final exportName =
        'sessoes_aulas_${DateTime.now().millisecondsSinceEpoch}.csv';

    try {
      final location = await exportCsvFile(
        fileName: exportName,
        content: content,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('CSV exportado com sucesso para $location.')),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Não foi possível exportar o CSV. $error')),
        );
    }
  }

  String _buildCsv(List<SessaoAulaItem> items) {
    final rows = <List<String>>[
      <String>[
        'Codigo',
        'Aluno',
        'Explicador',
        'Disciplina',
        'DataHora',
        'Duracao',
        'Estado',
        'Canal',
        'ReservaId',
        'VideoCallId',
      ],
      ...items.map(
        (item) => <String>[
          item.codigo,
          item.aluno,
          item.explicador,
          item.disciplina,
          item.dataHora,
          item.duracao,
          item.statusLabel,
          item.channelName ?? '',
          item.reservationId,
          item.videoCallId ?? '',
        ],
      ),
    ];

    return rows.map((row) => row.map(_escapeCsv).join(',')).join('\n');
  }

  String _escapeCsv(String value) {
    final normalized = value.replaceAll('"', '""');
    return '"$normalized"';
  }

  Future<void> _openLink(SessaoAulaItem item) async {
    if (item.recordingUrl != null && item.recordingUrl!.isNotEmpty) {
      final uri = Uri.tryParse(item.recordingUrl!);
      if (uri != null) {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched || !mounted) {
          return;
        }
      }
    }

    if (item.channelName != null && item.channelName!.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: item.channelName!));
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Canal ${item.channelName!} copiado para a área de transferência.'),
          ),
        );
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Não existe um link disponível para esta sessão.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BackofficeSessoesAulasViewData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data ??
            const BackofficeSessoesAulasViewData(items: <SessaoAulaItem>[]);
        final visibleItems = _applySearch(data.items);

        _selectedIds.removeWhere(
          (id) => !data.items.any((item) => item.id == id),
        );

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SessoesAulasHeaderSection(
              searchController: _searchController,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onExportPressed: () => _exportSelectedCsv(data.items),
              exportEnabled: _selectedIds.isNotEmpty,
            ),
            if (data.warningMessage != null) ...[
              const SizedBox(height: 24),
              ProfessionalDirectoryNoticeCard(
                message: data.warningMessage!,
                onRetry: _reload,
              ),
            ],
            const SizedBox(height: 37.273),
            SessoesAulasTableSection(
              items: visibleItems,
              selectedIds: _selectedIds,
              onOpenLink: _openLink,
              onSelectionChanged: (id, selected) {
                setState(() {
                  if (selected) {
                    _selectedIds.add(id);
                  } else {
                    _selectedIds.remove(id);
                  }
                });
              },
              onSelectAll: (selected) {
                setState(() {
                  if (selected) {
                    _selectedIds.addAll(visibleItems.map((item) => item.id));
                  } else {
                    _selectedIds.removeAll(visibleItems.map((item) => item.id));
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }
}
