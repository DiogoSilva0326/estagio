import 'package:flutter/material.dart';

import '../core/constants/app_dimensions.dart';
import '../design/widgets/backoffice_scaffold.dart';
import '../features/avaliacoes/pages/avaliacoes_page.dart';
import '../features/areas_disciplinas/pages/areas_disciplinas_page.dart';
import '../features/alunos/pages/alunos_page.dart';
import '../features/dashboard/pages/dashboard_page.dart';
import '../features/explicadores/pages/explicadores_page.dart';
import '../features/formularios/pages/formularios_page.dart';
import '../features/newsletter/pages/newsletter_page.dart';
import '../features/pagamentos/pages/pagamentos_page.dart';
import '../features/planos_precos/pages/planos_precos_page.dart';
import '../features/sessoes_aulas/pages/sessoes_aulas_page.dart';
import '../features/sessions/pages/sessions_page.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static const String initialRoute = AppRoutes.dashboard;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.dashboard:
        return _page(const DashboardPage(), settings);
      case AppRoutes.explicadores:
        return _page(const ExplicadoresPage(), settings);
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
        return _page(
          const _PlaceholderPage(
            route: AppRoutes.reclamacoes,
            title: 'Reclamações',
          ),
          settings,
        );
      case AppRoutes.mensagens:
        return _page(
          const _PlaceholderPage(
            route: AppRoutes.mensagens,
            title: 'Mensagens',
          ),
          settings,
        );
      case AppRoutes.newsletter:
        return _page(const NewsletterPage(), settings);
      case AppRoutes.faqs:
        return _page(
          const _PlaceholderPage(route: AppRoutes.faqs, title: 'FAQs'),
          settings,
        );
      case AppRoutes.paginasInstitucionais:
        return _page(
          const _PlaceholderPage(
            route: AppRoutes.paginasInstitucionais,
            title: 'Páginas Institucionais',
          ),
          settings,
        );
      case AppRoutes.configuracoes:
        return _page(
          const _PlaceholderPage(
            route: AppRoutes.configuracoes,
            title: 'Configurações',
          ),
          settings,
        );
      default:
        return _page(const DashboardPage(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => child,
      settings: settings,
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.route, required this.title});

  final String route;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BackofficeScaffold(
      currentRoute: route,
      title: title,
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pageHorizontalPadding,
            AppDimensions.pageVerticalPadding,
            AppDimensions.pageHorizontalPadding,
            AppDimensions.pageVerticalPadding,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.contentMaxWidth,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Text(
                'A página `$title` já está ligada ao menu lateral e pronta para receber `pages`, `sections`, `widgets`, `constants` e `models` próprios.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
