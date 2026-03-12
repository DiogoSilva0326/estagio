import 'package:aula_extra/core/components/header/assets/header_assets.dart';
import 'package:aula_extra/core/components/header/widgets/header_link.dart';
import 'package:aula_extra/core/components/header/widgets/header_profile_button.dart';
import 'package:aula_extra/core/components/header/widgets/role_switcher_button.dart';
import 'package:aula_extra/core/components/header/widgets/scaled_header_container.dart';
import 'package:aula_extra/core/data/auth_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum HeaderExplicadorItem {
  inicio,
  minhasAulas,
  meusAlunos,
  recursos,
}

class HeaderExplicador extends StatelessWidget {
  const HeaderExplicador({
    super.key,
    this.activeItem,
    this.displayName,
    this.onInicioTap,
    this.onMinhasAulasTap,
    this.onMeusAlunosTap,
    this.onRecursosTap,
    this.onProfileTap,
    this.onRoleTap,
    this.onLogoTap,
  });

  final HeaderExplicadorItem? activeItem;

  final String? displayName;

  final VoidCallback? onInicioTap;
  final VoidCallback? onMinhasAulasTap;
  final VoidCallback? onMeusAlunosTap;
  final VoidCallback? onRecursosTap;

  final VoidCallback? onProfileTap;
  final VoidCallback? onRoleTap;
  final VoidCallback? onLogoTap;

  static const double _designWidth = 1440;
  static const double _height = 90;

  static const _shadowColor = Color.fromRGBO(250, 189, 45, 0.18);
  static const Color _activeColor = Color(0xFFFC9039);

  void _handleLogoTap(BuildContext context) {
    if (onLogoTap != null) {
      onLogoTap!();
      return;
    }

    final currentRouteName = ModalRoute.of(context)?.settings.name;
    if (currentRouteName == Routes.home) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
  }

  void _handleInicioTap(BuildContext context) {
    if (onInicioTap != null) {
      onInicioTap!();
      return;
    }

    final currentRouteName = ModalRoute.of(context)?.settings.name;
    if (currentRouteName == Routes.home) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
  }

  void _handleMinhasAulasTap(BuildContext context) {
    if (onMinhasAulasTap != null) {
      onMinhasAulasTap!();
      return;
    }

    final currentRouteName = ModalRoute.of(context)?.settings.name;
    if (currentRouteName == Routes.professorCalendario) return;
    Navigator.of(context).pushNamed(Routes.professorCalendario);
  }

  Future<void> _handleLogoutTap(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    final user = context.read<UserProvider>();
    user.setAccount(null);
    user.setRole(Role.none);
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
  }

  Color? _itemColor(HeaderExplicadorItem item) {
    if (activeItem == null) return null;
    return activeItem == item ? _activeColor : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return ScaledHeaderContainer(
      height: _height,
      designWidth: _designWidth,
      boxShadow: const [
        BoxShadow(
          color: _shadowColor,
          offset: Offset(0, 4),
          blurRadius: 4.6,
          spreadRadius: -1,
        ),
      ],
      child: Stack(
        children: [
          Positioned(
            left: 55,
            top: 10,
            child: InkWell(
              onTap: () => _handleLogoTap(context),
              child: Image.asset(
                HeaderAssets.logo,
                width: 96,
                height: 69,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 448,
            top: 35,
            child: Row(
              children: [
                HeaderLink(
                  text: 'Início',
                  color: _itemColor(HeaderExplicadorItem.inicio),
                  onTap: () => _handleInicioTap(context),
                ),
                const SizedBox(width: 40),
                HeaderLink(
                  text: 'Minhas Aulas',
                  color: _itemColor(HeaderExplicadorItem.minhasAulas),
                  onTap: () => _handleMinhasAulasTap(context),
                ),
                const SizedBox(width: 40),
                HeaderLink(
                  text: 'Meus alunos',
                  color: _itemColor(HeaderExplicadorItem.meusAlunos),
                  onTap: onMeusAlunosTap,
                ),
                const SizedBox(width: 40),
                HeaderLink(
                  text: 'Recursos',
                  color: _itemColor(HeaderExplicadorItem.recursos),
                  onTap: onRecursosTap,
                ),
              ],
            ),
          ),
          Positioned(
            right: 60,
            top: 22,
            child: SizedBox(
              width: 129,
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: onRoleTap ?? onProfileTap,
                  child: Builder(
                    builder: (_) {
                      final name = (displayName ?? '').trim();
                      final fallback = 'Explicador';
                      final effective = name.isNotEmpty ? name : fallback;

                      final parts = effective.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
                      final line1 = parts.isNotEmpty ? parts.first : fallback;
                      final line2 = parts.length > 1 ? parts.sublist(1).join(' ') : '';

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            line1,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          if (line2.isNotEmpty)
                            Text(
                              line2,
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 1255,
            top: 27,
            child: HeaderProfileButton(
              onTap: onProfileTap,
              onLogoutTap: () => _handleLogoutTap(context),
            ),
          ),
          const Positioned(
            left: 1208,
            top: 28,
            child: RoleSwitcherButton(size: 32),
          ),
        ],
      ),
    );
  }
}
