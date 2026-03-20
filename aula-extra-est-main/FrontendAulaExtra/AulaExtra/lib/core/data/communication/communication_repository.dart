import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aula_extra/core/data/communication/dtos/message_dto.dart';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

class CommunicationRepository {
  final String baseUrl = '${ApiConfig.baseUrl}/Communication'; 

  // Função para ir buscar todas as mensagens
  Future<List<MessageDto>> getMessages() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/messages'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MessageDto.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao carregar mensagens: $e');
      return [];
    }
  }

  final TokenStorage _tokenStorage = TokenStorage();

  Future<bool> sendMessage(MessageDto message) async {
    try {
      // 1. Carregar o Token da Sessão
      final token = await _tokenStorage.loadToken();
      
      // 2. Montar o URL
      final urlReal = '$baseUrl/messages';

      print('--- TENTATIVA DE ENVIO DE MENSAGEM ---');
      print('URL que o Flutter está a chamar: $urlReal'); // <-- ISTO DESCOBRE O ERRO
      print('Token existe? ${token != null && token.isNotEmpty}');

      // 3. Fazer o pedido POST com a Autenticação
      final response = await http.post(
        Uri.parse(urlReal),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // A Chave de Segurança!
        },
        body: json.encode(message.toJson()),
      );

      print('Status Code: ${response.statusCode}');
      print('Resposta do Servidor: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('--- ERRO GRAVE DE CONEXÃO ---');
      print('Erro: $e');
      return false;
    }
  }
}