import 'package:flutter/material.dart';
// ADICIONAR ESTA LINHA PARA USAR O ENUM CORRETO:
import 'package:aula_extra/core/providers/user_provider.dart' show Role;

// ==========================================
// 1. CLASSES DE AGRUPAMENTO (SUB-CONFIGS)
// ==========================================

class MenuProfessorConfig {
  final String menuTitle;
  final String statsSessionsLabel;
  final String statsActiveLabel;

  const MenuProfessorConfig({
    required this.menuTitle,
    required this.statsSessionsLabel,
    required this.statsActiveLabel,
  });
}

class MarcarAulaConfig {
  final String createSessionTitle;
  final String chooseDateSubtitle;
  final String selectUserTitle;
  final String selectUserSubtitle;
  final String creationNote;
  final String joinSessionLabel;

  const MarcarAulaConfig({
    required this.createSessionTitle,
    required this.chooseDateSubtitle,
    required this.selectUserTitle,
    required this.selectUserSubtitle,
    required this.creationNote,
    required this.joinSessionLabel,
  });
}

class AlunoCardConfig {
  final String lastSessionLabel;
  const AlunoCardConfig({required this.lastSessionLabel});
}

class CalendarioConfig {
  final String nextSessionLabel;
  const CalendarioConfig({required this.nextSessionLabel});
}

class PublicarAnuncioConfig {
  final String emptyStateTitle;
  final String emptyStateSubtitle;
  final String emptyStateButton;
  final String pageSubtitleNew;
  final String pageSubtitleEdit;
  final String defaultProfileDescription;
  final String profileBadgeText;

  const PublicarAnuncioConfig({
    required this.emptyStateTitle,
    required this.emptyStateSubtitle,
    required this.emptyStateButton,
    required this.pageSubtitleNew,
    required this.pageSubtitleEdit,
    required this.defaultProfileDescription,
    required this.profileBadgeText,
  });
}

class DisponibilidadeConfig {
  final String pageDescription;
  const DisponibilidadeConfig({required this.pageDescription});
}

class PagamentosConfig {
  final String userHeader; 
  final String dateHeader; 
  final String subjectHeader; 
  final String historyIntro;

  const PagamentosConfig({
    required this.userHeader,
    required this.dateHeader,
    required this.subjectHeader,
    required this.historyIntro,
  });
}

class AvaliacoesConfig {
  final String sessionTabLabel; 
  final String sessionStatsLabel; 
  final String sessionEmptyLabel; 
  final String reviewerDefaultName; 

  const AvaliacoesConfig({
    required this.sessionTabLabel,
    required this.sessionStatsLabel,
    required this.sessionEmptyLabel,
    required this.reviewerDefaultName,
  });
}

class PerfilConfig {
  final String totalSessionsLabel;
  final String subjectsSectionTitle;
  final String addSubjectButtonLabel;

  const PerfilConfig({
    required this.totalSessionsLabel,
    required this.subjectsSectionTitle,
    required this.addSubjectButtonLabel,
  });
}

class MeusAlunosConfig {
  final String pageDescription;
  final String emptyStateTitle;
  final String emptyStateDescription;
  final String statsProgressHelper;
  final String statsSubjectsLabel;

  const MeusAlunosConfig({
    required this.pageDescription,
    required this.emptyStateTitle,
    required this.emptyStateDescription,
    required this.statsProgressHelper,
    required this.statsSubjectsLabel,
  });
}

// ==========================================
// 2. A CONFIGURAÇÃO PRINCIPAL
// ==========================================

class TeachingRoleConfig {
  // --- VOCABULÁRIO GLOBAL ---
  final String roleName;    
  final String studentsLabel;
  final String sessionsLabel;
  final String calendarLabel;
  final String publishAdLabel; 
  final String myAdsLabel;     

  // --- PALETA DE CORES EXPANDIDA ---
  final Color primaryColor;       
  final Color primaryLight;       
  final Color primaryDark;        
  final Color surfaceColor;       
  final Color borderColor;        
  final Color accentColor;        
  
