import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../constants/planos_precos_mock_data.dart';
import '../models/plano_item.dart';
import '../sections/planos_precos_overview_section.dart';
import '../widgets/novo_plano_dialog.dart';

class PlanosPrecosPage extends StatefulWidget {
  const PlanosPrecosPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  State<PlanosPrecosPage> createState() => _PlanosPrecosPageState();
}

class _PlanosPrecosPageState extends State<PlanosPrecosPage> {
  late final TextEditingController _commissionController;
  late final List<PlanoItem> _items;

  static const List<_PlanVisualStyle> _styles = [
    _PlanVisualStyle(
      badgeLabel: 'ATIVO',
      badgeBackgroundColor: Color(0xFFEAFBF3),
      badgeTextColor: Color(0xFF027A48),
      icon: Icons.school_outlined,
      iconBackgroundColor: Color(0xFFEAF2FB),
      iconColor: Color(0xFF41A7D7),
    ),
    _PlanVisualStyle(
      badgeLabel: 'POPULAR',
      badgeBackgroundColor: Color(0xFFFFF2E8),
      badgeTextColor: Color(0xFFFB7B02),
      icon: Icons.workspace_premium_outlined,
      iconBackgroundColor: Color(0xFFFFF2E8),
      iconColor: Color(0xFFFB7B02),
    ),
    _PlanVisualStyle(
      badgeLabel: 'CUSTOM',
      badgeBackgroundColor: Color(0xFFEEF2FF),
      badgeTextColor: Color(0xFF4F46E5),
      icon: Icons.tune_rounded,
      iconBackgroundColor: Color(0xFFFCEFE4),
      iconColor: Color(0xFFFC9039),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _commissionController = TextEditingController(text: basePlatformCommission);
    _items = List<PlanoItem>.from(planosPrecosMockData);
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
    final result = await showDialog<NovoPlanoDialogResult>(
      context: context,
      barrierColor: const Color(0x73000000),
      builder: (_) => const NovoPlanoDialog(),
    );

    if (result == null) {
      return;
    }

    final style = _styles[_items.length % _styles.length];
    final normalizedPrice = result.price.contains('€')
        ? result.price
        : '${result.price}€';

    setState(() {
      _items.add(
        PlanoItem(
          name: result.name,
          subtitle: 'Plano criado manualmente para novos cenários.',
          description:
              'Plano configurável para diferentes necessidades, com preço personalizado e edição futura disponível.',
          priceLabel: normalizedPrice,
          badgeLabel: style.badgeLabel,
          badgeBackgroundColor: style.badgeBackgroundColor,
          badgeTextColor: style.badgeTextColor,
          icon: style.icon,
          iconBackgroundColor: style.iconBackgroundColor,
          iconColor: style.iconColor,
        ),
      );
    });
  }

  Future<void> _openEditPlanDialog(int index) async {
    final item = _items[index];
    final result = await showDialog<NovoPlanoDialogResult>(
      context: context,
      barrierColor: const Color(0x73000000),
      builder: (_) => NovoPlanoDialog(
        title: 'Editar Plano',
        subtitle: 'Atualize o nome e o preço do plano selecionado.',
        submitLabel: 'Guardar alterações',
        initialName: item.name,
        initialPrice: item.priceLabel.replaceAll('€', ''),
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _items[index] = item.copyWith(
        name: result.name,
        priceLabel: result.price.contains('€')
            ? result.price
            : '${result.price}€',
      );
    });
  }

  void _saveCommission() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Comissão base atualizada para ${_commissionController.text.trim()}%.',
          ),
        ),
      );
  }
}

class _PlanVisualStyle {
  const _PlanVisualStyle({
    required this.badgeLabel,
    required this.badgeBackgroundColor,
    required this.badgeTextColor,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
  });

  final String badgeLabel;
  final Color badgeBackgroundColor;
  final Color badgeTextColor;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
}
