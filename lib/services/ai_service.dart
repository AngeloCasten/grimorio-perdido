import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiURL = "https://api.openai.com/v1/chat/completions";
  // O usuário deve passar a chave via --dart-define=AI_KEY=...
  static const String _apiKey = String.fromEnvironment('AI_KEY');

  static Future<Map<String, dynamic>?> generateWordContent(String termo) async {
    if (_apiKey.isEmpty) return null;

    final prompt = """
    Gere um JSON para a palavra literária '$termo' com os campos:
    definicao (curta), 
    etimologia (origem da palavra), 
    classe_gramatical, 
    frase_lacuna (uma frase de autor clássico com a palavra substituída por ___), 
    autor_citacao, 
    pergunta_quiz, 
    opcoes_quiz (lista de 4 strings), 
    index_correto_quiz (0 a 3), 
    explicacao_erro, 
    desafio_criativo (proposta de escrita), 
    aceitas_flexoes (lista de 3 variações).
    Responda APENAS o JSON.
    """;

    try {
      final response = await http.post(
        Uri.parse(_apiURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [{"role": "user", "content": prompt}],
          "temperature": 0.7
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content);
      }
    } catch (e) {
      print("Erro na IA: $e");
    }
    return null;
  }
}
