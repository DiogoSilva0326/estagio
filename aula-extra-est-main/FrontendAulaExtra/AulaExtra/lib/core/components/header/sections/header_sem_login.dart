import 'package:aula_extra/core/components/header/assets/header_assets.dart';
import 'package:aula_extra/core/components/header/widgets/header_link.dart';
import 'package:aula_extra/core/components/header/widgets/role_switcher_button.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class HeaderSemLogin extends StatelessWidget {
  const HeaderSemLogin({
    super.key,
    this.onRegisterTap,
    this.onLoginTap,
    this.onLogoTap,
  });

  final VoidCallback? onRegisterTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onLogoTap;

  static const double _designWidth = 1440;
  static const double _height = 90;
  static const double height = _height;

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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: _shadowColor,
              offset: Offset(0, 4),
              blurRadius: 4.6,
              spreadRadius: -1,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: _designWidth,
                      height: _height,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 46,
                            top: 10,
                            child: InkWell(
                              onTap: () => _handleLogoTap(context),
                              child: Image.asset(
                                HeaderAssets.logo,
                                width: 96,
                                height: 69,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 35,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HeaderLink(
                                  text: 'Como Funciona',
                                  color: ModalRoute.of(context)?.settings.name == Routes.home ? _activeColor : null,
                                  onTap: () => Navigator.of(context).pushNamed(Routes.home),
                                ),
                                const SizedBox(width: 40),
                                HeaderLink(
                                  text: 'Disciplinas',
                                  color: ModalRoute.of(context)?.settings.name == Routes.disciplinas ? _activeColor : null,
                                  onTap: () => Navigator.of(context).pushNamed(Routes.disciplinas),
                                ),
                                const SizedBox(width: 40),
                                HeaderLink(
                                  text: 'Explicadores',
                                  color: ModalRoute.of(context)?.settings.name == Routes.explicadores ? _activeColor : null,
                                  onTap: () => Navigator.of(context).pushNamed(Routes.explicadores),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 55,
                            top: 18,
                            child: SizedBox(
                              height: 54,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 11),
                                    child: RoleSwitcherButton(size: 32),
                                  ),
                                  const SizedBox(width: 14),
                                  InkWell(
                                    onTap: onRegisterTap,
                                    child: const Center(
                                      child: Text(
                                        'REGISTAR-ME',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  SizedBox(
                                    width: 110,
                                    height: 54,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFABD2D),
                                        foregroundColor: Colors.black,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                      onPressed: onLoginTap,
                                      child: const Text(
                                        'ENTRAR',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
