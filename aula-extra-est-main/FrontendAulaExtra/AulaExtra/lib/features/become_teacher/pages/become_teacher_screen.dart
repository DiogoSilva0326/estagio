import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/become_teacher/constants/become_teacher_constants.dart';
import 'package:aula_extra/features/become_teacher/widgets/become_teacher_card.dart';
import 'package:aula_extra/features/register/widgets/hero_panel_offset.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BecomeTeacherScreen extends StatefulWidget {
  const BecomeTeacherScreen({super.key});

  @override
  State<BecomeTeacherScreen> createState() => _BecomeTeacherScreenState();
}

class _BecomeTeacherScreenState extends State<BecomeTeacherScreen> {
  bool _redirected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_redirected) return;

    final user = context.read<UserProvider>();
    if (!user.isLoggedIn) {
      _redirected = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, Routes.registerStudent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_redirected) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      backgroundColor: BecomeTeacherColors.pageBackground,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedHeaderDelegate(
              height: AppHeader.height,
              child: AppHeader(
                onRegisterTap: () => Navigator.pushReplacementNamed(context, Routes.registerStudent),
                onLoginTap: () => Navigator.pushReplacementNamed(context, Routes.login),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: BecomeTeacherLayout.topSpacerHeight),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: BecomeTeacherLayout.maxContentWidth),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: BecomeTeacherLayout.contentWidth,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: BecomeTeacherLayout.leftSpacerWidth),
                            BecomeTeacherCard(
                              onLoginTap: () => Navigator.pushReplacementNamed(context, Routes.login),
                            ),
                            const SizedBox(width: BecomeTeacherLayout.cardHeroGap),
                            const RegisterHeroPanelOffset(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: BecomeTeacherLayout.beforeFooterGap),
                const FooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
