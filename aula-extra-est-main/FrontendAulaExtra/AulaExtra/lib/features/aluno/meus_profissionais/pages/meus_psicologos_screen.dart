import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/components/header/variants/header_aluno.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/aluno/meus_profissionais/sections/meus_profissionais_content_section.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeusPsicologosScreen extends StatelessWidget {
  const MeusPsicologosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserProvider>().role;
    final isStudent = role == Role.student;
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    if (!isStudent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
      });
    }

    final contentSection = const MeusProfissionaisContentSection(
      title: 'Meus Psicólogos',
      subtitle: 'Veja os seus psicólogos e faça a gestão das suas sessões.',
      emptyStateTitle: 'Ainda não tem psicólogos',
      emptyStateMessage: 'Explore psicólogos e comece o seu acompanhamento.',
      findMoreLabel: 'Encontrar psicólogos',
      targetRole: 'Psicólogo',
      findMoreRoute: Routes.psicologos, 
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: Column(
          children: [
            AppHeader(
              onRegisterTap: () =>
                  Navigator.of(context).pushNamed(Routes.registerStudent),
              onLoginTap: () => Navigator.of(context).pushNamed(Routes.login),
              onLogoTap: () => Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(Routes.home, (route) => false),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ColoredBox(
                      color: const Color(0xFFF9F9F9),
                      child: SizedBox(
                        width: double.infinity,
                        child: contentSection,
                      ),
                    ),
                    const ColoredBox(
                      color: Color(0xFFF9F9F9),
                      child: FooterSection(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
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
              children: [
                ColoredBox(
                  color: const Color(0xFFF9F9F9),
                  child: SizedBox(
                    width: double.infinity,
                    child: FullBleedScaledSection(
                      child: contentSection,
                    ),
                  ),
                ),
                const ColoredBox(color: Color(0xFFF9F9F9), child: FooterSection()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}