import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../constants/areas_disciplinas_mock_data.dart';
import '../models/area_disciplinas_item.dart';
import '../sections/areas_disciplinas_overview_section.dart';
import '../widgets/area_disciplinas_dialog.dart';

class AreasDisciplinasPage extends StatefulWidget {
  const AreasDisciplinasPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  State<AreasDisciplinasPage> createState() => _AreasDisciplinasPageState();
}

class _AreasDisciplinasPageState extends State<AreasDisciplinasPage> {
  late final List<AreaDisciplinasItem> _items;

  static const List<_AreaVisualStyle> _visualStyles = [
    _AreaVisualStyle(
      icon: Icons.calculate_rounded,
      iconBackgroundColor: Color(0x2641A7D7),
      iconColor: Color(0xFF41A7D7),
    ),
    _AreaVisualStyle(
      icon: Icons.biotech_outlined,
      iconBackgroundColor: Color(0x26FB7B02),
      iconColor: Color(0xFFFB7B02),
    ),
    _AreaVisualStyle(
      icon: Icons.menu_book_rounded,
      iconBackgroundColor: Color(0x80FFBDC0),
      iconColor: Color(0xFFF15C64),
    ),
    _AreaVisualStyle(
      icon: Icons.public_rounded,
      iconBackgroundColor: Color(0x2612B76A),
      iconColor: Color(0xFF12B76A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _items = List<AreaDisciplinasItem>.from(areasDisciplinasMockData);
  }

  @override
  Widget build(BuildContext context) {
    return BackofficeScaffold(
      currentRoute: AppRoutes.areasDisciplinas,
      title: 'Áreas e Disciplinas',
      showTopBar: false,
      body: _AreasDisciplinasBody(
        items: _items,
        onAddArea: _openAddAreaDialog,
        onEditArea: _openEditAreaDialog,
        onAddDisciplina: _openAddDisciplinaDialog,
      ),
    );
  }

  Future<void> _openAddAreaDialog() async {
    final style = _visualStyles[_items.length % _visualStyles.length];
    final result = await showDialog<AreaDisciplinasDialogResult>(
      context: context,
      builder: (dialogContext) => AreaDisciplinasDialog(
        mode: AreaDisciplinasDialogMode.area,
        icon: style.icon,
        iconBackgroundColor: style.iconBackgroundColor,
        iconColor: style.iconColor,
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _items.add(
        AreaDisciplinasItem(
          nome: result.areaName,
          explicadores: 0,
          disciplinas: result.disciplinas,
          icon: style.icon,
          iconBackgroundColor: style.iconBackgroundColor,
          iconColor: style.iconColor,
        ),
      );
    });
  }

  Future<void> _openEditAreaDialog(int index) async {
    final item = _items[index];
    final result = await showDialog<AreaDisciplinasDialogResult>(
      context: context,
      builder: (dialogContext) => AreaDisciplinasDialog(
        mode: AreaDisciplinasDialogMode.area,
        initialAreaName: item.nome,
        initialDisciplinas: item.disciplinas,
        icon: item.icon,
        iconBackgroundColor: item.iconBackgroundColor,
        iconColor: item.iconColor,
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _items[index] = item.copyWith(
        nome: result.areaName,
        disciplinas: result.disciplinas,
      );
    });
  }

  Future<void> _openAddDisciplinaDialog(int index) async {
    final item = _items[index];
    final result = await showDialog<AreaDisciplinasDialogResult>(
      context: context,
      builder: (dialogContext) => AreaDisciplinasDialog(
        mode: AreaDisciplinasDialogMode.disciplina,
        initialAreaName: item.nome,
        initialDisciplinas: item.disciplinas,
        icon: item.icon,
        iconBackgroundColor: item.iconBackgroundColor,
        iconColor: item.iconColor,
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _items[index] = item.copyWith(disciplinas: result.disciplinas);
    });
  }
}

class _AreasDisciplinasBody extends StatelessWidget {
  const _AreasDisciplinasBody({
    required this.items,
    required this.onAddArea,
    required this.onEditArea,
    required this.onAddDisciplina,
  });

  final List<AreaDisciplinasItem> items;
  final VoidCallback onAddArea;
  final ValueChanged<int> onEditArea;
  final ValueChanged<int> onAddDisciplina;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
                maxWidth: AreasDisciplinasPage._contentMaxWidth,
              ),
              child: AreasDisciplinasOverviewSection(
                items: items,
                onAddArea: onAddArea,
                onEditArea: onEditArea,
                onAddDisciplina: onAddDisciplina,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AreaVisualStyle {
  const _AreaVisualStyle({
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
}
