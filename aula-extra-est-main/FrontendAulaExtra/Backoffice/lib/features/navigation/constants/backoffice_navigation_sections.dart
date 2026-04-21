import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../models/backoffice_nav_item.dart';
import '../models/backoffice_nav_section.dart';
import '../models/backoffice_user_profile.dart';

class BackofficeNavigationSections {
  const BackofficeNavigationSections._();

  static const BackofficeUserProfile currentUser = BackofficeUserProfile(
    name: 'Admin AulaExtra',
    email: 'admin@aulaextra.pt',
    initials: 'AA',
  );

  static const List<BackofficeNavSection> sections = [
    BackofficeNavSection(
      title: '',
      items: [
        BackofficeNavItem(
          label: 'Dashboard',
          route: AppRoutes.dashboard,
          icon: Icons.grid_view_rounded,
        ),
      ],
    ),
    BackofficeNavSection(
      title: 'Utilizadores',
      items: [
        BackofficeNavItem(
          label: 'Explicadores',
          route: AppRoutes.explicadores,
          icon: Icons.groups_2_outlined,
        ),
        BackofficeNavItem(
          label: 'Alunos',
          route: AppRoutes.alunos,
          icon: Icons.school_outlined,
        ),
      ],
    ),
    BackofficeNavSection(
      title: 'Catálogo Educativo',
      items: [
        BackofficeNavItem(
          label: 'Áreas e Disciplinas',
          route: AppRoutes.areasDisciplinas,
          icon: Icons.auto_stories_outlined,
        ),
      ],
    ),
    BackofficeNavSection(
      title: 'Operações',
      items: [
        BackofficeNavItem(
          label: 'Sessões / Aulas',
          route: AppRoutes.sessoesAulas,
          icon: Icons.ondemand_video_outlined,
        ),
        BackofficeNavItem(
          label: 'Avaliações',
          route: AppRoutes.avaliacoes,
          icon: Icons.chat_bubble_outline_rounded,
        ),
      ],
    ),
    BackofficeNavSection(
      title: 'Financeiro',
      items: [
        BackofficeNavItem(
          label: 'Pagamentos & Faturação',
          route: AppRoutes.pagamentos,
          icon: Icons.receipt_long_outlined,
        ),
        BackofficeNavItem(
          label: 'Planos / Preços',
          route: AppRoutes.planosPrecos,
          icon: Icons.credit_card_outlined,
        ),
      ],
    ),
    BackofficeNavSection(
      title: 'Comunicação',
      items: [
        BackofficeNavItem(
          label: 'Formulários',
          route: AppRoutes.formularios,
          icon: Icons.mail_outline_rounded,
        ),
        BackofficeNavItem(
          label: 'Reclamações',
          route: AppRoutes.reclamacoes,
          icon: Icons.mail_outline_rounded,
        ),
        BackofficeNavItem(
          label: 'Mensagens',
          route: AppRoutes.mensagens,
          icon: Icons.mail_outline_rounded,
        ),
        BackofficeNavItem(
          label: 'Newsletter',
          route: AppRoutes.newsletter,
          icon: Icons.mail_outline_rounded,
        ),
      ],
    ),
    BackofficeNavSection(
      title: 'Conteúdo (CMS)',
      items: [
        BackofficeNavItem(
          label: 'FAQs',
          route: AppRoutes.faqs,
          icon: Icons.help_outline_rounded,
        ),
        BackofficeNavItem(
          label: 'Páginas Institucionais',
          route: AppRoutes.paginasInstitucionais,
          icon: Icons.description_outlined,
        ),
      ],
    ),
    BackofficeNavSection(
      title: 'Sistema',
      items: [
        BackofficeNavItem(
          label: 'Configurações',
          route: AppRoutes.configuracoes,
          icon: Icons.settings_outlined,
        ),
      ],
    ),
  ];
}
