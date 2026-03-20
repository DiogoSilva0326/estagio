import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/calendario/widgets/full_bleed_scaled_section.dart';

class ProfessorStudentProfileScreen extends StatefulWidget {
  final String studentId;
  
  const ProfessorStudentProfileScreen({
    super.key, 
    required this.studentId,
  });

  @override
  State<ProfessorStudentProfileScreen> createState() => _ProfessorStudentProfileScreenState();
}

class _ProfessorStudentProfileScreenState extends State<ProfessorStudentProfileScreen> {
  late Future<Map<String, dynamic>> _studentDataFuture;

  @override
  void initState() {
    super.initState();
    _studentDataFuture = _carregarDetalhesDoAluno();
  }

  Future<Map<String, dynamic>> _carregarDetalhesDoAluno() async {
    final token = await TokenStorage().loadToken() ?? '';
    
    final response = await http.get(
      ApiConfig.uri('/api/Users/${widget.studentId}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 404) {
      throw Exception('Aluno não encontrado (404)');
    } else {
      throw Exception('Falha ao carregar detalhes do aluno (${response.statusCode})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedHeaderDelegate(
              height: 90,
              child: const AppHeader(),
            ),
          ),

          SliverToBoxAdapter(
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
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: _studentDataFuture,
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

                          final user = snapshot.data!;

                          final String firstName = user['firstName'] ?? 'Sem';
                          final String lastName = user['lastName'] ?? 'Nome';
                          final String username = user['userName'] ?? user['username'] ?? 'sem.user'; 
                          final String email = user['email'] ?? 'Sem email';
                          final String? mobileNumber = user['mobileNumber'];
                          final String? biography = user['biography'];
                          final String? avatarUrl = user['avatarUrl'];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back, color: Color(0xFF697282)),
                                label: const Text('Voltar para Meus Alunos', style: TextStyle(color: Color(0xFF697282))),
                              ),
                              const SizedBox(height: 20),

                              const Text(
                                'Perfil do Aluno',
                                style: TextStyle(color: Color(0xFF1D2838), fontWeight: FontWeight.w700, fontSize: 32),
                              ),
                              const SizedBox(height: 40),

                              _buildInfoCard(firstName, lastName, username, email, mobileNumber, avatarUrl),

                              const SizedBox(height: 30),

                              _buildAboutCard(biography),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: FooterSection()),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String firstName, String lastName, String username, String email, String? mobileNumber, String? avatarUrl) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFE5E7EB),
            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) 
                ? NetworkImage(avatarUrl) 
                : null,
            child: (avatarUrl == null || avatarUrl.isEmpty) 
                ? const Icon(Icons.person, size: 50, color: Color(0xFF9CA3AF)) 
                : null,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$firstName $lastName',
                  style: const TextStyle(color: Color(0xFF1D2838), fontWeight: FontWeight.w600, fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  '@$username',
                  style: const TextStyle(color: Color(0xFF697282), fontWeight: FontWeight.w500, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Email: $email',
                  style: const TextStyle(color: Color(0xFF697282), fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Telemóvel: ${mobileNumber ?? 'Não registado'}',
                  style: const TextStyle(color: Color(0xFF697282), fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(String? biography) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sobre o Aluno',
            style: TextStyle(color: Color(0xFF1D2838), fontWeight: FontWeight.w600, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Text(
            (biography != null && biography.trim().isNotEmpty) 
                ? biography 
                : 'Este aluno ainda não preencheu a sua biografia.',
            style: const TextStyle(color: Color(0xFF495565), fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}