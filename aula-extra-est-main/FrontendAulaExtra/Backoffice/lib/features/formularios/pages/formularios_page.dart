import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../constants/formularios_mock_data.dart';
import '../models/formulario_item.dart';
import '../sections/formularios_overview_section.dart';

class FormulariosPage extends StatefulWidget {
  const FormulariosPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  State<FormulariosPage> createState() => _FormulariosPageState();
}

class _FormulariosPageState extends State<FormulariosPage> {
  late final TextEditingController _searchController;
  late final List<FormularioItem> _allItems;
  late List<FormularioItem> _visibleItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _allItems = List<FormularioItem>.from(FormulariosMockData.items);
    _visibleItems = _allItems;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackofficeScaffold(
      currentRoute: AppRoutes.formularios,
      title: 'Formulários',
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
                  maxWidth: FormulariosPage._contentMaxWidth,
                ),
                child: FormulariosOverviewSection(
                  items: _visibleItems,
                  searchController: _searchController,
                  onSearchChanged: _onSearchChanged,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onSearchChanged(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _visibleItems = _allItems;
        return;
      }

      _visibleItems = _allItems.where((item) {
        return item.id.toLowerCase().contains(query) ||
            item.dateLabel.toLowerCase().contains(query) ||
            item.profileName.toLowerCase().contains(query) ||
            item.profileEmail.toLowerCase().contains(query) ||
            item.formName.toLowerCase().contains(query) ||
            item.statusLabel.toLowerCase().contains(query);
      }).toList();
    });
  }
}
