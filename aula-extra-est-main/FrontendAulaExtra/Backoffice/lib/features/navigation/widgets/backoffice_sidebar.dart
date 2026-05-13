import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/auth/backoffice_session_controller.dart';
import '../../../design/theme/app_colors.dart';
import '../constants/backoffice_navigation_sections.dart';
import '../models/backoffice_user_profile.dart';
import 'backoffice_sidebar_section.dart';

class BackofficeSidebar extends StatefulWidget {
  const BackofficeSidebar({
    required this.currentRoute,
    required this.onNavigate,
    super.key,
  });

  final String currentRoute;
  final ValueChanged<String> onNavigate;

  @override
  State<BackofficeSidebar> createState() => _BackofficeSidebarState();
}

class _BackofficeSidebarState extends State<BackofficeSidebar> {
  static double _lastOffset = 0;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: _lastOffset)
      ..addListener(_storeOffset);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_storeOffset)
      ..dispose();
    super.dispose();
  }

  void _storeOffset() {
    _lastOffset = _scrollController.offset;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _SidebarHeader(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 24, 15, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final section
                        in BackofficeNavigationSections.sections) ...[
                      BackofficeSidebarSection(
                        section: section,
                        currentRoute: widget.currentRoute,
                        onItemTap: widget.onNavigate,
                      ),
                      const SizedBox(height: 26),
                    ],
                  ],
                ),
              ),
            ),
            const _SidebarFooter(),
          ],
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 122,
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSoft)),
      ),
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 22),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 190,
            child: Text(
              'apoioextra',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 38.62,
                fontFamily: 'Gulax',
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'BACK OFFICE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context) {
    final session = BackofficeSessionController.instance;
    final profile = session.userProfile ?? const BackofficeUserProfile(
      name: 'Admin AulaExtra',
      email: 'admin@aulaextra.pt',
      initials: 'AA',
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderSoft)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 17),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFC9039), Color(0xFFFFBDC0)],
              ),
            ),
            child: Text(
              profile.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await session.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              }
            },
            icon: const Icon(
              Icons.logout,
              size: 20,
              color: AppColors.textMuted,
            ),
            splashRadius: 18,
            tooltip: 'Terminar sessão',
          ),
        ],
      ),
    );
  }
}
