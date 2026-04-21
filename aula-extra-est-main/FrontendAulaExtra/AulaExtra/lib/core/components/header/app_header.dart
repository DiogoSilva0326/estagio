import 'package:aula_extra/core/components/header/sections/header_sem_login.dart';
import 'package:aula_extra/core/components/header/variants/header_aluno.dart';
import 'package:aula_extra/core/components/header/variants/header_explicador.dart';
import 'package:aula_extra/core/components/header/widgets/mobile_app_header.dart';
import 'package:aula_extra/core/data/payments/payments_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.headerAlunoActiveItem,
    this.onRegisterTap,
    this.onLoginTap,
    this.onLogoTap,
    this.onProfileTap,
  });

  static const double height = 90;
  static const double mobileHeight = MobileAppHeader.height;
  static const double mobileBreakpoint = 1400;

  final HeaderAlunoItem? headerAlunoActiveItem;

  final VoidCallback? onRegisterTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onLogoTap;
  final VoidCallback? onProfileTap;

  static double resolvedHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).width <= mobileBreakpoint
        ? mobileHeight
        : height;
  }

  HeaderAlunoItem? _studentActiveItemFromRoute(String? routeName) {
    switch (routeName) {
      case Routes.home:
        return HeaderAlunoItem.inicio;
      case Routes.calendario:
      case Routes.calendarioSemanal:
        return HeaderAlunoItem.minhasAulas;
      case Routes.explicadores:
      case Routes.meusExplicadores:
        return HeaderAlunoItem.maisExplicadores;
      case Routes.areasAluno:
      case Routes.arquivos:
      case Routes.chats:
      case Routes.pagamentos:
      case Routes.avaliacoes:
      case Routes.perfilAluno:
      case Routes.notificacoes:
        return HeaderAlunoItem.recursos;
    }
    return null;
  }

  HeaderExplicadorItem? _teacherActiveItemFromRoute(String? routeName) {
    switch (routeName) {
      case Routes.home:
        return HeaderExplicadorItem.inicio;
      case Routes.professorCalendario:
        return HeaderExplicadorItem.minhasAulas;
      case Routes.professorMeusAlunos:
        return HeaderExplicadorItem.meusAlunos;
      case Routes.professorArquivos:
      case Routes.professorChats:
      case Routes.professorDisponibilidade:
      case Routes.professorPagamentos:
      case Routes.professorAvaliacoes:
      case Routes.professorPerfil:
      case Routes.professorNotificacoes:
        return HeaderExplicadorItem.recursos;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final userRole = user.role;
    final currentRouteName = ModalRoute.of(context)?.settings.name;
    final isMobile = MediaQuery.sizeOf(context).width <= mobileBreakpoint;

    String? nonEmpty(String? value) {
      final v = value?.trim();
      return (v == null || v.isEmpty) ? null : v;
    }

    final displayName =
        nonEmpty(user.account?.fullName) ?? nonEmpty(user.account?.username);
    final profileImageUrl = nonEmpty(user.account?.profileImageUrl);

    final effectiveAlunoItem = userRole == Role.student
        ? (_studentActiveItemFromRoute(currentRouteName) ??
              headerAlunoActiveItem)
        : headerAlunoActiveItem;

    final effectiveTeacherItem = userRole == Role.teacher
        ? _teacherActiveItemFromRoute(currentRouteName)
        : null;

    if (isMobile) {
      return MobileAppHeader(
        role: userRole,
        onRegisterTap: onRegisterTap,
        onLoginTap: onLoginTap,
        onLogoTap: onLogoTap,
        onProfileTap: onProfileTap,
      );
    }

    return userRole == Role.teacher
        ? HeaderExplicador(
            activeItem: effectiveTeacherItem,
            displayName: displayName,
            profileImageUrl: profileImageUrl,
            onLogoTap: onLogoTap,
            onProfileTap: onProfileTap,
            onMeusAlunosTap: () =>
                Navigator.of(context).pushNamed(Routes.professorMeusAlunos),
            onRecursosTap: () =>
                Navigator.of(context).pushNamed(Routes.professorMeusAlunos),
          )
        : userRole == Role.student
        ? _StudentHeaderWithCredits(
            activeItem: effectiveAlunoItem,
            displayName: displayName,
            onLogoTap: onLogoTap,
            onProfileTap: onProfileTap,
          )
        : HeaderSemLogin(
            onRegisterTap: onRegisterTap,
            onLoginTap: onLoginTap,
            onLogoTap: onLogoTap,
          );
  }
}

class _StudentHeaderWithCredits extends StatefulWidget {
  const _StudentHeaderWithCredits({
    required this.activeItem,
    required this.displayName,
    this.onLogoTap,
    this.onProfileTap,
  });

  final HeaderAlunoItem? activeItem;
  final String? displayName;
  final VoidCallback? onLogoTap;
  final VoidCallback? onProfileTap;

  @override
  State<_StudentHeaderWithCredits> createState() =>
      _StudentHeaderWithCreditsState();
}

class _StudentHeaderWithCreditsState extends State<_StudentHeaderWithCredits> {
  final PaymentsService _paymentsService = PaymentsService();
  bool _isLoadingCredits = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeLoadCredits();
  }

  @override
  void didUpdateWidget(covariant _StudentHeaderWithCredits oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeLoadCredits();
  }

  void _maybeLoadCredits() {
    if (_isLoadingCredits) return;

    final provider = context.read<UserProvider>();
    final account = provider.account;

    if (account == null || account.creditsBalance != null) return;

    _loadCredits();
  }

  Future<void> _loadCredits() async {
    _isLoadingCredits = true;
    try {
      final summary = await _paymentsService.fetchMySummary();
      if (!mounted) return;
      final provider = context.read<UserProvider>();
      provider.setAccount(
        (provider.account ?? const UserAccount()).copyWith(
          creditsBalance: summary.availableCredits,
          creditsCurrency: summary.currency,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      final provider = context.read<UserProvider>();
      provider.setAccount(
        (provider.account ?? const UserAccount()).copyWith(
          creditsBalance: 0,
          creditsCurrency: 'EUR',
        ),
      );
    } finally {
      _isLoadingCredits = false;
    }
  }

  String? _formatCredits(double? balance, String? currency) {
    if (balance == null) return null;
    final symbol = (currency ?? 'EUR').toUpperCase() == 'EUR'
        ? '€'
        : (currency ?? '').trim();
    final fixed = balance
        .toStringAsFixed(balance.truncateToDouble() == balance ? 0 : 2)
        .replaceAll('.', ',');
    return symbol.isEmpty ? fixed : '$fixed$symbol';
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<UserProvider>().account;
    return HeaderAluno(
      activeItem: widget.activeItem,
      displayName: widget.displayName,
      creditsText: _formatCredits(
        account?.creditsBalance,
        account?.creditsCurrency,
      ),
      onLogoTap: widget.onLogoTap,
      onProfileTap: widget.onProfileTap,
    );
  }
}
