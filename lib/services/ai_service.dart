import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Ajustado para usar o Google Gemini API
  static const String _apiURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";
  // O usuário deve passar a chave via --dart-define=AI_KEY=...
  static const String _apiKey = String.fromEnvironment('AI_KEY');

  static Future<Map<String, dynamic>?> generateWordContent(String termo) async {
    print("AI_SERVICE: Iniciando geração para '$termo'...");
    
    if (_apiKey.isEmpty) {
      print("AI_SERVICE ERROR: A chave AI_KEY está vazia! Verifique o --dart-define.");
      return null;
    } else {
      print("AI_SERVICE: Chave detectada (Início: ${_apiKey.substring(0, 5)}...)");
    }

    final prompt = """
    Gere um JSON estruturado exatamente como este exemplo para a palavra literária '$termo':
    {
      "definicao": "valor",
      "etimologia": "valor",
      "classe_gramatical": "valor",
      "frase_lacuna": "frase com ___",
      "autor_citacao": "nome",
      "pergunta_quiz": "texto",
      "opcoes_quiz": ["op1", "op2", "op3", "op4"],
      "index_correto_quiz": 1,
      "explicacao_erro": "texto",
      "desafio_criativo": "texto",
      "aceitas_flexoes": ["v1", "v2", "v3"]
    }
    Responda APENAS o JSON puro, sem markdown ou explicações.
    """;

    try {
      print("AI_SERVICE: Enviando requisição para Google Gemini...");
      final response = await http.post(
        Uri.parse("$_apiURL?key=$_apiKey"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 1024,
          }
        }),
      );

      print("AI_SERVICE: Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String content = data['candidates'][0]['content']['parts'][0]['text'];
        
        print("AI_SERVICE: Resposta recebida com sucesso!");
        
        // Limpar possíveis markdown code blocks que o Gemini às vezes retorna
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();
        
        return jsonDecode(content);
      } else {
        print("AI_SERVICE ERROR: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("AI_SERVICE EXCEPTION: $e");
    }
    return null;
  }
}
