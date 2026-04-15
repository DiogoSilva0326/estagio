import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/aluno/avaliacoes/sections/avaliacoes_content_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvaliacoesScreen extends StatelessWidget {
  const AvaliacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserProvider>().role;
    final isStudent = role == Role.student;

    if (!isStudent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedHeaderDelegate(
              height: AppHeader.resolvedHeight(context),
              child: AppHeader(
                headerAlunoActiveItem: null,
                onRegisterTap: () =>
                    Navigator.of(context).pushNamed(Routes.registerStudent),
                onLoginTap: () => Navigator.of(context).pushNamed(Routes.login),
                onLogoTap: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(Routes.home, (route) => false),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: const [
                ColoredBox(
                  color: Color(0xFFF9F9F9),
                  child: SizedBox(
                    width: double.infinity,
                    child: FullBleedScaledSection(
                      child: AvaliacoesContentSection(),
                    ),
                  ),
                ),
                ColoredBox(color: Color(0xFFF9F9F9), child: FooterSection()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
