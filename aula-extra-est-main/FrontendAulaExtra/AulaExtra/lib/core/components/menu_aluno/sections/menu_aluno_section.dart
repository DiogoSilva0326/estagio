import 'package:aula_extra/core/components/menu_aluno/constants/menu_aluno_colors.dart';
import 'package:aula_extra/core/components/menu_aluno/constants/menu_aluno_items.dart';
import 'package:aula_extra/core/components/menu_aluno/widgets/menu_aluno_nav_item.dart';
import 'package:aula_extra/core/components/menu_aluno/widgets/menu_aluno_stat_row.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';
import 'package:aula_extra/core/data/auth/auth_service.dart';
import 'package:aula_extra/core/data/auth/available_roles.dart';
import 'package:aula_extra/core/data/session/preferences_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuAlunoSection extends StatefulWidget {
  const MenuAlunoSection({
    super.key,
    this.selectedIndex,
    this.creditsText,
    required this.notificationCount,
    required this.aulasEstaSemana,
    required this.tarefasPendentes,
    required this.proximaAulaEm,
    this.onItemTap,
  });

  final int? selectedIndex;
  final String? creditsText;
  final int notificationCount;

  final int aulasEstaSemana;
  final int tarefasPendentes;
  final String proximaAulaEm;

  final ValueChanged<int>? onItemTap;

  @override
  State<MenuAlunoSection> createState() => _MenuAlunoSectionState();
}

class _MenuAlunoSectionState extends State<MenuAlunoSection> {
  Set<Role> _availableRoles = const {Role.none};

  @override
  void initState() {
    super.initState();
    _loadAvailableRoles();
  }

  Future<void> _loadAvailableRoles() async {
    try {
      final available = await AvailableRoles.fetch();
      if (!mounted) return;
      setState(() => _availableRoles = available);
    } catch (_) {
      if (!mounted) return;
      setState(() => _availableRoles = const {Role.none});
    }
  }

  String? get _normalizedCreditsText {
    final value = widget.creditsText?.trim();
    if (value == null || value.isEmpty) return null;

    final digitsOnly = value.replaceAll(RegExp(r'[^0-9,]'), '').trim();
    if (digitsOnly.isEmpty) return value;
    return '$digitsOnly créditos';
  }

  Future<void> _switchRole(BuildContext context, Role role) async {
    final userProvider = context.read<UserProvider>();
    if (userProvider.role == role) return;

    userProvider.setRole(role);
    await PreferencesService.savePreferredRole(role.name);

    if (!context.mounted) return;
    if (role == Role.student) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.professorCalendario, (route) => false);
    }
  }

  Future<void> _handleLogoutTap(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;

    final userProvider = context.read<UserProvider>();
    userProvider.setAccount(null);
    userProvider.setRole(Role.none);
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
  }

  void _showRoleSwitcherDialog(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final available = {..._availableRoles, userProvider.role};
    final roles = [
      if (available.contains(Role.student)) Role.student,
      if (available.contains(Role.teacher)) Role.teacher,
      if (available.contains(Role.tutor)) Role.tutor,
      if (available.contains(Role.psychologist)) Role.psychologist,
    ];

    if (roles.length <= 1) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Mudar Perfil',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MenuAlunoColors.textHeading,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...roles.map((role) {
                    final title = switch (role) {
                      Role.student => 'Modo Aluno',
                      Role.teacher => 'Modo Explicador',
                      Role.tutor => 'Modo Tutor',
                      Role.psychologist => 'Modo Psicólogo',
                      Role.none => 'Sem sessão',
                    };
                    final icon = switch (role) {
                      Role.student => Icons.school_rounded,
                      Role.teacher => Icons.menu_book_rounded,
                      Role.tutor => Icons.psychology_alt_rounded,
                      Role.psychologist => Icons.health_and_safety_rounded,
                      Role.none => Icons.block,
                    };
                    final color = switch (role) {
                      Role.student => const Color(0xFF6B7280),
                      Role.teacher => TeachingRoleConfig.fromRole(Role.teacher).primaryColor,
                      Role.tutor => TeachingRoleConfig.fromRole(Role.tutor).primaryColor,
                      Role.psychologist => TeachingRoleConfig.fromRole(Role.psychologist).primaryColor,
                      Role.none => const Color(0xFF6B7280),
                    };

                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontWeight: userProvider.role == role ? FontWeight.bold : FontWeight.w500,
                          color: userProvider.role == role ? color : const Color(0xFF374151),
                        ),
                      ),
                      trailing: userProvider.role == role
                          ? Icon(Icons.check_circle_rounded, color: color)
                          : const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      onTap: () async {
                        Navigator.of(dialogContext).pop();
                        await _switchRole(context, role);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final canSwitch = ({..._availableRoles, userProvider.role}.where((item) => item != Role.none).length > 1);

    return SizedBox(
      width: 308,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MenuAlunoColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Menu do Estudante',
                style: TextStyle(
                  fontSize: 22,
                  height: 28 / 22,
                  fontWeight: FontWeight.w600,
                  color: MenuAlunoColors.textHeading,
                ),
              ),
              if (_normalizedCreditsText != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFFFD6A7)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(15, 23, 42, 0.06),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _normalizedCreditsText!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFCA3500),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ...List.generate(MenuAlunoItems.all.length, (index) {
                final item = MenuAlunoItems.all[index];
                final badgeCount = item.hasBadge ? widget.notificationCount : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MenuAlunoNavItem(
                    icon: item.icon,
                    label: item.label,
                    badgeCount: badgeCount,
                    selected: widget.selectedIndex == index,
                    onTap: widget.onItemTap == null ? null : () => widget.onItemTap!(index),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: MenuAlunoColors.divider),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estatísticas',
                      style: TextStyle(
                        fontSize: 22,
                        height: 20 / 22,
                        fontWeight: FontWeight.w600,
                        color: MenuAlunoColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 16),
                    MenuAlunoStatRow(
                      label: 'Apoios esta semana:',
                      value: '${widget.aulasEstaSemana}',
                      valueColor: MenuAlunoColors.accentOrange,
                    ),
                    const SizedBox(height: 12),
                    MenuAlunoStatRow(
                      label: 'Tarefas pendentes:',
                      value: '${widget.tarefasPendentes}',
                      valueColor: MenuAlunoColors.accentOrange,
                    ),
                    const SizedBox(height: 12),
                    MenuAlunoStatRow(
                      label: 'Próxima aula em:',
                      value: widget.proximaAulaEm,
                      valueColor: MenuAlunoColors.accentGreen,
                    ),
                    const SizedBox(height: 24),
                    if (canSwitch) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => _showRoleSwitcherDialog(context),
                          icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                          label: const Text(
                            'MUDAR DE PERFIL',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF374151),
                            side: const BorderSide(
                              color: Color(0xFFD1D5DB),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => _handleLogoutTap(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFF2B8B5),
                            width: 0.7,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'TERMINAR SESSÃO',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFD14343),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
