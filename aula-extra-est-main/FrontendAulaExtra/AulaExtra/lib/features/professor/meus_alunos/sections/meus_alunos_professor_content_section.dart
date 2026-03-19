import 'package:flutter/material.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_aluno_dto.dart';
import 'package:aula_extra/core/data/professors/professors_api.dart';
import 'package:aula_extra/core/data/session/token_storage.dart'; 
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/calendario/widgets/full_bleed_scaled_section.dart';

import '../widgets/alunos_grid.dart';

class MeusAlunosProfessorContentSection extends StatefulWidget {
  const MeusAlunosProfessorContentSection({super.key});

  @override
  State<MeusAlunosProfessorContentSection> createState() => _MeusAlunosProfessorContentSectionState();
}

class _MeusAlunosProfessorContentSectionState extends State<MeusAlunosProfessorContentSection> {
  late Future<List<ProfessorAlunoDto>> _studentsFuture;
  final ProfessorsApi _professorsApi = ProfessorsApi();

  @override
  void initState() {
    super.initState();
    _studentsFuture = _carregarAlunos();
  }

  Future<List<ProfessorAlunoDto>> _carregarAlunos() async {
    final tokenStorage = TokenStorage();
    final token = await tokenStorage.loadToken() ?? '';
    return await _professorsApi.getMeusAlunos(token: token);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 30.0, 
            right: 30.0,
            top: 40.0,
            bottom: 90.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfessorMenuNav(selectedIndex: 0), 
              
              const SizedBox(width: 30), 

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meus Alunos',
                      style: TextStyle(
                        color: Color(0xFF1D2838),
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 40),

                    FutureBuilder<List<ProfessorAlunoDto>>(
                      future: _studentsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Erro: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final alunos = snapshot.data ?? [];

                        if (alunos.isEmpty) {
                          return const Center(
                            child: Text('Ainda não tens alunos associados.'),
                          );
                        }

                        return AlunosGrid(
                          alunos: alunos,
                        );
                      },
                    ),
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