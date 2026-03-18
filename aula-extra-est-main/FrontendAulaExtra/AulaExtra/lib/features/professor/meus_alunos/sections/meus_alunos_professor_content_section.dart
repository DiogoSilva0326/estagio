import 'package:flutter/material.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_aluno_dto.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_colors.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_layout.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/alunos_grid.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/full_bleed_scaled_section.dart';

class MeusAlunosProfessorContentSection extends StatefulWidget {
  const MeusAlunosProfessorContentSection({super.key});

  @override
  State<MeusAlunosProfessorContentSection> createState() => _MeusAlunosProfessorContentSectionState();
}

class _MeusAlunosProfessorContentSectionState extends State<MeusAlunosProfessorContentSection> {
  final ProfessorsService _service = ProfessorsService(); // Alterado para Service
  List<ProfessorAlunoDto> _alunos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAlunos();
  }

  Future<void> _fetchAlunos() async {
    try {
      final alunos = await _service.fetchMeusAlunos();
      setState(() {
        _alunos = alunos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao carregar alunos: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: MeusAlunosProfessorColors.title,
      fontWeight: FontWeight.w800,
      fontSize: MeusAlunosProfessorLayout.titleFontSize,
      height: MeusAlunosProfessorLayout.titleLineHeight / MeusAlunosProfessorLayout.titleFontSize,
    );

    return Container(
      color: MeusAlunosProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: MeusAlunosProfessorLayout.pageLeftPadding,
            right: MeusAlunosProfessorLayout.pageRightPadding,
            top: MeusAlunosProfessorLayout.pageTopPadding,
            bottom: 90,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfessorMenuNav(),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meus Alunos', style: titleStyle),
                    const SizedBox(height: 30),
                    
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator(color: Colors.orange))
                    else if (_errorMessage != null)
                      Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                    else if (_alunos.isEmpty)
                      const Center(child: Text("Ainda não tem alunos atribuídos.", style: TextStyle(fontSize: 18)))
                    else
                      AlunosGrid(alunos: _alunos),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}