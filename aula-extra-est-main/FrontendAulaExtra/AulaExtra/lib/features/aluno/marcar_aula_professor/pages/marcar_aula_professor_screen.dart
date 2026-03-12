import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/aluno/marcar_aula_professor/constants/marcar_aula_professor_constants.dart';
import 'package:aula_extra/features/aluno/marcar_aula_professor/models/marcar_aula_professor_args.dart';
import 'package:aula_extra/features/aluno/marcar_aula_professor/sections/marcar_aula_professor_content_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MarcarAulaProfessorScreen extends StatelessWidget {
  const MarcarAulaProfessorScreen({super.key});

  static const MarcarAulaProfessorArgs fallbackArgs = MarcarAulaProfessorArgs(
    tutorName: 'João Ribeiro',
    subject: 'Matemática',
    rating: 4.9,
    reviewCount: 127,
    location: 'Lisboa',
    pricePerHour: 25,
  );

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserProvider>().role;
    final isStudent = role == Role.student;

    if (!isStudent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
      });
    }

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final args = routeArgs is MarcarAulaProfessorArgs ? routeArgs : fallbackArgs;

    return Scaffold(
      backgroundColor: MarcarAulaProfessorConstants.pageBackground,
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
              children: [
                ColoredBox(
                  color: MarcarAulaProfessorConstants.pageBackground,
                  child: SizedBox(
                    width: double.infinity,
                    child: FullBleedScaledSection(
                      child: MarcarAulaProfessorContentSection(args: args),
                    ),
                  ),
                ),
                const ColoredBox(
                  color: MarcarAulaProfessorConstants.pageBackground,
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
