import 'package:flutter/material.dart';

/// Modelo de dados para um item do **Menu do Professor**.
///
/// Onde é usado:
/// - Em `lib/core/components/menu_professor/` para construir a navegação do
///   professor (label, ícone e badge opcional).
class MenuProfessorItemData {
  const MenuProfessorItemData({
    required this.label,
    required this.icon,
    this.hasBadge = false,
  });

  final String label;
  final IconData icon;
  final bool hasBadge;
}

class MenuProfessorItems {
  const MenuProfessorItems._();

  /// Lista canónica de itens do menu do professor.
  ///
  /// Onde é usado:
  /// - No widget do menu para renderizar a navegação e associar rotas/ações.
  static const List<MenuProfessorItemData> all = [
    MenuProfessorItemData(label: 'Meus Alunos', icon: Icons.groups_rounded),
    MenuProfessorItemData(
      label: 'Minhas Disciplinas',
      icon: Icons.menu_book_rounded,
    ),
    MenuProfessorItemData(
      label: 'Calendário',
      icon: Icons.calendar_month_rounded,
    ),
    MenuProfessorItemData(label: 'Arquivos', icon: Icons.folder_rounded),
    MenuProfessorItemData(label: 'Chats', icon: Icons.chat_bubble_rounded),
    MenuProfessorItemData(
      label: 'Publicar Anúncio',
      icon: Icons.campaign_rounded,
    ),
    MenuProfessorItemData(
      label: 'Os meus anúncios',
      icon: Icons.view_agenda_rounded,
    ),
    MenuProfessorItemData(
      label: 'Disponibilidade',
      icon: Icons.schedule_rounded,
    ),
    MenuProfessorItemData(label: 'Pagamentos', icon: Icons.payments_rounded),
    MenuProfessorItemData(label: 'Avaliações', icon: Icons.star_rounded),
    MenuProfessorItemData(label: 'Perfil', icon: Icons.person_rounded),
    MenuProfessorItemData(
      label: 'Notificações',
      icon: Icons.notifications_rounded,
      hasBadge: true,
    ),
  ];
}
