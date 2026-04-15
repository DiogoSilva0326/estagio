import 'package:flutter/material.dart';

import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/routes/routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('ProfileScreen')),
          ),
        ],
      ),
    );
  }
}
