import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Ajustado para usar OpenAI (ChatGPT)
  static const String _apiURL = "https://api.openai.com/v1/chat/completions";
  // O usuário deve passar a chave via --dart-define=AI_KEY=...
  static const String _apiKey = String.fromEnvironment('AI_KEY');

  static Future<Map<String, dynamic>?> generateWordContent(String termo) async {
    print("AI_SERVICE: Iniciando geração para '$termo' usando OpenAI...");
    
    if (_apiKey.isEmpty) {
      print("AI_SERVICE ERROR: A chave AI_KEY (OpenAI) está vazia! Verifique o --dart-define.");
      return null;
    }

    final prompt = """
    Gere um JSON estruturado exatamente como este exemplo para a palavra literária '$termo':
    {
      "definicao": "valor curto",
      "etimologia": "valor",
      "classe_gramatical": "valor",
      "frase_lacuna": "frase de autor clássico com ___",
      "autor_citacao": "nome do autor",
      "pergunta_quiz": "texto da pergunta",
      "opcoes_quiz": ["op1", "op2", "op3", "op4"],
      "index_correto_quiz": 1,
      "explicacao_erro": "explicação pedagógica",
      "desafio_criativo": "proposta narrativa",
      "aceitas_flexoes": ["v1", "v2", "v3"]
    }
    Responda APENAS o JSON puro, sem markdown ou explicações. Seja erudito e poético.
    """;

    try {
      print("AI_SERVICE: Enviando requisição para OpenAI (gpt-3.5-turbo)...");
      final response = await http.post(
        Uri.parse(_apiURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "system", "content": "Você é um mestre bibliotecário de um grimório místico."},
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.7
        }),
      );

      print("AI_SERVICE: Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String content = data['choices'][0]['message']['content'];
        
        print("AI_SERVICE: Resposta OpenAI recebida!");
        
        // Limpar possíveis markdown
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();
        
        return jsonDecode(content);
      } else {
        print("AI_SERVICE ERROR OpenAI: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("AI_SERVICE EXCEPTION OpenAI: $e");
    }
    return null;
  }
}
