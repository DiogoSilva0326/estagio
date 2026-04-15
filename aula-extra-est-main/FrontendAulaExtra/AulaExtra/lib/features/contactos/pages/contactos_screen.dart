import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/contactos/sections/contactos_content_section.dart';
import 'package:aula_extra/features/home/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class ContactosScreen extends StatelessWidget {
  const ContactosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          const SliverToBoxAdapter(
            child: Column(
              children: [
                ColoredBox(
                  color: Colors.white,
                  child: SizedBox(
                    width: double.infinity,
                    child: FullBleedScaledSection(
                      child: ContactosContentSection(),
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
