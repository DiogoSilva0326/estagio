import 'package:flutter/material.dart';

import '../../explicadores/widgets/professional_directory_notice_card.dart';
import '../../explicadores/models/explicador_item.dart';
import '../../profissionais/services/backoffice_professionals_service.dart';
import 'tutores_header_section.dart';
import 'tutores_table_section.dart';

class TutoresOverviewSection extends StatefulWidget {
  const TutoresOverviewSection({super.key});

  @override
  State<TutoresOverviewSection> createState() => _TutoresOverviewSectionState();
}

class _TutoresOverviewSectionState extends State<TutoresOverviewSection> {
  late Future<BackofficeProfessionalsViewData> _future;
  late final TextEditingController _searchController;
  String _searchQuery = '';
  String _statusFilter = 'TODOS';
  String _areaFilter = 'TODAS';
  String _verificationFilter = 'TODOS';

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

  Future<BackofficeProfessionalsViewData> _load() {
    return BackofficeProfessionalsService().fetch(
      BackofficeProfessionalCategory.tutores,
    );
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  List<String> _buildAreaOptions(List<ExplicadorItem> items) {
    final areas = items
        .map((item) => item.areaLabel.trim())
        .where((area) => area.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return <String>['TODAS', ...areas];
  }

  List<ExplicadorItem> _applyFilters(List<ExplicadorItem> items) {
    final normalizedQuery = _normalize(_searchQuery);

    return items.where((item) {
      final matchesSearch =
          normalizedQuery.isEmpty ||
          <String>[
            item.name,
            item.email,
            item.phone ?? '',
            item.areaLabel,
            item.mainSubject,
            item.location ?? '',
            item.statusLabel,
            item.verifiedLabel,
          ].map(_normalize).any((value) => value.contains(normalizedQuery));

      final matchesStatus =
          _statusFilter == 'TODOS' || item.statusLabel == _statusFilter;
      final matchesArea =
          _areaFilter == 'TODAS' || item.areaLabel == _areaFilter;
      final matchesVerification =
          _verificationFilter == 'TODOS' ||
          item.verifiedLabel == _verificationFilter;

      return matchesSearch &&
          matchesStatus &&
          matchesArea &&
          matchesVerification;
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
    return FutureBuilder<BackofficeProfessionalsViewData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data ??
            const BackofficeProfessionalsViewData(items: <ExplicadorItem>[]);
        final areaOptions = _buildAreaOptions(data.items);
        if (!areaOptions.contains(_areaFilter)) {
          _areaFilter = 'TODAS';
        }
        final filteredItems = _applyFilters(data.items);

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
            TutoresHeaderSection(
              searchController: _searchController,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            if (data.warningMessage != null) ...[
              const SizedBox(height: 24),
              ProfessionalDirectoryNoticeCard(
                message: data.warningMessage!,
                onRetry: _reload,
              ),
            ],
            const SizedBox(height: 37.273),
            TutoresTableSection(
              items: filteredItems,
              statusFilter: _statusFilter,
              areaFilter: _areaFilter,
              verificationFilter: _verificationFilter,
              areaOptions: areaOptions,
              onReviewUpdated: _reload,
              onStatusChanged: (value) {
                setState(() {
                  _statusFilter = value;
                });
              },
              onAreaChanged: (value) {
                setState(() {
                  _areaFilter = value;
                });
              },
              onVerificationChanged: (value) {
                setState(() {
                  _verificationFilter = value;
                });
              },
            ),
          ],
        );
      },
    );
  }
}
