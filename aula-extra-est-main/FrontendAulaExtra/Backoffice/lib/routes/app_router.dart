import 'package:flutter/material.dart';

import '../core/auth/backoffice_session_controller.dart';
import '../features/auth/pages/login_page.dart';
import '../features/avaliacoes/pages/avaliacoes_page.dart';
import '../features/areas_disciplinas/pages/areas_disciplinas_page.dart';
import '../features/alunos/pages/alunos_page.dart';
import '../features/dashboard/pages/dashboard_page.dart';
import '../features/configuracoes/pages/configuracoes_page.dart';
import '../features/explicadores/pages/explicadores_page.dart';
import '../features/faqs/pages/faqs_page.dart';
import '../features/formularios/pages/formularios_page.dart';
import '../features/mensagens/pages/mensagens_page.dart';
import '../features/newsletter/pages/newsletter_page.dart';
import '../features/pagamentos/pages/pagamentos_page.dart';
import '../features/paginas_institucionais/pages/paginas_institucionais_page.dart';
import '../features/planos_precos/pages/planos_precos_page.dart';
import '../features/psicologos/pages/psicologos_page.dart';
import '../features/reclamacoes/pages/reclamacoes_page.dart';
import '../features/sessoes_aulas/pages/sessoes_aulas_page.dart';
import '../features/sessions/pages/sessions_page.dart';
import '../features/tutores/pages/tutores_page.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static const String initialRoute = AppRoutes.dashboard;

  static Widget homeForState(BackofficeSessionController session) {
    if (session.isAuthenticated) {
      return const DashboardPage();
    }

    return const LoginPage();
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final session = BackofficeSessionController.instance;
    final routeName = settings.name ?? AppRoutes.dashboard;

    if (!session.isAuthenticated && routeName != AppRoutes.login) {
      return _page(const LoginPage(), settings);
    }

    if (session.isAuthenticated && routeName == AppRoutes.login) {
      return _page(const DashboardPage(), settings);
    }

    switch (settings.name) {
      case AppRoutes.login:
        return _page(const LoginPage(), settings);
      case AppRoutes.dashboard:
        return _page(const DashboardPage(), settings);
      case AppRoutes.explicadores:
        return _page(const ExplicadoresPage(), settings);
      case AppRoutes.tutores:
        return _page(const TutoresPage(), settings);
      case AppRoutes.psicologos:
        return _page(const PsicologosPage(), settings);
      case AppRoutes.alunos:
        return _page(const AlunosPage(), settings);
      case AppRoutes.areasDisciplinas:
        return _page(const AreasDisciplinasPage(), settings);
      case AppRoutes.sessoesAulas:
        return _page(const SessoesAulasPage(), settings);
      case AppRoutes.sessoesRecentes:
        return _page(const SessionsPage(), settings);
      case AppRoutes.avaliacoes:
        return _page(const AvaliacoesPage(), settings);
      case AppRoutes.pagamentos:
        return _page(const PagamentosPage(), settings);
      case AppRoutes.planosPrecos:
        return _page(const PlanosPrecosPage(), settings);
      case AppRoutes.formularios:
        return _page(const FormulariosPage(), settings);
      case AppRoutes.reclamacoes:
        return _page(const ReclamacoesPage(), settings);
      case AppRoutes.mensagens:
        return _page(const MensagensPage(), settings);
      case AppRoutes.newsletter:
        return _page(const NewsletterPage(), settings);
      case AppRoutes.faqs:
        return _page(const FaqsPage(), settings);
      case AppRoutes.paginasInstitucionais:
        return _page(const PaginasInstitucionaisPage(), settings);
      case AppRoutes.configuracoes:
        return _page(const ConfiguracoesPage(), settings);
      default:
        return _page(
          session.isAuthenticated ? const DashboardPage() : const LoginPage(),
          settings,
        );
    }
  }

  static PageRouteBuilder<dynamic> _page(
    Widget child,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}
