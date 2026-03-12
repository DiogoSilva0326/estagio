import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/disciplinas/sections/disciplinas_content_section.dart';
import 'package:aula_extra/features/disciplinas/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class DisciplinasScreen extends StatelessWidget {
  const DisciplinasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedHeaderDelegate(
              height: AppHeader.height,
              child: AppHeader(
                onRegisterTap: () => Navigator.of(context).pushNamed(Routes.registerStudent),
                onLoginTap: () => Navigator.of(context).pushNamed(Routes.login),
                onLogoTap: () => Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: const [
                ColoredBox(
                  color: Color(0xFFF9FAFB),
                  child: SizedBox(
                    width: double.infinity,
                    child: FullBleedScaledSection(child: DisciplinasContentSection()),
                  ),
                ),
                ColoredBox(
                  color: Color(0xFFF9FAFB),
                  child: FooterSection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
