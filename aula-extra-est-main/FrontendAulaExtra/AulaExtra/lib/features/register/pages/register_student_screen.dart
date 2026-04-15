import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/features/register/pages/register_mobile_page.dart';
import 'package:aula_extra/features/register/widgets/hero_panel_offset.dart';
import 'package:aula_extra/features/register/widgets/register_card.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class RegisterStudentScreen extends StatelessWidget {
  const RegisterStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;
    if (isMobile) {
      return const RegisterMobilePage();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedHeaderDelegate(
              height: AppHeader.resolvedHeight(context),
              child: AppHeader(
                onRegisterTap: () => Navigator.pushReplacementNamed(
                  context,
                  Routes.registerStudent,
                ),
                onLoginTap: () =>
                    Navigator.pushReplacementNamed(context, Routes.login),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 54),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1404),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 1404,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 233),
                            RegisterCard(
                              onLoginTap: () => Navigator.pushReplacementNamed(
                                context,
                                Routes.login,
                              ),
                            ),
                            const SizedBox(width: 52),
                            const RegisterHeroPanelOffset(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const FooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
