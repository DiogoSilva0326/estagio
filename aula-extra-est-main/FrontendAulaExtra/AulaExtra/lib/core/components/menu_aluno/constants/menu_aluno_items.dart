import 'package:flutter/material.dart';

/// Modelo de dados para um item do **Menu do Aluno**.
///
/// Onde é usado:
/// - Em `lib/core/components/menu_aluno/` para construir a lista de navegação
///   (label, ícone e se deve mostrar badge).
class MenuAlunoItemData {
  const MenuAlunoItemData({
    required this.label,
    required this.icon,
    this.hasBadge = false,
  });

  final String label;
  final IconData icon;
  final bool hasBadge;
}

class MenuAlunoItems {
  const MenuAlunoItems._();

  /// Lista canónica de itens do menu do aluno.
  ///
  /// Onde é usado:
  /// - No widget do menu para renderizar a navegação e associar rotas/ações.
  static const List<MenuAlunoItemData> all = [
    MenuAlunoItemData(label: 'Minhas Áreas', icon: Icons.grid_view_rounded),
    MenuAlunoItemData(label: 'Meus Explicadores', icon: Icons.groups_rounded),
    MenuAlunoItemData(label: 'Calendário', icon: Icons.calendar_month_rounded),
    MenuAlunoItemData(label: 'Arquivos', icon: Icons.folder_rounded),
    MenuAlunoItemData(label: 'Chats', icon: Icons.chat_bubble_rounded),
    MenuAlunoItemData(label: 'Pagamentos', icon: Icons.payments_rounded),
    MenuAlunoItemData(label: 'Avaliações', icon: Icons.star_rounded),
    MenuAlunoItemData(label: 'Perfil', icon: Icons.person_rounded),
    MenuAlunoItemData(
      label: 'Notificações',
      icon: Icons.notifications_rounded,
      hasBadge: true,
    ),
  ];
}
