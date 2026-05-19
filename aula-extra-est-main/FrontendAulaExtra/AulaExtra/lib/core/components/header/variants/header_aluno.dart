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
import 'package:flutter_svg/flutter_svg.dart';

enum HeaderAlunoItem {
  inicio,
  minhasAulas,
  maisExplicadores, // Mantivemos o enum name para não quebrar referências, mas o texto é "Mais Profissionais"
  calendario,
  recursos,
}

class HeaderAluno extends StatelessWidget {
  const HeaderAluno({
    super.key,
    this.activeItem,
    this.displayName,
    this.creditsText,
    this.onInicioTap,
    this.onMinhasAulasTap,
    this.onMaisExplicadoresTap,
    this.onRecursosTap,
    this.onProfileTap,
    this.onRoleTap,
    this.onLogoTap,
  });

  final HeaderAlunoItem? activeItem;

  final String? displayName;
  final String? creditsText;

  final VoidCallback? onInicioTap;
  final VoidCallback? onMinhasAulasTap;
  final VoidCallback? onMaisExplicadoresTap;
  final VoidCallback? onRecursosTap;

  final VoidCallback? onProfileTap;
  final VoidCallback? onRoleTap;
  final VoidCallback? onLogoTap;

  static const double _designWidth = 1440;
  static const double _height = 90;

  static const _shadowColor = Color.fromRGBO(250, 189, 45, 0.18);
  static const Color _activeColor = Color(0xFFFC9039);

  void _handleMaisExplicadoresTap(BuildContext context) {
    if (onMaisExplicadoresTap != null) {
      onMaisExplicadoresTap!();
      return;
    }
    Navigator.of(context).pushNamed(Routes.explicadores);
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
    if (currentRouteName == Routes.calendario) return;
    Navigator.of(context).pushNamed(Routes.calendario);
  }

  Future<void> _handleLogoutTap(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    final user = context.read<UserProvider>();
    user.setAccount(null);
    user.setRole(Role.none);
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
  }

  void _handleRecursosTap(BuildContext context) {
    if (onRecursosTap != null) {
      onRecursosTap!();
      return;
    }

    Navigator.of(context).pushNamed(Routes.areasAluno);
  }

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

  Color? _itemColor(HeaderAlunoItem item) {
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
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 55,
            top: 10,
            child: InkWell(
              onTap: () => _handleLogoTap(context),
              child: SvgPicture.asset(
                HeaderAssets.logo,
                width: 96, 
                height: 69,
                fit: BoxFit.contain,
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
                  color: _itemColor(HeaderAlunoItem.inicio),
                  onTap: () => _handleInicioTap(context),
                ),
                const SizedBox(width: 40),
                HeaderLink(
                  text: 'Calendário',
                  color: _itemColor(HeaderAlunoItem.minhasAulas),
                  onTap: () => _handleMinhasAulasTap(context),
                ),
                const SizedBox(width: 40),
                HeaderLink(
                  text: 'Mais Apoios', 
                  color: _itemColor(HeaderAlunoItem.maisExplicadores),
                  onTap: () => _handleMaisExplicadoresTap(context),
                ),
                const SizedBox(width: 40),
                HeaderLink(
                  text: 'Recursos',
                  color: _itemColor(HeaderAlunoItem.recursos),
                  onTap: () => _handleRecursosTap(context),
                ),
                if (creditsText != null && creditsText!.trim().isNotEmpty) ...[
                  const SizedBox(width: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      '${creditsText!.replaceAll(RegExp(r'[^0-9]'), '').trim()} créditos',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFCA3500),
                      ),
                    ),
                  ),
                ],
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
                      final fallback = 'Estudante';
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
              imageUrl: context.watch<UserProvider>().account?.profileImageUrl,
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