import 'package:flutter/widgets.dart';
import 'package:aula_extra/features/disciplinas/pages/disciplinas_screen.dart';
import 'package:aula_extra/features/explicadores/pages/explicadores_screen.dart';
import 'package:aula_extra/features/aluno/areas_aluno/pages/areas_aluno_screen.dart';
import 'package:aula_extra/features/aluno/meus_explicadores/pages/meus_explicadores_screen.dart';
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
import 'package:aula_extra/features/become_teacher/pages/become_teacher_screen.dart';
import 'package:aula_extra/features/home/pages/home_screen.dart';
import 'package:aula_extra/features/login/pages/login_screen.dart';
import 'package:aula_extra/features/profile/pages/profile_screen.dart';
import 'package:aula_extra/features/register/pages/register_student_screen.dart';
import 'package:aula_extra/features/professor/meus_alunos/pages/meus_alunos_professor_screen.dart';
import 'package:aula_extra/features/professor/calendario/pages/calendario_professor_screen.dart';
import 'package:aula_extra/features/professor/arquivos/pages/arquivos_professor_screen.dart';
import 'package:aula_extra/features/professor/chats/pages/chats_professor_screen.dart';
import 'package:aula_extra/features/professor/disponibilidade/pages/disponibilidade_professor_screen.dart';
import 'package:aula_extra/features/professor/pagamentos/pages/pagamentos_professor_screen.dart';
import 'package:aula_extra/features/professor/avaliacoes/pages/avaliacoes_professor_screen.dart';
import 'package:aula_extra/features/professor/perfil/pages/perfil_professor_screen.dart';
import 'package:aula_extra/features/professor/notificacoes/pages/notificacoes_professor_screen.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/data/auth/auth_service.dart';

class _TeacherOnly extends StatefulWidget {
  const _TeacherOnly({required this.child});

  final Widget child;

  @override
  State<_TeacherOnly> createState() => _TeacherOnlyState();
}

class _TeacherOnlyState extends State<_TeacherOnly> {
  final TokenStorage _tokenStorage = TokenStorage();
  bool? _isTeacher;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    try {
      final token = await _tokenStorage.loadToken();
      if (token == null || token.trim().isEmpty) {
        if (!mounted) return;
        setState(() => _isTeacher = false);
        return;
      }

      // Confirm roles with backend (prevents stale JWT granting access).
      bool teacher;
      try {
        final session = await AuthService(tokenStorage: _tokenStorage).refresh();
        teacher = session.appRole == Role.teacher;
      } catch (_) {
        // If we cannot confirm with backend, deny teacher access.
        teacher = false;
      }

      if (!mounted) return;

      // As a tiny resilience fallback, if refresh succeeded earlier but appRole is teacher,
      // we don't need to parse JWT. If refresh failed, teacher is already false.
      if (teacher == false) {
        // Keep a best-effort provider correction (won't grant teacher).
        final provider = context.read<UserProvider>();
        if (provider.role == Role.teacher) provider.setRole(Role.student);
      }
      setState(() => _isTeacher = teacher);

      // Keep provider role consistent (best-effort).
      final provider = context.read<UserProvider>();
      if (teacher && provider.role != Role.teacher) provider.setRole(Role.teacher);
      if (!teacher && provider.role == Role.teacher) provider.setRole(Role.student);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isTeacher = false);
      final provider = context.read<UserProvider>();
      if (provider.role == Role.teacher) provider.setRole(Role.student);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = _isTeacher;

    // Safe default: deny until proven.
    if (isTeacher != true) {
      return const BecomeTeacherScreen();
    }

    return widget.child;
  }
}

class Routes {
  static const String home = '/';
  static const String faq = '/faq';
  static const String becomeTeacher = '/tornar-se-explicador';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String registerStudent = '/register/student';
  static const String explicadores = '/explicadores';
  static const String meusExplicadores = '/aluno/meus-explicadores';
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
  static const String professorStudentProfile = '/professor/meus-alunos/perfil';

  static const String professorMeusAlunos = '/professor/meus-alunos';
  static const String professorCalendario = '/professor/calendario';
  static const String professorArquivos = '/professor/arquivos';
  static const String professorChats = '/professor/chats';
  static const String professorDisponibilidade = '/professor/disponibilidade';
  static const String professorPagamentos = '/professor/pagamentos';
  static const String professorAvaliacoes = '/professor/avaliacoes';
  static const String professorPerfil = '/professor/perfil';
  static const String professorNotificacoes = '/professor/notificacoes';

  static Map<String, WidgetBuilder> get all => {
        home: (context) => const HomeScreen(),
      faq: (context) => const FaqScreen(),
        becomeTeacher: (context) => const BecomeTeacherScreen(),
        login: (context) => const LoginScreen(),
        profile: (context) => const ProfileScreen(),
        registerStudent: (context) => const RegisterStudentScreen(),
        explicadores: (context) => const ExplicadoresScreen(),
        meusExplicadores: (context) => const MeusExplicadoresScreen(),
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
        professorMeusAlunos: (context) => const _TeacherOnly(child: MeusAlunosProfessorScreen()),
        professorCalendario: (context) => const _TeacherOnly(child: CalendarioProfessorScreen()),
        professorArquivos: (context) => const _TeacherOnly(child: ArquivosProfessorScreen()),
        professorChats: (context) => const _TeacherOnly(child: ChatsProfessorScreen()),
        professorDisponibilidade: (context) => const _TeacherOnly(child: DisponibilidadeProfessorScreen()),
        professorPagamentos: (context) => const _TeacherOnly(child: PagamentosProfessorScreen()),
        professorAvaliacoes: (context) => const _TeacherOnly(child: AvaliacoesProfessorScreen()),
        professorPerfil: (context) => const _TeacherOnly(child: PerfilProfessorScreen()),
        professorNotificacoes: (context) => const _TeacherOnly(child: NotificacoesProfessorScreen()),
        professorStudentProfile: (context) {
        final studentId = ModalRoute.of(context)!.settings.arguments as String;
        return _TeacherOnly(child: ProfessorStudentProfileScreen(studentId: studentId));
        },
      };
}
