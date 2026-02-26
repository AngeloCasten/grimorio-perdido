import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Serviço que gerencia a integração com a IA (Google Gemini Free).
/// Certifique-se de passar a chave via --dart-define=AI_KEY=SUA_CHAVE no build/run.
class AIService {
  // Chave de API recuperada das variáveis de ambiente do Flutter.
  static const String _apiKey = String.fromEnvironment('AI_KEY');

  static Future<Map<String, dynamic>?> generateWordContent(String termo) async {
    print("AI_SERVICE: ✨ Invocando o Oráculo para '$termo' (Gemini 1.5 Flash - Free)...");
    
    if (_apiKey.isEmpty) {
      print("AI_SERVICE ERROR: A chave AI_KEY não foi encontrada! Use --dart-define=AI_KEY=...");
      return null;
    }

    try {
      // Usando o modelo 'gemini-1.5-flash', que é o mais rápido e otimizado para o plano grátis.
      final model = GenerativeModel(
        model: 'gemini-1.5-flash', 
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.8,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 2048,
          responseMimeType: 'application/json', // Solicita resposta em formato JSON nativo
        ),
      );

      final prompt = """
      Você é o Mestre Bibliotecário do 'Grimório Perdido', uma entidade mística e erudita.
      Sua missão é detalhar a palavra literária: '$termo'.
      
      Gere um JSON estruturado exatamente como este exemplo, com conteúdo literário, poético e fascinante:
      {
        "definicao": "descrição curta e erudita do significado",
        "etimologia": "origem etimológica da palavra",
        "classe_gramatical": "ex: substantivo, adjetivo",
        "frase_lacuna": "uma frase de um autor clássico da língua portuguesa contendo '___' no lugar da palavra",
        "autor_citacao": "nome do autor real da frase acima",
        "pergunta_quiz": "uma pergunta instigante sobre o uso ou nuance desta palavra",
        "opcoes_quiz": ["opção 1", "opção 2", "opção 3", "opção 4"],
        "index_correto_quiz": 1,
        "explicacao_erro": "uma breve explicação mística sobre por que as outras opções são sombras do significado original",
        "desafio_criativo": "uma pequena proposta de escrita usando a palavra",
        "aceitas_flexoes": ["flexao_1", "flexao_2", "flexao_3"]
      }
      
      Atenção: Retorne APENAS o JSON puro, sem blocos de código markdown. Seja fiel à língua portuguesa erudita.
      """;

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (response.text != null) {
        String jsonString = response.text!;
        print("AI_SERVICE: Resposta do Oráculo recebida com sucesso.");
        
        // Limpeza de segurança caso o modelo insista em Markdown
        jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();
        
        return jsonDecode(jsonString);
      } else {
        print("AI_SERVICE ERROR: O Oráculo permaneceu em silêncio.");
      }
    } catch (e) {
      print("AI_SERVICE EXCEPTION: Erro ao consultar o Gemini: $e");
      
      if (e.toString().contains("429") || e.toString().contains("quota")) {
        print("DICA: Você atingiu o limite do plano grátis (15 requisições/min). Aguarde um momento.");
      } else if (e.toString().contains("401") || e.toString().contains("403")) {
        print("DICA: A chave de API (AI_KEY) parece ser inválida para o Google AI SDK.");
      }
    }
    return null;
  }
}
