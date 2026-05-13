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
    MenuAlunoItemData(label: 'Minhas Áreas', icon: Icons.grid_view_rounded),          // Index 0
    MenuAlunoItemData(label: 'Meus Explicadores', icon: Icons.groups_rounded),        // Index 1
    MenuAlunoItemData(label: 'Meus Tutores', icon: Icons.school_rounded),             // Index 2
    MenuAlunoItemData(label: 'Meus Psicólogos', icon: Icons.psychology_rounded),      // Index 3 
    MenuAlunoItemData(label: 'Calendário', icon: Icons.calendar_month_rounded),       // Index 4
    MenuAlunoItemData(label: 'Arquivos', icon: Icons.folder_rounded),                 // Index 5
    MenuAlunoItemData(label: 'Chats', icon: Icons.chat_bubble_rounded),               // Index 6
    MenuAlunoItemData(label: 'Pagamentos', icon: Icons.payments_rounded),             // Index 7
    MenuAlunoItemData(label: 'Avaliações', icon: Icons.star_rounded),                 // Index 8
    MenuAlunoItemData(label: 'Perfil', icon: Icons.person_rounded),                   // Index 9
    MenuAlunoItemData(
      label: 'Notificações',
      icon: Icons.notifications_rounded,
      hasBadge: true,
    ),
  ];
}