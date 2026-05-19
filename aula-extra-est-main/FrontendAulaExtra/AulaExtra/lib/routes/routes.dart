import 'package:flutter/material.dart';
import 'package:aula_extra/features/disciplinas/pages/disciplinas_screen.dart';
import 'package:aula_extra/features/explicadores/pages/explicadores_screen.dart';
import 'package:aula_extra/features/aluno/areas_aluno/pages/areas_aluno_screen.dart';
import 'package:aula_extra/features/aluno/meus_profissionais/pages/meus_explicadores_screen.dart';
import 'package:aula_extra/features/aluno/calendario/pages/calendario_screen.dart';
import 'package:aula_extra/features/aluno/calendario/pages/calendario_semanal_screen.dart';
import 'package:aula_extra/features/aluno/chats/pages/chats_screen.dart';
import 'package:aula_extra/features/aluno/arquivos/pages/arquivos_screen.dart';
import 'package:aula_extra/features/aluno/pagamentos/pages/pagamentos_screen.dart';
import 'package:aula_extra/features/aluno/avaliacoes/pages/avaliacoes_screen.dart';
import 'package:aula_extra/features/aluno/perfil/pages/perfil_aluno_screen.dart';
import 'package:aula_extra/features/aluno/notificacoes/pages/notificacoes_screen.dart';
import 'package:aula_extra/features/aluno/marcar_aula_professor/pages/marcar_aula_professor_screen.dart';
import 'package:aula_extra/features/tutor_profile_view/pages/tutor_profile_screen.dart';
import 'package:aula_extra/features/faq/pages/faq_screen.dart';
import 'package:aula_extra/features/contactos/pages/contactos_screen.dart';
import 'package:aula_extra/features/become_teacher/pages/become_teacher_screen.dart';
import 'package:aula_extra/features/comprar_creditos/pages/comprar_creditos_screen.dart';
import 'package:aula_extra/features/home/pages/home_screen.dart';
import 'package:aula_extra/features/login/pages/login_screen.dart';
import 'package:aula_extra/features/newsletter/pages/newsletter_status_screen.dart';
import 'package:aula_extra/features/profile/pages/profile_screen.dart';
import 'package:aula_extra/features/register/pages/register_student_screen.dart';
import 'package:aula_extra/features/professor/meus_alunos/pages/meus_alunos_professor_screen.dart';
import 'package:aula_extra/features/professor/meus_alunos/pages/aluno_profile_view_screen.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/pages/minhas_disciplinas_professor_screen.dart';
import 'package:aula_extra/features/professor/calendario/pages/calendario_professor_screen.dart';
import 'package:aula_extra/features/professor/arquivos/pages/arquivos_professor_screen.dart';
import 'package:aula_extra/features/professor/chats/pages/chats_professor_screen.dart';
import 'package:aula_extra/features/professor/disponibilidade/pages/disponibilidade_professor_screen.dart';
import 'package:aula_extra/features/professor/pagamentos/pages/pagamentos_professor_screen.dart';
import 'package:aula_extra/features/professor/avaliacoes/pages/avaliacoes_professor_screen.dart';
import 'package:aula_extra/features/professor/perfil/pages/perfil_professor_screen.dart';
import 'package:aula_extra/features/professor/meus_anuncios/pages/meus_anuncios_professor_screen.dart';
import 'package:aula_extra/features/professor/notificacoes/pages/notificacoes_professor_screen.dart';
import 'package:aula_extra/features/professor/publicar_anuncio/pages/publicar_anuncio_professor_screen.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:aula_extra/features/aluno/meus_profissionais/pages/meus_tutores_screen.dart';
import 'package:aula_extra/features/aluno/meus_profissionais/pages/meus_psicologos_screen.dart';

class _TeacherOnly extends StatelessWidget {
  const _TeacherOnly({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentRole = context.watch<UserProvider>().role;

    final allowedRoles = [Role.teacher, Role.tutor, Role.psychologist];

    if (allowedRoles.contains(currentRole)) {
      return child;
    }

    // Se houver erro de permissão, ele mostra esta tela. 
    // Se a tua app volta para o início, verifica se a 'BecomeTeacherScreen' 
    // tem algum Navigator.push no seu initState.
    return const BecomeTeacherScreen();
  }
}


class Routes {
  static const String home = '/';
  static const String faq = '/faq';
  static const String contactos = '/contactos';
  static const String comprarCreditos = '/precos';
  static const String becomeTeacher = '/tornar-se-explicador';
  static const String login = '/login';
    static const String newsletterConfirm = '/newsletter/confirmar';
    static const String newsletterCancel = '/newsletter/cancelar';
  static const String profile = '/profile';
  static const String registerStudent = '/register/student';
  static const String explicadores = '/explicadores';
  static const String meusExplicadores = '/aluno/meus-explicadores';
  static const String meusTutores = '/aluno/meus-tutores';         
  static const String meusPsicologos = '/aluno/meus-psicologos';     
  static const String tutores = '/tutores';                  
  static const String psicologos = '/psicologos';
  static const String disciplinas = '/disciplinas';
  static const String tutorProfile = '/explicadores/perfil';
  static const String marcarAulaProfessor = '/aluno/marcar-aula';
  static const String calendario = '/aluno/calendario';
  static const String calendarioSemanal = '/aluno/calendario-semanal';
  static const String arquivos = '/aluno/arquivos';
  static const String chats = '/aluno/chats';
  static const String pagamentos = '/aluno/pagamentos';
  static const String avaliacoes = '/aluno/avaliacoes';
  static const String perfilAluno = '/aluno/perfil';
  static const String notificacoes = '/aluno/notificacoes';
  static const String areasAluno = '/aluno/areas';

