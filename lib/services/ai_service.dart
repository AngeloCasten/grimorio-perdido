import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // O usuário deve passar a chave via --dart-define=AI_KEY=...
  static const String _apiKey = String.fromEnvironment('AI_KEY');

  static Future<Map<String, dynamic>?> generateWordContent(String termo) async {
    print("AI_SERVICE: Iniciando geração para '$termo' usando SDK oficial...");
    
    if (_apiKey.isEmpty) {
      print("AI_SERVICE ERROR: A chave AI_KEY está vazia! Verifique o --dart-define.");
      return null;
    } else {
      print("AI_SERVICE: Chave detectada (Início: ${_apiKey.substring(0, 5)}...)");
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

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

      print("AI_SERVICE: Enviando prompt ao Gemini SDK...");
      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text != null) {
        String content = response.text!;
        print("AI_SERVICE: Resposta recebida!");
        
        // Limpar possíveis markdown code blocks
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();
        
        return jsonDecode(content);
      } else {
        print("AI_SERVICE ERROR: Resposta do modelo vazia.");
      }
    } catch (e) {
      print("AI_SERVICE EXCEPTION: $e");
    }
    return null;
  }
}
