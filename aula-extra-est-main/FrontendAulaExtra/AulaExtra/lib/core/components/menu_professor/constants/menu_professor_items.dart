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
  /// IMPORTANTE: As labels aqui definidas são usadas como chaves para a 
  /// tradução dinâmica baseada na Role (Explicador/Tutor/Psicólogo) 
  /// definida no TeachingRoleConfig.
  static const List<MenuProfessorItemData> all = [
    MenuProfessorItemData(
      label: 'Meus Alunos', // Substituído por "Meus Membros" se Psicólogo/Tutor
      icon: Icons.groups_rounded,
    ),
    MenuProfessorItemData(
      label: 'Minhas Disciplinas', // Substituído por "Especialidades" ou "Áreas"
      icon: Icons.menu_book_rounded,
    ),
    MenuProfessorItemData(
      label: 'Calendário', // Substituído por "Agenda Clínica" se Psicólogo
      icon: Icons.calendar_month_rounded,
    ),
    MenuProfessorItemData(label: 'Arquivos', icon: Icons.folder_rounded),
    MenuProfessorItemData(label: 'Chats', icon: Icons.chat_bubble_rounded),
    MenuProfessorItemData(
      label: 'Publicar Anúncio', // Substituído por "Gerir Serviços" se Psicólogo
      icon: Icons.campaign_rounded,
    ),
    MenuProfessorItemData(
      label: 'Os meus anúncios', // Substituído por "O Meu Perfil Clínico" se Psicólogo
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