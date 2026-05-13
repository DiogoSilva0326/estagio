import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../models/plano_item.dart';
import '../sections/planos_precos_overview_section.dart';
import '../services/backoffice_planos_precos_service.dart';
import '../widgets/novo_plano_dialog.dart';

class PlanosPrecosPage extends StatefulWidget {
  const PlanosPrecosPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  State<PlanosPrecosPage> createState() => _PlanosPrecosPageState();
}

class _PlanosPrecosPageState extends State<PlanosPrecosPage> {
  late final TextEditingController _commissionController;
  final BackofficePlanosPrecosService _service = BackofficePlanosPrecosService();
  List<PlanoItem> _items = const [];
  List<BackofficePlanCourseOption> _courses = const [];

  @override
  void initState() {
    super.initState();
    _commissionController = TextEditingController(text: '20');
    _load();
  }

  @override
  void dispose() {
    _commissionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackofficeScaffold(
      currentRoute: AppRoutes.planosPrecos,
      title: 'Planos / Preços',
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
                  maxWidth: PlanosPrecosPage._contentMaxWidth,
                ),
                child: PlanosPrecosOverviewSection(
                  items: _items,
                  commissionController: _commissionController,
                  onCreatePlan: _openCreatePlanDialog,
                  onSaveCommission: _saveCommission,
                  onEditPlan: _openEditPlanDialog,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openCreatePlanDialog() async {
    if (_courses.isEmpty) {
      _showSnackBar('Não existem cursos disponíveis para associar a um plano.');
      return;
    }

    final result = await showDialog<NovoPlanoDialogResult>(
      context: context,
      barrierColor: const Color(0x73000000),
      builder: (_) => NovoPlanoDialog(
        courses: _dialogCourses,
        subtitle: 'Crie um novo plano com nome, descrição e preço.',
      ),
    );

    if (result == null) {
      return;
    }

    try {
      await _service.createPlan(_draftFromDialog(result));
      await _load();
      _showSnackBar('Plano criado com sucesso.');
    } catch (_) {
      _showSnackBar('Não foi possível criar o plano.');
    }
  }

  Future<void> _openEditPlanDialog(int index) async {
    final item = _items[index];
    final result = await showDialog<NovoPlanoDialogResult>(
      context: context,
      barrierColor: const Color(0x73000000),
      builder: (_) => NovoPlanoDialog(
        courses: _dialogCourses,
        title: 'Editar Plano',
        subtitle: 'Atualize o nome, descrição e preço do plano selecionado.',
        submitLabel: 'Guardar alterações',
        initialCourseId: item.courseId,
        initialName: item.name,
        initialDescription: item.description.replaceAll('\n', ' '),
        initialPrice: item.priceLabel.replaceAll('€', ''),
        initialNumberOfLessons: item.numberOfLessons,
        initialIsActive: item.isActive,
      ),
    );

    if (result == null) {
      return;
    }

    try {
      await _service.updatePlan(item.id, _draftFromDialog(result));
      await _load();
      _showSnackBar('Plano atualizado com sucesso.');
    } catch (_) {
      _showSnackBar('Não foi possível atualizar o plano.');
    }
  }

  Future<void> _saveCommission() async {
    final normalized = _commissionController.text.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      _showSnackBar('Indique uma comissão válida.');
      return;
    }

    try {
      await _service.saveBaseCommission(normalized);
      _showSnackBar('Comissão base atualizada para $normalized%.');
    } catch (_) {
      _showSnackBar('Não foi possível guardar a comissão base.');
    }
  }

  Future<void> _load() async {
    try {
      final data = await _service.fetchData();
      if (!mounted) {
        return;
      }

      setState(() {
        _items = data.items;
        _courses = data.courses;
        _commissionController.text = data.baseCommission;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _items = const [];
        _courses = const [];
      });
    }
  }

  List<NovoPlanoDialogCourseOption> get _dialogCourses => _courses
      .map((course) => NovoPlanoDialogCourseOption(id: course.id, name: course.name))
      .toList(growable: false);

  BackofficePlanDraft _draftFromDialog(NovoPlanoDialogResult result) {
    final normalized = result.price.replaceAll('€', '').replaceAll(',', '.').trim();
    return BackofficePlanDraft(
      courseId: result.courseId,
      name: result.name,
      description: result.description,
      price: double.tryParse(normalized) ?? 0,
      numberOfLessons: result.numberOfLessons,
      isActive: result.isActive,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
