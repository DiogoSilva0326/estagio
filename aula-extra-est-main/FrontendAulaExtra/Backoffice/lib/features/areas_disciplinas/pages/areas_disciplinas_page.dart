import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../../explicadores/widgets/professional_directory_notice_card.dart';
import '../models/area_disciplinas_item.dart';
import '../sections/areas_disciplinas_overview_section.dart';
import '../services/backoffice_areas_disciplinas_service.dart';
import '../widgets/area_disciplinas_dialog.dart';

class AreasDisciplinasPage extends StatefulWidget {
  const AreasDisciplinasPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  State<AreasDisciplinasPage> createState() => _AreasDisciplinasPageState();
}

class _AreasDisciplinasPageState extends State<AreasDisciplinasPage> {
  late Future<BackofficeAreasDisciplinasViewData> _future;
  late final BackofficeAreasDisciplinasService _service;

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
    _service = BackofficeAreasDisciplinasService();
    _future = _load();
  }

  Future<BackofficeAreasDisciplinasViewData> _load() => _service.fetch();

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackofficeScaffold(
      currentRoute: AppRoutes.areasDisciplinas,
      title: 'Áreas e Disciplinas',
      showTopBar: false,
      body: _AreasDisciplinasBody(
        future: _future,
        onRetry: _reload,
        onAddArea: _openAddAreaDialog,
        onEditArea: _openEditAreaDialog,
        onAddDisciplina: _openAddDisciplinaDialog,
      ),
    );
  }

  Future<void> _openAddAreaDialog() async {
    final style = _visualStyles[DateTime.now().millisecond % _visualStyles.length];
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

    await _runMutation(
      () => _service.createArea(
        areaName: result.areaName,
        disciplinaNames: result.disciplinas,
        targetRole: result.targetRole,
      ),
      successMessage: 'Área criada com sucesso.',
    );
  }

  Future<void> _openEditAreaDialog(AreaDisciplinasItem item) async {
    final result = await showDialog<AreaDisciplinasDialogResult>(
      context: context,
      builder: (dialogContext) => AreaDisciplinasDialog(
        mode: AreaDisciplinasDialogMode.area,
        initialAreaName: item.nome,
        initialTargetRole: item.targetRole, 
        initialDisciplinas: item.disciplinas.map((disciplina) => disciplina.nome).toList(growable: false),
        icon: item.icon,
        iconBackgroundColor: item.iconBackgroundColor,
        iconColor: item.iconColor,
      ),
    );

    if (result == null) {
      return;
    }

    await _runMutation(
      () => _service.updateAreaAndDisciplinas(
        area: item,
        areaName: result.areaName,
        disciplinaNames: result.disciplinas,
        targetRole: result.targetRole, 
      ),
      successMessage: 'Área atualizada com sucesso.',
    );
  }

  Future<void> _openAddDisciplinaDialog(AreaDisciplinasItem item) async {
    final result = await showDialog<AreaDisciplinasDialogResult>(
      context: context,
      builder: (dialogContext) => AreaDisciplinasDialog(
        mode: AreaDisciplinasDialogMode.disciplina,
        initialAreaName: item.nome,
        initialTargetRole: item.targetRole, 
        initialDisciplinas: item.disciplinas.map((disciplina) => disciplina.nome).toList(growable: false),
        icon: item.icon,
        iconBackgroundColor: item.iconBackgroundColor,
        iconColor: item.iconColor,
      ),
    );

    if (result == null) {
      return;
    }

    await _runMutation(
      () => _service.updateAreaAndDisciplinas(
        area: item,
        areaName: item.nome,
        disciplinaNames: result.disciplinas,
        targetRole: item.targetRole,
      ),
      successMessage: 'Disciplinas atualizadas com sucesso.',
    );
  }

  Future<void> _runMutation(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    try {
      await action();
      if (!mounted) {
        return;
      }

      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível concluir a ação: $error')),
      );
    }
  }
}

class _AreasDisciplinasBody extends StatelessWidget {
  const _AreasDisciplinasBody({
    required this.future,
    required this.onRetry,
    required this.onAddArea,
    required this.onEditArea,
    required this.onAddDisciplina,
  });

  final Future<BackofficeAreasDisciplinasViewData> future;
  final VoidCallback onRetry;
  final VoidCallback onAddArea;
  final ValueChanged<AreaDisciplinasItem> onEditArea;
  final ValueChanged<AreaDisciplinasItem> onAddDisciplina;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 900 ? 24.0 : 55.91;
        final verticalPadding = constraints.maxWidth < 900 ? 24.0 : 55.91;

        return Align(
          alignment: Alignment.topCenter,
          child: FutureBuilder<BackofficeAreasDisciplinasViewData>(
            future: future,
            builder: (context, snapshot) {
              final data = snapshot.data ??
                  const BackofficeAreasDisciplinasViewData(
                    items: <AreaDisciplinasItem>[],
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

              return SingleChildScrollView(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.warningMessage != null) ...[
                        ProfessionalDirectoryNoticeCard(
                          message: data.warningMessage!,
                          onRetry: onRetry,
                        ),
                        const SizedBox(height: 24),
                      ],
                      AreasDisciplinasOverviewSection(
                        items: data.items,
                        onAddArea: onAddArea,
                        onEditArea: onEditArea,
                        onAddDisciplina: onAddDisciplina,
                      ),
                    ],
                  ),
                ),
              );
            },
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