  static const String professorMeusAlunos = '/professor/meus-alunos';
    static const String professorPerfilAlunoView = '/professor/meus-alunos/perfil';
  static const String professorMinhasDisciplinas =
      '/professor/minhas-disciplinas';
  static const String professorCalendario = '/professor/calendario';
  static const String professorArquivos = '/professor/arquivos';
  static const String professorChats = '/professor/chats';
  static const String professorDisponibilidade = '/professor/disponibilidade';
  static const String professorPagamentos = '/professor/pagamentos';
  static const String professorAvaliacoes = '/professor/avaliacoes';
  static const String professorPublicarAnuncio = '/professor/publicar-anuncio';
  static const String professorMeusAnuncios = '/professor/meus-anuncios';
  static const String professorPerfil = '/professor/perfil';
  static const String professorNotificacoes = '/professor/notificacoes';

  static Map<String, WidgetBuilder> get all => {
    home: (context) => const HomeScreen(),
    faq: (context) => const FaqScreen(),
    contactos: (context) => const ContactosScreen(),
    comprarCreditos: (context) => const ComprarCreditosScreen(),
    becomeTeacher: (context) => const BecomeTeacherScreen(),
    login: (context) => const LoginScreen(),
    profile: (context) => const ProfileScreen(),
    registerStudent: (context) => const RegisterStudentScreen(),
    explicadores: (context) => const ExplicadoresScreen(),
    meusExplicadores: (context) => const MeusExplicadoresScreen(),
    meusTutores: (context) => const MeusTutoresScreen(),      
    meusPsicologos: (context) => const MeusPsicologosScreen(),
    calendario: (context) => const CalendarioScreen(),
    calendarioSemanal: (context) => const CalendarioSemanalScreen(),
    arquivos: (context) => const ArquivosScreen(),
    chats: (context) => const ChatsScreen(),
    pagamentos: (context) => const PagamentosScreen(),
    avaliacoes: (context) => const AvaliacoesScreen(),
    perfilAluno: (context) => const PerfilAlunoScreen(),
    notificacoes: (context) => const NotificacoesScreen(),
    disciplinas: (context) => const DisciplinasScreen(),
    tutorProfile: (context) => const TutorProfileScreen(),
    marcarAulaProfessor: (context) => const MarcarAulaProfessorScreen(),
    areasAluno: (context) => const AreasAlunoScreen(),
    professorMeusAlunos: (context) =>
        const _TeacherOnly(child: MeusAlunosProfessorScreen()),
    professorPerfilAlunoView: (context) =>
        const _TeacherOnly(child: AlunoProfileViewScreen()),
    professorMinhasDisciplinas: (context) =>
        const _TeacherOnly(child: MinhasDisciplinasProfessorScreen()),
    professorCalendario: (context) =>
        const _TeacherOnly(child: CalendarioProfessorScreen()),
    professorArquivos: (context) =>
        const _TeacherOnly(child: ArquivosProfessorScreen()),
    professorChats: (context) =>
        const _TeacherOnly(child: ChatsProfessorScreen()),
    professorDisponibilidade: (context) =>
        const _TeacherOnly(child: DisponibilidadeProfessorScreen()),
    professorPagamentos: (context) =>
        const _TeacherOnly(child: PagamentosProfessorScreen()),
    professorAvaliacoes: (context) =>
        const _TeacherOnly(child: AvaliacoesProfessorScreen()),
    professorPublicarAnuncio: (context) =>
        const _TeacherOnly(child: PublicarAnuncioProfessorScreen()),
    professorMeusAnuncios: (context) =>
        const _TeacherOnly(child: MeusAnunciosProfessorScreen()),
    professorPerfil: (context) =>
        const _TeacherOnly(child: PerfilProfessorScreen()),
    professorNotificacoes: (context) =>
        const _TeacherOnly(child: NotificacoesProfessorScreen()),
  };

    static String normalizePath(String path) {
        if (path.length > 1 && path.endsWith('/')) {
            return path.substring(0, path.length - 1);
        }

        return path;
    }

    static Widget? resolveDynamic(Uri uri) {
        final path = normalizePath(uri.path);

        switch (path) {
            case newsletterConfirm:
                return NewsletterStatusScreen.confirm(
                    token: uri.queryParameters['token'] ?? '',
                );
            case newsletterCancel:
                return NewsletterStatusScreen.unsubscribe(
                    token: uri.queryParameters['token'] ?? '',
                );
            default:
                return null;
        }
    }
}
