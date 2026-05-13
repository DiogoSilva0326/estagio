import 'package:aula_extra/core/components/menu_professor/constants/menu_professor_colors.dart';
import 'package:aula_extra/core/components/menu_professor/constants/menu_professor_items.dart';
import 'package:aula_extra/core/components/menu_professor/widgets/menu_professor_nav_item.dart';
import 'package:aula_extra/core/components/menu_professor/widgets/menu_professor_stat_row.dart';
import 'package:aula_extra/core/providers/user_provider.dart'; 
import 'package:aula_extra/core/config/teaching_roles_config.dart'; 
import 'package:aula_extra/core/data/auth_service.dart';
import 'package:aula_extra/routes/routes.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuProfessorSection extends StatelessWidget {
  const MenuProfessorSection({
    super.key,
    this.selectedIndex,
    required this.notificationCount,
    required this.aulasEstaSemana,
    required this.ganhosPendentes,
    required this.alunosAtivos,
    this.onItemTap,
    this.config,
  });

  final TeachingRoleConfig? config; 
  final int? selectedIndex;
  final int notificationCount;

  final int aulasEstaSemana;
  final String ganhosPendentes;
  final int alunosAtivos;

  final ValueChanged<int>? onItemTap;

  Future<void> _handleLogoutTap(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    final user = context.read<UserProvider>();
    user.setAccount(null);
    user.setRole(Role.none);
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
  }

  void _showRoleSwitcherDialog(BuildContext context, UserProvider userProvider) {
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
                        color: MenuProfessorColors.textHeading,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RoleTile(
                    title: 'Modo Aluno',
                    icon: Icons.school_rounded,
                    color: const Color(0xFF6B7280),
                    isActive: userProvider.role == Role.student,
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      userProvider.setRole(Role.student);
                      Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  _RoleTile(
                    title: 'Modo Explicador',
                    icon: Icons.menu_book_rounded,
                    color: TeachingRoleConfig.fromRole(Role.teacher).primaryColor,
                    isActive: userProvider.role == Role.teacher,
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      userProvider.setRole(Role.teacher);
                      Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
                    },
                  ),
                  _RoleTile(
                    title: 'Modo Tutor',
                    icon: Icons.psychology_alt_rounded,
                    color: TeachingRoleConfig.fromRole(Role.tutor).primaryColor,
                    isActive: userProvider.role == Role.tutor,
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      userProvider.setRole(Role.tutor);
                      Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
                    },
                  ),
                  _RoleTile(
                    title: 'Modo Psicólogo',
                    icon: Icons.health_and_safety_rounded,
                    color: TeachingRoleConfig.fromRole(Role.psychologist).primaryColor,
                    isActive: userProvider.role == Role.psychologist,
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      userProvider.setRole(Role.psychologist);
                      Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
                    },
                  ),
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
    final userProvider = Provider.of<UserProvider>(context);
    
    final resolvedConfig = config ?? TeachingRoleConfig.fromRole(userProvider.role);

    return SizedBox(
      width: 307.765,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MenuProfessorColors.background,
          borderRadius: BorderRadius.circular(20),
          border: const Border(
            right: BorderSide(color: MenuProfessorColors.divider, width: 1.231),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(19.697, 19.697, 39.394, 19.697),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 34.47,
                  child: Text(
                    resolvedConfig.menu.menuTitle, 
                    style: const TextStyle(
                      fontSize: 22.159,
                      height: 34.47 / 22.159,
                      fontWeight: FontWeight.w600,
                      color: MenuProfessorColors.textHeading,
                    ),
                  ),
                ),
                const SizedBox(height: 19.697),
                ...List.generate(MenuProfessorItems.all.length, (index) {
                  final item = MenuProfessorItems.all[index];

                  final badgeCount = item.hasBadge ? notificationCount : null;
                  
                  String label = item.label;
                  
                  if (label == 'Meus Alunos') {
                    label = resolvedConfig.studentsLabel; 
                  } else if (label == 'Minhas Disciplinas') {
                    label = resolvedConfig.perfil.subjectsSectionTitle; 
                  } else if (label == 'Calendário') {
                    label = resolvedConfig.calendarLabel; 
                  }

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == MenuProfessorItems.all.length - 1 ? 0 : 4.924,
                    ),
                    child: MenuProfessorNavItem(
                      icon: item.icon,
                      label: label, 
                      badgeCount: badgeCount,
                      selected: selectedIndex == index,
                      activeColor: resolvedConfig.primaryColor,
                      onTap: onItemTap == null ? null : () => onItemTap!(index),
                    ),
                  );
                }),
                const SizedBox(height: 19.697),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(19.697, 19.697, 19.697, 19.697),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(19.697),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [resolvedConfig.surfaceColor, resolvedConfig.primaryLight],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 33.239,
                        child: Text(
                          'Estatísticas',
                          style: TextStyle(
                            fontSize: 22.159,
                            height: 33.239 / 22.159,
                            fontWeight: FontWeight.w600,
                            color: MenuProfessorColors.textHeading,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14.773),
                      MenuProfessorStatRow(
                        label: resolvedConfig.menu.statsSessionsLabel, 
                        value: '$aulasEstaSemana',
                        valueColor: resolvedConfig.primaryColor,
                      ),
                      const SizedBox(height: 9.848),
                      MenuProfessorStatRow(
                        label: 'Ganhos pendentes:',
                        value: ganhosPendentes,
                        valueColor: MenuProfessorColors.accentGreen,
                      ),
                      const SizedBox(height: 9.848),
                      MenuProfessorStatRow(
                        label: resolvedConfig.menu.statsActiveLabel,
                        value: '$alunosAtivos',
                        valueColor: MenuProfessorColors.accentBlue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _showRoleSwitcherDialog(context, userProvider),
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
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          color: isActive ? color : const Color(0xFF374151),
        ),
      ),
      trailing: isActive
          ? Icon(Icons.check_circle_rounded, color: color)
          : const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: onTap,
    );
  }
}