import 'package:aula_extra/core/components/header/sections/header_sem_login.dart';
import 'package:aula_extra/core/components/header/variants/header_aluno.dart';
import 'package:aula_extra/core/components/header/variants/header_explicador.dart';
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

  final HeaderAlunoItem? headerAlunoActiveItem;

  final VoidCallback? onRegisterTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onLogoTap;
  final VoidCallback? onProfileTap;

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

    String? nonEmpty(String? value) {
      final v = value?.trim();
      return (v == null || v.isEmpty) ? null : v;
    }

    final displayName = nonEmpty(user.account?.fullName) ??
        nonEmpty(user.account?.username) ??
        nonEmpty(user.account?.email);

    final effectiveAlunoItem = userRole == Role.student
        ? (_studentActiveItemFromRoute(currentRouteName) ?? headerAlunoActiveItem)
        : headerAlunoActiveItem;

    final effectiveTeacherItem = userRole == Role.teacher
        ? _teacherActiveItemFromRoute(currentRouteName)
        : null;

    return userRole == Role.teacher
        ? HeaderExplicador(
            activeItem: effectiveTeacherItem,
            displayName: displayName,
            onLogoTap: onLogoTap,
            onProfileTap: onProfileTap,
            onMeusAlunosTap: () => Navigator.of(context).pushNamed(Routes.professorMeusAlunos),
            onRecursosTap: () => Navigator.of(context).pushNamed(Routes.professorArquivos),
          )
        : userRole == Role.student
            ? HeaderAluno(
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
