import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

class ProfessorStudentProfileScreen extends StatefulWidget {
  final String studentId;
  const ProfessorStudentProfileScreen({super.key, required this.studentId});

  @override
  State<ProfessorStudentProfileScreen> createState() => _ProfessorStudentProfileScreenState();
}

class _ProfessorStudentProfileScreenState extends State<ProfessorStudentProfileScreen> {
  late Future<Map<String, dynamic>> _studentData;

  @override
  void initState() {
    super.initState();
    _studentData = _fetchStudentDetails();
  }

  Future<Map<String, dynamic>> _fetchStudentDetails() async {
    final token = await TokenStorage().loadToken();
    final response = await http.get(
      ApiConfig.uri('/api/Users/${widget.studentId}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar detalhes do aluno');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil do Aluno')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _studentData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));

          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                const SizedBox(height: 20),
                Text('Nome: ${user['firstName']} ${user['lastName']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Email: ${user['email']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Telemóvel: ${user['mobileNumber'] ?? 'Não registado'}', style: const TextStyle(fontSize: 18)),
                const Divider(height: 40),
                const Text('Sobre o Aluno:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(user['biography'] ?? 'Sem biografia disponível.'),
              ],
            ),
          );
        },
      ),
    );
  }
}