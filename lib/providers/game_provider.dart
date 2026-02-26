import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_models.dart';
import '../data/game_data.dart';
import 'dart:convert';

class GameProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  List<EraLiteraria> _eras = [];
  List<String> _palavrasDominadas = [];
  int _nivel = 1;
  int _xp = 0;
  int _fragmentos = 0;
  int _pontosTalento = 0;
  List<String> _talentos = [];
  List<String> _erasRestauradas = [];
  List<Map<String, dynamic>> _leaderboard = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GameProvider() {
    _eras = List.from(bibliotecaDeEras);
    _initializeData();
  }

  List<EraLiteraria> get eras => _eras;
  List<String> get palavrasDominadas => _palavrasDominadas;
  int get nivel => _nivel;
  int get xp => _xp;
  int get fragmentos => _fragmentos;
  int get pontosTalento => _pontosTalento;
  List<String> get talentos => _talentos;
  List<String> get erasRestauradas => _erasRestauradas;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;

  Future<void> _initializeData() async {
    await _loadProgressLocal();
    await syncWithSupabase();
    await fetchLeaderboard();
  }

  // --- SINCRONIZAÇÃO SUPABASE ---

  Future<void> syncWithSupabase() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Tentar buscar perfil do Supabase
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        // Atualizar local com dados da nuvem (Nuvem manda)
        _nivel = response['nivel'] ?? _nivel;
        _xp = response['xp'] ?? _xp;
        _fragmentos = response['fragmentos'] ?? _fragmentos;
        _pontosTalento = response['pontos_talento'] ?? _pontosTalento;
        _palavrasDominadas = List<String>.from(response['palavras_dominadas'] ?? _palavrasDominadas);
        _talentos = List<String>.from(response['talentos'] ?? _talentos);
        _erasRestauradas = List<String>.from(response['eras_restauradas'] ?? _erasRestauradas);
        await saveProgress(); // Salva localmente o que veio da nuvem
      } else {
        // Criar perfil se não existir (Local manda)
        await _supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'nivel': _nivel,
          'xp': _xp,
          'fragmentos': _fragmentos,
          'pontos_talento': _pontosTalento,
          'palavras_dominadas': _palavrasDominadas,
          'talentos': _talentos,
          'eras_restauradas': _erasRestauradas,
        });
      }
      
      // 2. Sincronizar Bibliotecas (Opcional: Eras e Palavras customizadas)
      await fetchErasFromSupabase();
      
      notifyListeners();
    } catch (e) {
      print("Erro ao sincronizar com Supabase: $e");
    }
  }

  Future<void> fetchErasFromSupabase() async {
    try {
      final erasData = await _supabase.from('eras').select('*, palavras(*)');
      if (erasData != null && erasData.isNotEmpty) {
        List<EraLiteraria> remoteEras = [];
        for (var eraMap in erasData) {
          List<PalavraMestra> palavras = (eraMap['palavras'] as List)
              .map((p) => PalavraMestra.fromMap(p))
              .toList();
          remoteEras.add(EraLiteraria.fromMap(eraMap, palavras));
        }
        _eras = remoteEras;
        notifyListeners();
      }
    } catch (e) {
      print("Erro ao buscar eras: $e");
    }
  }

  Future<void> fetchLeaderboard() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('email, nivel, xp')
          .order('nivel', ascending: false)
          .order('xp', ascending: false)
          .limit(10);
      
      _leaderboard = List<Map<String, dynamic>>.from(data);
      notifyListeners();
    } catch (e) {
      print("Erro ao buscar leaderboard: $e");
    }
  }

  // --- LÓGICA LOCAL ---

  Future<void> _loadProgressLocal() async {
    final prefs = await SharedPreferences.getInstance();
    _nivel = prefs.getInt('nivel') ?? 1;
    _xp = prefs.getInt('xp') ?? 0;
    _fragmentos = prefs.getInt('fragmentos') ?? 0;
    _pontosTalento = prefs.getInt('pontosTalento') ?? 0;
    _palavrasDominadas = prefs.getStringList('palavrasDominadas') ?? ["p1"];
    _talentos = prefs.getStringList('talentos') ?? [];
    _erasRestauradas = prefs.getStringList('erasRestauradas') ?? [];
    
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

    // Salvar no Supabase se logado
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _supabase.from('profiles').update({
        'nivel': _nivel,
        'xp': _xp,
        'fragmentos': _fragmentos,
        'pontos_talento': _pontosTalento,
        'palavras_dominadas': _palavrasDominadas,
        'talentos': _talentos,
        'eras_restauradas': _erasRestauradas,
      }).eq('id', user.id).then((_) => fetchLeaderboard());
    }
  }

  // --- MÉTODOS DE JOGO ---

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

  // --- MÉTODOS ADMIN (COM SUPABASE SYNC) ---

  Future<void> adicionarPalavra(String eraId, PalavraMestra novaPalavra) async {
    int eraIndex = _eras.indexWhere((e) => e.id == eraId);
    if (eraIndex != -1) {
      // Update local
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
      
      // Update Nuvem
      try {
        await _supabase.from('palavras').insert({
          ...novaPalavra.toMap(),
          'era_id': eraId,
        });
      } catch (e) { print("Erro ao salvar palavra na nuvem: $e"); }
      
      notifyListeners();
    }
  }

  Future<void> reordenarPalavras(String eraId, int oldIndex, int newIndex) async {
    // Implementação simplificada: no Supabase você precisaria de um campo 'ordem'
    // Aqui reordenamos localmente e o Admin precisaria salvar a estrutura
    int eraIndex = _eras.indexWhere((e) => e.id == eraId);
    if (eraIndex != -1) {
      final eraAntiga = _eras[eraIndex];
      final novasPalavras = List<PalavraMestra>.from(eraAntiga.palavras);
      if (newIndex > oldIndex) newIndex -= 1;
      final item = novasPalavras.removeAt(oldIndex);
      novasPalavras.insert(newIndex, item);

      _eras[eraIndex] = EraLiteraria(
        id: eraAntiga.id,
        nome: eraAntiga.nome,
        descricao: eraAntiga.descricao,
        corTema: eraAntiga.corTema,
        avatarSeed: eraAntiga.avatarSeed,
        iconeArtefato: eraAntiga.iconeArtefato,
        nomeArtefato: eraAntiga.nomeArtefato,
        palavras: novasPalavras,
      );
      notifyListeners();
    }
  }
  
  // ... outros métodos simplificados para brevidade
}
