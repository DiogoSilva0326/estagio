import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../constants/mensagens_mock_data.dart';
import '../models/mensagem_thread.dart';
import '../sections/mensagens_overview_section.dart';

class MensagensPage extends StatefulWidget {
  const MensagensPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  State<MensagensPage> createState() => _MensagensPageState();
}

class _MensagensPageState extends State<MensagensPage> {
  late final TextEditingController _searchController;
  late final List<MensagemThread> _allThreads;
  MensagemThreadType? _selectedType;
  late List<MensagemThread> _visibleThreads;
  MensagemThread? _selectedThread;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _allThreads = List<MensagemThread>.from(MensagensMockData.threads);
    _visibleThreads = _allThreads;
    _selectedThread = _visibleThreads.isNotEmpty ? _visibleThreads.first : null;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackofficeScaffold(
      currentRoute: AppRoutes.mensagens,
      title: 'Mensagens',
      showTopBar: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 900 ? 24.0 : 55.91;
          final verticalPadding = constraints.maxWidth < 900 ? 24.0 : 55.91;

          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: MensagensPage._contentMaxWidth,
                ),
                child: MensagensOverviewSection(
                  threads: _visibleThreads,
                  selectedType: _selectedType,
                  selectedThread: _selectedThread,
                  searchController: _searchController,
                  onSearchChanged: _applyFilters,
                  onSelectType: (value) {
                    setState(() => _selectedType = value);
                    _applyFilters(_searchController.text);
                  },
                  onSelectThread: (thread) {
                    setState(() => _selectedThread = thread);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _applyFilters(String rawQuery) {
    final query = rawQuery.trim().toLowerCase();
    final filtered = _allThreads.where((thread) {
      final matchesType = _selectedType == null || thread.type == _selectedType;
      final matchesQuery =
          query.isEmpty ||
          thread.title.toLowerCase().contains(query) ||
          thread.subtitle.toLowerCase().contains(query) ||
          thread.lastMessage.toLowerCase().contains(query);
      return matchesType && matchesQuery;
    }).toList();

    setState(() {
      _visibleThreads = filtered;
      if (_selectedThread == null ||
          !_visibleThreads.any((thread) => thread.id == _selectedThread!.id)) {
        _selectedThread = _visibleThreads.isNotEmpty
            ? _visibleThreads.first
            : null;
      }
    });
  }
}
