import 'package:aula_extra/core/components/header/assets/header_assets.dart';
import 'package:aula_extra/core/components/menu_sem_login/menu_sem_login.dart';
import 'package:aula_extra/core/components/header/widgets/student_mobile_menu_drawer.dart';
import 'package:aula_extra/core/components/header/widgets/teacher_mobile_menu_drawer.dart';
import 'package:aula_extra/core/data/auth_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MobileAppHeader extends StatelessWidget {
  const MobileAppHeader({
    super.key,
    required this.role,
    this.onRegisterTap,
    this.onLoginTap,
    this.onLogoTap,
    this.onProfileTap,
  });

  static const double height = 64;
  static const Color _shadowColor = Color.fromRGBO(0, 0, 0, 0.1);

  final Role role;
  final VoidCallback? onRegisterTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onLogoTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: _shadowColor,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onLogoTap ?? () => _handleLogoTap(context),
                borderRadius: BorderRadius.circular(12),
                child: SvgPicture.asset(
                  HeaderAssets.logo,
                  width: 96, 
                  height: 69,
                  fit: BoxFit.contain,
                ),
              ),
              InkWell(
                onTap: () => _handleMenuTap(context),
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  width: 50,
                  height: 40,
                  child: Icon(
                    Icons.menu_rounded,
                    size: 30,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogoTap(BuildContext context) {
    final currentRouteName = ModalRoute.of(context)?.settings.name;
    if (currentRouteName == Routes.home) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
  }

  void _handleMenuTap(BuildContext context) {
    if (role == Role.none) {
      showMenuSemLogin(
        context,
        onRegisterTap: onRegisterTap,
        onLoginTap: onLoginTap,
      );
      return;
    }

    if (role == Role.student) {
      _showStudentMenu(context);
      return;
    }

    _showTeacherMenu(context);
  }

  void _showStudentMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu do estudante',
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
                    constraints: const BoxConstraints.tightFor(width: 308),
                    child: StudentMobileMenuDrawer(
                      onClose: () => Navigator.of(context).pop(),
                      onLogoutTap: () => _handleLogoutTap(context),
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

  void _showTeacherMenu(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu do explicador',
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
                    constraints: const BoxConstraints.tightFor(width: 308),
                    child: TeacherMobileMenuDrawer(
                      onClose: () => Navigator.of(context).pop(),
                      onLogoutTap: () => _handleLogoutTap(context),
                      currentRouteName: currentRoute, 
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

  Future<void> _handleLogoutTap(BuildContext context) async {
    Navigator.of(context).pop();
    await AuthService().logout();
    if (!context.mounted) {
      return;
    }

    final userProvider = context.read<UserProvider>();
    userProvider.setAccount(null);
    userProvider.setRole(Role.none);
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
  }
}
