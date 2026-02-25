import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_models.dart';
import '../data/game_data.dart';
import 'dart:convert';

class GameProvider extends ChangeNotifier {
  List<EraLiteraria> _eras = [];
  List<String> _palavrasDominadas = [];
  int _nivel = 1;
  int _xp = 0;
  int _fragmentos = 0;
  int _pontosTalento = 0;
  List<String> _talentos = [];
  List<String> _erasRestauradas = [];

  GameProvider() {
    _eras = List.from(bibliotecaDeEras);
    _loadProgress();
  }

  List<EraLiteraria> get eras => _eras;
  List<String> get palavrasDominadas => _palavrasDominadas;
  int get nivel => _nivel;
  int get xp => _xp;
  int get fragmentos => _fragmentos;
  int get pontosTalento => _pontosTalento;
  List<String> get talentos => _talentos;
  List<String> get erasRestauradas => _erasRestauradas;

  // Carregar progresso do SharedPreferences (Mocking Database)
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _nivel = prefs.getInt('nivel') ?? 1;
    _xp = prefs.getInt('xp') ?? 0;
    _fragmentos = prefs.getInt('fragmentos') ?? 0;
    _pontosTalento = prefs.getInt('pontosTalento') ?? 0;
    _palavrasDominadas = prefs.getStringList('palavrasDominadas') ?? ["p1"];
    _talentos = prefs.getStringList('talentos') ?? [];
    _erasRestauradas = prefs.getStringList('erasRestauradas') ?? [];
    
    // Atualizar o PlayerProgress estático para compatibilidade com código antigo
    PlayerProgress.nivelIluminacao = _nivel;
    PlayerProgress.xpAtual = _xp;
    PlayerProgress.fragmentosDeAlma = _fragmentos;
    PlayerProgress.pontosTalento = _pontosTalento;
    PlayerProgress.palavrasDominadas = _palavrasDominadas;
    PlayerProgress.talentosDesbloqueados = _talentos;
    PlayerProgress.erasRestauradas = _erasRestauradas;
    
    notifyListeners();
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nivel', _nivel);
    await prefs.setInt('xp', _xp);
    await prefs.setInt('fragmentos', _fragmentos);
    await prefs.setInt('pontosTalento', _pontosTalento);
    await prefs.setStringList('palavrasDominadas', _palavrasDominadas);
    await prefs.setStringList('talentos', _talentos);
    await prefs.setStringList('erasRestauradas', _erasRestauradas);
  }

  void adicionarPalavra(String eraId, PalavraMestra novaPalavra) {
    int eraIndex = _eras.indexWhere((e) => e.id == eraId);
    if (eraIndex != -1) {
      // Como EraLiteraria é const no game_data, precisamos criar uma nova instância ou cópia
      final eraAntiga = _eras[eraIndex];
      _eras[eraIndex] = EraLiteraria(
        id: eraAntiga.id,
        nome: eraAntiga.nome,
        descricao: eraAntiga.descricao,
        corTema: eraAntiga.corTema,
        avatarSeed: eraAntiga.avatarSeed,
        iconeArtefato: eraAntiga.iconeArtefato,
        nomeArtefato: eraAntiga.nomeArtefato,
        palavras: [...eraAntiga.palavras, novaPalavra],
      );
      notifyListeners();
    }
  }

  void dominarPalavra(String id, int xpGanho) {
    if (!_palavrasDominadas.contains(id)) {
      _palavrasDominadas.add(id);
      ganharXP(xpGanho);
      saveProgress();
      notifyListeners();
    }
  }

  void ganharXP(int quantidade) {
    int bonus = _talentos.contains("t_dobro_xp") ? 5 : 0;
    _xp += (quantidade + bonus);
    while (_xp >= 100) {
      _xp -= 100;
      _nivel++;
      _pontosTalento++;
    }
    saveProgress();
    notifyListeners();
  }

  void restaurarEra(String eraId) {
    if (!_erasRestauradas.contains(eraId)) {
      _erasRestauradas.add(eraId);
      _fragmentos += 100;
      saveProgress();
      notifyListeners();
    }
  }

  void comprarTalento(Talento talento) {
    if (_pontosTalento >= talento.custo && !_talentos.contains(talento.id)) {
      _pontosTalento -= talento.custo;
      _talentos.add(talento.id);
      saveProgress();
      notifyListeners();
    }
  }
}
