import 'package:flutter/material.dart';

class PlayerProgress {
  static String nomeGuardiao = "Viajante";
  static int nivelIluminacao = 1;
  static int xpAtual = 0;
  static int xpParaProximoNivel = 100;
  static int fragmentosDeAlma = 0;
  static int pontosTalento = 0;
  static List<String> palavrasDominadas = ["p1"];
  static List<String> erasRestauradas = [];
  static List<String> talentosDesbloqueados = [];

  // --- Lógica de Títulos ---
  static String get tituloAtual {
    if (nivelIluminacao < 3) return "Noviço das Letras";
    if (nivelIluminacao < 5) return "Escriba Viajante";
    if (nivelIluminacao < 10) return "Guardião da Memória";
    if (nivelIluminacao < 20) return "Mestre dos Tempos";
    return "Luminar Eterno";
  }

  // --- Função para Ganhar XP ---
  static void ganharXP(int quantidade) {
    // Aplica bônus se tiver o talento de XP
    int bonus = talentosDesbloqueados.contains("t_dobro_xp") ? 5 : 0;
    xpAtual += (quantidade + bonus);
    while (xpAtual >= xpParaProximoNivel) {
      xpAtual -= xpParaProximoNivel;
      nivelIluminacao++;
      pontosTalento++; // Ganha ponto ao subir de nível
    }
  }

  // --- Função Exigida pelo Sistema de Quiz/Palavras ---
  static void dominarPalavra(String idPalavra, int xpGanho) {
    if (!palavrasDominadas.contains(idPalavra)) {
      palavrasDominadas.add(idPalavra);
      ganharXP(xpGanho);
    }
  }

  // --- Função Exigida para verificar o progresso da Era ---
  static void verificarEraCompleta(EraLiteraria era) {
    bool todasDominadas = era.palavras.every((p) => palavrasDominadas.contains(p.id));
    if (todasDominadas && !erasRestauradas.contains(era.id)) {
      erasRestauradas.add(era.id);
      fragmentosDeAlma += 100; // Recompensa extra em fragmentos
    }
  }
}

class PalavraMestra {
  final String id;
  final String termoPrincipal;
  final String definicao;
  final String etimologia;
  final String classeGramatical;
  final String fraseLacuna; // Ex: "A ___ da vida..."
  final String autorCitacao;
  final String perguntaQuiz;
  final List<String> opcoesQuiz;
  final int indexCorretoQuiz;
  final String explicacaoErro;
  final String desafioCriativo; // Para a fase de escrita
  final List<String> aceitasFlexoes; // Sinônimos aceitos
  final int xpValor; // XP obtido ao dominar a palavra

  const PalavraMestra({
    required this.id,
    required this.termoPrincipal,
    required this.definicao,
    required this.etimologia,
    required this.classeGramatical,
    required this.fraseLacuna,
    required this.autorCitacao,
    required this.perguntaQuiz,
    required this.opcoesQuiz,
    required this.indexCorretoQuiz,
    required this.explicacaoErro,
    required this.desafioCriativo,
    required this.aceitasFlexoes,
    this.xpValor = 200,
  });

  PalavraMestra copyWith({
    String? id,
    String? termoPrincipal,
    String? definicao,
    String? etimologia,
    String? classeGramatical,
    String? fraseLacuna,
    String? autorCitacao,
    String? perguntaQuiz,
    List<String>? opcoesQuiz,
    int? indexCorretoQuiz,
    String? explicacaoErro,
    String? desafioCriativo,
    List<String>? aceitasFlexoes,
    int? xpValor,
  }) {
    return PalavraMestra(
      id: id ?? this.id,
      termoPrincipal: termoPrincipal ?? this.termoPrincipal,
      definicao: definicao ?? this.definicao,
      etimologia: etimologia ?? this.etimologia,
      classeGramatical: classeGramatical ?? this.classeGramatical,
      fraseLacuna: fraseLacuna ?? this.fraseLacuna,
      autorCitacao: autorCitacao ?? this.autorCitacao,
      perguntaQuiz: perguntaQuiz ?? this.perguntaQuiz,
      opcoesQuiz: opcoesQuiz ?? this.opcoesQuiz,
      indexCorretoQuiz: indexCorretoQuiz ?? this.indexCorretoQuiz,
      explicacaoErro: explicacaoErro ?? this.explicacaoErro,
      desafioCriativo: desafioCriativo ?? this.desafioCriativo,
      aceitasFlexoes: aceitasFlexoes ?? this.aceitasFlexoes,
      xpValor: xpValor ?? this.xpValor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'termo_principal': termoPrincipal,
      'definicao': definicao,
      'etimologia': etimologia,
      'classe_gramatical': classeGramatical,
      'frase_lacuna': fraseLacuna,
      'autor_citacao': autorCitacao,
      'pergunta_quiz': perguntaQuiz,
      'opcoes_quiz': opcoesQuiz,
      'index_correto_quiz': indexCorretoQuiz,
      'explicacao_erro': explicacaoErro,
      'desafio_criativo': desafioCriativo,
      'aceitas_flexoes': aceitasFlexoes,
      'xp_valor': xpValor,
    };
  }

  factory PalavraMestra.fromMap(Map<String, dynamic> map) {
    return PalavraMestra(
      id: map['id'],
      termoPrincipal: map['termo_principal'],
      definicao: map['definicao'],
      etimologia: map['etimologia'],
      classeGramatical: map['classe_gramatical'],
      fraseLacuna: map['frase_lacuna'],
      autorCitacao: map['autor_citacao'],
      perguntaQuiz: map['pergunta_quiz'],
      opcoesQuiz: List<String>.from(map['opcoes_quiz']),
      indexCorretoQuiz: map['index_correto_quiz'],
      explicacaoErro: map['explicacao_erro'],
      desafioCriativo: map['desafio_criativo'],
      aceitasFlexoes: List<String>.from(map['aceitas_flexoes']),
      xpValor: map['xp_valor'] ?? 200,
    );
  }
}

class EraLiteraria {
  final String id;
  final String nome;
  final String descricao;
  final Color corTema;
  final String avatarSeed; // Para gerar o avatar do mentor
  final IconData iconeArtefato;
  final String nomeArtefato;
  final List<PalavraMestra> palavras;

  const EraLiteraria({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.corTema,
    required this.avatarSeed,
    required this.iconeArtefato,
    required this.nomeArtefato,
    required this.palavras,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'cor_tema': corTema.value,
      'avatar_seed': avatarSeed,
      'icone_code': iconeArtefato.codePoint,
      'nome_artefato': nomeArtefato,
      // Palavras geralmente serão salvas em tabela separada no Supabase, mas toMap ajuda em cache local
    };
  }

  factory EraLiteraria.fromMap(Map<String, dynamic> map, List<PalavraMestra> palavras) {
    return EraLiteraria(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      corTema: Color(map['cor_tema']),
      avatarSeed: map['avatar_seed'],
      iconeArtefato: IconData(map['icone_code'], fontFamily: 'MaterialIcons'),
      nomeArtefato: map['nome_artefato'],
      palavras: palavras,
    );
  }
}

class Talento {
  final String id;
  final String nome;
  final String descricao;
  final IconData icone;
  final int custo;

  Talento({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.icone,
    this.custo = 1,
  });
}
