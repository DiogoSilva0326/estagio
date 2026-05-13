import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../models/reclamacao_item.dart';
import '../sections/reclamacoes_overview_section.dart';
import '../services/backoffice_reclamacoes_service.dart';

class ReclamacoesPage extends StatefulWidget {
  const ReclamacoesPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  State<ReclamacoesPage> createState() => _ReclamacoesPageState();
}

class _ReclamacoesPageState extends State<ReclamacoesPage> {
  final BackofficeReclamacoesService _service = BackofficeReclamacoesService();
  late final TextEditingController _searchController;
  List<ReclamacaoItem> _complaintItems = <ReclamacaoItem>[];
  List<ReclamacaoItem> _paymentDisputeItems = <ReclamacaoItem>[];
  List<ReclamacaoItem> _visibleItems = <ReclamacaoItem>[];
  String? _selectedType;
  ReclamacaoSource _selectedSource = ReclamacaoSource.utilizadores;
  bool _loading = true;
  String? _warningMessage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackofficeScaffold(
      currentRoute: AppRoutes.reclamacoes,
      title: 'Reclamações',
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
                  maxWidth: ReclamacoesPage._contentMaxWidth,
                ),
                child: ReclamacoesOverviewSection(
                  items: _visibleItems,
                  selectedSource: _selectedSource,
                  searchController: _searchController,
                  types: _availableTypes,
                  selectedType: _selectedType,
                  isLoading: _loading,
                  warningMessage: _warningMessage,
                  onDataChanged: _load,
                  onSourceChanged: (value) {
                    setState(() {
                      _selectedSource = value;
                      _selectedType = null;
                    });
                    _applyFilters(_searchController.text);
                  },
                  onSearchChanged: _applyFilters,
                  onTypeChanged: (value) {
                    setState(() => _selectedType = value);
                    _applyFilters(_searchController.text);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> get _availableTypes {
    final types = _activeItems
        .map((item) => item.type.trim())
        .where((type) => type.isNotEmpty)
        .toSet()
        .toList();
    types.sort((left, right) => left.toLowerCase().compareTo(right.toLowerCase()));
    return types;
  }

  List<ReclamacaoItem> get _activeItems =>
      _selectedSource == ReclamacaoSource.utilizadores
          ? _complaintItems
          : _paymentDisputeItems;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _warningMessage = null;
    });

    try {
      final data = await _service.fetchData();
      if (!mounted) {
        return;
      }

      setState(() {
        _complaintItems = data.complaints;
        _paymentDisputeItems = data.paymentDisputes;
        _visibleItems = _activeItems;
        _loading = false;
      });
      _applyFilters(_searchController.text);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _warningMessage = 'Não foi possível carregar as reclamações da API. $error';
      });
    }
  }

  void _applyFilters(String rawQuery) {
    final query = rawQuery.trim().toLowerCase();
    final activeItems = _activeItems;

    setState(() {
      _visibleItems = activeItems.where((item) {
        final matchesType = _selectedType == null || item.type == _selectedType;
        final matchesQuery =
            query.isEmpty ||
            item.id.toLowerCase().contains(query) ||
            item.dateLabel.toLowerCase().contains(query) ||
            item.profileName.toLowerCase().contains(query) ||
            item.profileEmail.toLowerCase().contains(query) ||
            item.type.toLowerCase().contains(query) ||
            item.statusLabel.toLowerCase().contains(query) ||
            item.title.toLowerCase().contains(query);
        return matchesType && matchesQuery;
      }).toList();
    });
  }
}