  // --- CONFIGURAÇÕES DE ECRÃ ---
  final MenuProfessorConfig menu;
  final MarcarAulaConfig marcarAula;
  final AlunoCardConfig alunoCard;
  final CalendarioConfig calendario;
  final PublicarAnuncioConfig publicarAnuncio;
  final DisponibilidadeConfig disponibilidade;
  final PagamentosConfig pagamentos;
  final AvaliacoesConfig avaliacoes;
  final PerfilConfig perfil;
  final MeusAlunosConfig meusAlunos;

  TeachingRoleConfig({
    required this.roleName,
    required this.primaryColor,
    required this.primaryLight,
    required this.primaryDark,
    required this.surfaceColor,
    required this.borderColor,
    required this.accentColor,
    required this.studentsLabel,
    required this.sessionsLabel,
    required this.calendarLabel,
    required this.publishAdLabel,
    required this.myAdsLabel,
    required this.menu,
    required this.marcarAula,
    required this.alunoCard,
    required this.calendario,
    required this.publicarAnuncio,
    required this.disponibilidade,
    required this.pagamentos,
    required this.avaliacoes,
    required this.perfil,
    required this.meusAlunos,
  });

  factory TeachingRoleConfig.fromRole(Role role) {
    switch (role) {
      case Role.psychologist:
        return TeachingRoleConfig(
          roleName: 'Psicólogo',
          primaryColor:  const Color(0xFF00B27A), 
          primaryLight:  const Color(0xFFE2F7EF), 
          primaryDark:   const Color(0xFF005439), 
          surfaceColor:  const Color(0xFFF2FCF8), 
          borderColor:   const Color(0xFFBCECDA), 
          accentColor:   const Color(0xFF00D693),      
          studentsLabel: 'Meus Membros',
          sessionsLabel: 'sessões',
          calendarLabel: 'Agenda Clínica',
          publishAdLabel: 'Gerir Serviços',
          myAdsLabel: 'O Meu Perfil Clínico', 
          menu: const MenuProfessorConfig(
            menuTitle: 'Menu do Psicólogo',
            statsSessionsLabel: 'Sessões esta semana:',
            statsActiveLabel: 'Membros ativos:',
          ),
          alunoCard: const AlunoCardConfig(lastSessionLabel: 'Última sessão'),
          calendario: const CalendarioConfig(nextSessionLabel: 'Próximas sessões'),
          marcarAula: const MarcarAulaConfig(
            createSessionTitle: 'Criar Sessão',
            chooseDateSubtitle: 'Escolhe o dia e a hora da sessão.',
            selectUserTitle: 'Selecionar Membro',
            selectUserSubtitle: 'Seleciona o membro que vai participar na sessão.',
            creationNote: 'A marcação fica pendente até o membro confirmar o pagamento.',
            joinSessionLabel: 'Entrar na sessão',
          ),
          publicarAnuncio: const PublicarAnuncioConfig(
            emptyStateTitle: 'Primeiro adicione uma especialidade.',
            emptyStateSubtitle: 'Só pode configurar serviços para especialidades já adicionadas ao seu perfil.',
            emptyStateButton: 'Ir para Especialidades',
            pageSubtitleNew: 'Selecione uma das suas especialidades, confirme o tipo de sessão e configure o serviço.',
            pageSubtitleEdit: 'Atualize os detalhes do serviço selecionado.',
            defaultProfileDescription: 'Psicólogo disponível para novas sessões.',
            profileBadgeText: 'Psicólogo ApoioExtra',
          ),
          disponibilidade: const DisponibilidadeConfig(
            pageDescription: 'Define aqui o teu horário semanal. Este é o calendário que os teus membros vão ver no teu perfil.',
          ),
          pagamentos: const PagamentosConfig(
            userHeader: 'Membro',
            dateHeader: 'Data da Sessão',
            subjectHeader: 'Especialidade',
            historyIntro: 'Acompanhe ganhos, pagamentos pendentes e o histórico das suas sessões.',
          ),
          avaliacoes: const AvaliacoesConfig(
            sessionTabLabel: 'Sessões',
            sessionStatsLabel: 'Avaliações submetidas às sessões',
            sessionEmptyLabel: 'Ainda não existem avaliações submetidas às suas sessões.',
            reviewerDefaultName: 'Membro',
          ),
          perfil: const PerfilConfig(
            totalSessionsLabel: 'Total de sessões',
            subjectsSectionTitle: 'Especialidades',
            addSubjectButtonLabel: 'Adicionar Especialidade',
          ),
          meusAlunos: const MeusAlunosConfig(
            pageDescription: 'Acompanhe os seus membros associados, o progresso e aceda rapidamente aos perfis.',
            emptyStateTitle: 'Ainda não tem membros associados.',
            emptyStateDescription: 'Quando um membro reservar uma sessão consigo, ele aparecerá aqui automaticamente.',
            statsProgressHelper: 'membros',
            statsSubjectsLabel: 'Especialidades',
          ),
        );

      case Role.tutor:
        return TeachingRoleConfig(
          roleName: 'Tutor',
          primaryColor:  const Color(0xFF0284C7), 
          primaryLight:  const Color(0xFFE0F2FE), 
          primaryDark:   const Color(0xFF075985), 
          surfaceColor:  const Color(0xFFF0F9FF), 
          borderColor:   const Color(0xFFBAE6FD), 
          accentColor:   const Color(0xFF0EA5E9),    
          studentsLabel: 'Meus Membros',
          sessionsLabel: 'sessões',
          calendarLabel: 'Calendário',
          publishAdLabel: 'Publicar Anúncio',
          myAdsLabel: 'Os meus anúncios',
          menu: const MenuProfessorConfig(
            menuTitle: 'Menu do Tutor',
            statsSessionsLabel: 'Sessões esta semana:',
            statsActiveLabel: 'Membros ativos:',
          ),
          alunoCard: const AlunoCardConfig(lastSessionLabel: 'Última sessão'),
          calendario: const CalendarioConfig(nextSessionLabel: 'Próximas sessões'),
          marcarAula: const MarcarAulaConfig(
            createSessionTitle: 'Criar sessão',
            chooseDateSubtitle: 'Escolhe o dia e a hora da sessão.',
            selectUserTitle: 'Selecionar Membro',
            selectUserSubtitle: 'Seleciona o membro que vai participar.',
            creationNote: 'A marcação fica pendente até o membro confirmar o pagamento.',
            joinSessionLabel: 'Entrar na sessão',
          ),
          publicarAnuncio: const PublicarAnuncioConfig(
            emptyStateTitle: 'Primeiro adicione uma área de tutoria.',
            emptyStateSubtitle: 'Só pode publicar anúncios para áreas já configuradas no seu perfil.',
            emptyStateButton: 'Ir para Minhas Áreas',
            pageSubtitleNew: 'Selecione uma das suas áreas, confirme o tipo de sessão e publique o anúncio.',
            pageSubtitleEdit: 'Atualize os campos do anúncio selecionado.',
            defaultProfileDescription: 'Tutor disponível para novas sessões.',
            profileBadgeText: 'Tutor ApoioExtra',
          ),
          disponibilidade: const DisponibilidadeConfig(
            pageDescription: 'Define aqui o teu horário semanal. Este é o calendário que os teus membros vão ver no teu perfil.',
          ),
          pagamentos: const PagamentosConfig(
            userHeader: 'Membro',
            dateHeader: 'Data da Sessão',
            subjectHeader: 'Área',
            historyIntro: 'Acompanhe ganhos, pagamentos pendentes e o histórico das suas sessões.',
          ),
          avaliacoes: const AvaliacoesConfig(
            sessionTabLabel: 'Sessões',
            sessionStatsLabel: 'Avaliações submetidas às sessões',
            sessionEmptyLabel: 'Ainda não existem avaliações submetidas às suas sessões.',
            reviewerDefaultName: 'Membro',
          ),
          perfil: const PerfilConfig(
            totalSessionsLabel: 'Total de sessões',
            subjectsSectionTitle: 'Áreas de Tutoria',
            addSubjectButtonLabel: 'Adicionar Área',
          ),
          meusAlunos: const MeusAlunosConfig(
            pageDescription: 'Acompanhe os seus membros associados, o progresso e aceda rapidamente aos perfis.',
            emptyStateTitle: 'Ainda não tem membros associados.',
            emptyStateDescription: 'Quando um membro reservar uma sessão consigo, ele aparecerá aqui automaticamente.',
            statsProgressHelper: 'membros',
            statsSubjectsLabel: 'Áreas',
          ),
        );

      default: 
        return TeachingRoleConfig(
          roleName: 'Explicador',
          primaryColor:  const Color(0xFFEA580C), 
          primaryLight:  const Color(0xFFFFEDD5), 
          primaryDark:   const Color(0xFF9A3412), 
          surfaceColor:  const Color(0xFFFFF7ED), 
          borderColor:   const Color(0xFFFED7AA), 
          accentColor:   const Color(0xFFF97316),      
          studentsLabel: 'Meus Alunos',
          sessionsLabel: 'aulas',
          calendarLabel: 'Minhas Aulas',
          publishAdLabel: 'Publicar Anúncio',
          myAdsLabel: 'Os meus anúncios',
          menu: const MenuProfessorConfig(
            menuTitle: 'Menu do Explicador',
            statsSessionsLabel: 'Aulas esta semana:',
            statsActiveLabel: 'Alunos ativos:',
          ),
          alunoCard: const AlunoCardConfig(lastSessionLabel: 'Última aula'),
          calendario: const CalendarioConfig(nextSessionLabel: 'Próximas aulas'),
          marcarAula: const MarcarAulaConfig(
            createSessionTitle: 'Criar Aula',
            chooseDateSubtitle: 'Escolhe o dia e a hora da aula.',
            selectUserTitle: 'Selecionar Aluno',
            selectUserSubtitle: 'Seleciona o aluno que vai participar na aula.',
            creationNote: 'A marcação fica pendente até o aluno confirmar o pagamento.',
            joinSessionLabel: 'Entrar na aula',
          ),
          publicarAnuncio: const PublicarAnuncioConfig(
            emptyStateTitle: 'Primeiro adicione uma disciplina.',
            emptyStateSubtitle: 'Só pode publicar anúncios para disciplinas já configuradas em Minhas Disciplinas.',
            emptyStateButton: 'Ir para Minhas Disciplinas',
            pageSubtitleNew: 'Selecione uma das suas disciplinas, confirme o tipo de aula e publique o anúncio com o nível de ensino bloqueado automaticamente.',
            pageSubtitleEdit: 'Atualize os campos do anúncio selecionado. O nível de ensino continua bloqueado automaticamente pela disciplina.',
            defaultProfileDescription: 'Professor disponível para novas aulas.',
            profileBadgeText: 'Professor ApoioExtra',
          ),
          disponibilidade: const DisponibilidadeConfig(
            pageDescription: 'Define aqui o teu horário semanal. Este é o calendário que os teus alunos vão ver no teu perfil.',
          ),
          pagamentos: const PagamentosConfig(
            userHeader: 'Aluno',
            dateHeader: 'Data da Aula',
            subjectHeader: 'Disciplina',
            historyIntro: 'Acompanhe ganhos, pagamentos pendentes e o histórico das suas aulas.',
          ),
          avaliacoes: const AvaliacoesConfig(
            sessionTabLabel: 'Aulas',
            sessionStatsLabel: 'Avaliações submetidas às aulas',
            sessionEmptyLabel: 'Ainda não existem avaliações submetidas às suas aulas.',
            reviewerDefaultName: 'Aluno',
          ),
          perfil: const PerfilConfig(
            totalSessionsLabel: 'Total de aulas',
            subjectsSectionTitle: 'Minhas Disciplinas',
            addSubjectButtonLabel: 'Adicionar Disciplina',
          ),
          meusAlunos: const MeusAlunosConfig(
            pageDescription: 'Acompanhe os seus alunos associados, o progresso da turma e aceda rapidamente aos perfis.',
            emptyStateTitle: 'Ainda não tem alunos associados.',
            emptyStateDescription: 'Quando um aluno reservar uma aula consigo, ele aparecerá aqui automaticamente.',
            statsProgressHelper: 'turma',
            statsSubjectsLabel: 'Disciplinas',
          ),
        );
    }
  }
}