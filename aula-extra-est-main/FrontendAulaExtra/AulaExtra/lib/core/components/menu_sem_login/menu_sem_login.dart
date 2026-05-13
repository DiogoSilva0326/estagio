import 'package:aula_extra/core/components/header/assets/header_assets.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Menu lateral (drawer) exibido para utilizadores não autenticados.
/// Design baseado no Figma: node 4112:38485
class MenuSemLogin extends StatelessWidget {
  const MenuSemLogin({
    super.key,
    this.onClose,
    this.onRegisterTap,
    this.onLoginTap,
    this.navigationItems,
    this.actionButtons,
    this.headerContent,
  });

  final VoidCallback? onClose;
  final VoidCallback? onRegisterTap;
  final VoidCallback? onLoginTap;
  final List<MenuDrawerItem>? navigationItems;
  final List<MenuDrawerAction>? actionButtons;
  final Widget? headerContent;

  static const double menuWidth = 308;
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _textColor = Color(0xFF364153);

  List<MenuDrawerItem> _defaultNavigationItems(BuildContext context) {
    return [
      MenuDrawerItem(
        icon: Icons.home_outlined,
        label: 'Como Funciona',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(Routes.home);
        },
      ),
      MenuDrawerItem(
        icon: Icons.menu_book_outlined,
        label: 'Disciplinas',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(Routes.disciplinas);
        },
      ),
      MenuDrawerItem(
        icon: Icons.school_outlined,
        label: 'Explicadores',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(Routes.explicadores);
        },
      ),
    ];
  }

  List<MenuDrawerAction> _defaultActionButtons(BuildContext context) {
    return [
      MenuDrawerAction(
        label: 'REGISTAR-ME',
        filled: false,
        onTap:
            onRegisterTap ??
            () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Routes.registerStudent);
            },
      ),
      MenuDrawerAction(
        label: 'ENTRAR',
        filled: true,
        onTap:
            onLoginTap ??
            () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Routes.login);
            },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final resolvedNavigationItems =
        navigationItems ?? _defaultNavigationItems(context);
    final resolvedActionButtons =
        actionButtons ?? _defaultActionButtons(context);

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(19),
        bottomLeft: Radius.circular(19),
      ),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(left: BorderSide(color: _borderColor, width: 0.7)),
        ),
        child: SafeArea(
          left: false,
          child: SizedBox(
            width: menuWidth,
            height: double.infinity,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      if (headerContent != null) ...[
                        const SizedBox(height: 24),
                        headerContent!,
                      ],
                      const SizedBox(height: 32),
                      _buildNavigation(resolvedNavigationItems),
                      if (resolvedActionButtons.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _buildActionButtons(resolvedActionButtons),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Botão de fechar (X)
        _CloseButton(onTap: onClose ?? () => Navigator.of(context).pop()),
        // Logo Aula Extra
        SvgPicture.asset(
          HeaderAssets.logo,
          width: 96, 
          height: 69,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildNavigation(List<MenuDrawerItem> items) {
    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _NavigationLink(
            icon: items[index].icon,
            label: items[index].label,
            onTap: items[index].onTap,
          ),
          if (index != items.length - 1) const SizedBox(height: 4),
        ],
      ],
    );
  }

  Widget _buildActionButtons(List<MenuDrawerAction> actions) {
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _borderColor, width: 0.7)),
      ),
      child: Column(
        children: [
          for (var index = 0; index < actions.length; index++) ...[
            SizedBox(
              width: double.infinity,
              height: index == 0 ? 49 : 48,
              child: actions[index].filled
                  ? ElevatedButton(
                      onPressed: actions[index].onTap,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                            actions[index].backgroundColor ??
                            const Color(0xFFFABD2D),
                        foregroundColor:
                            actions[index].foregroundColor ?? Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        actions[index].label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                        ),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: actions[index].onTap,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: actions[index].borderColor ?? _borderColor,
                          width: 0.7,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        actions[index].label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: actions[index].foregroundColor ?? _textColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
            ),
            if (index != actions.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class MenuDrawerItem {
  const MenuDrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class MenuDrawerAction {
  const MenuDrawerAction({
    required this.label,
    required this.onTap,
    required this.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
}

/// Botão de fechar (X) estilizado
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 32,
        height: 32,
        child: const Icon(Icons.close, size: 24, color: Color(0xFF364153)),
      ),
    );
  }
}

/// Link de navegação do menu
class _NavigationLink extends StatelessWidget {
  const _NavigationLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF364153)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Color(0xFF364153),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mostra o menu sem login como um drawer lateral direito
void showMenuSemLogin(
  BuildContext context, {
  VoidCallback? onRegisterTap,
  VoidCallback? onLoginTap,
  List<MenuDrawerItem>? navigationItems,
  List<MenuDrawerAction>? actionButtons,
  Widget? headerContent,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Menu',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox.expand(),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(
                    width: MenuSemLogin.menuWidth,
                  ),
                  child: MenuSemLogin(
                    onRegisterTap: onRegisterTap,
                    onLoginTap: onLoginTap,
                    navigationItems: navigationItems,
                    actionButtons: actionButtons,
                    headerContent: headerContent,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      );
    },
  );
}
