import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../data/game_data.dart';
import '../widgets/grimorio_widgets.dart';

class TelaGrimorio extends StatefulWidget {
  const TelaGrimorio({super.key});

  @override
  State<TelaGrimorio> createState() => _TelaGrimorioState();
}

class _TelaGrimorioState extends State<TelaGrimorio> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _verificarDesbloqueioEra(EraLiteraria era) {
    bool todasDominadas = era.palavras.every((p) => PlayerProgress.palavrasDominadas.contains(p.id));
    if (todasDominadas && !PlayerProgress.erasRestauradas.contains(era.id)) {
      if (mounted) {
        setState(() {
          PlayerProgress.erasRestauradas.add(era.id);
        });
      }
      _mostrarReliquiaRestaurada(era);
    }
  }

  void _mostrarReliquiaRestaurada(EraLiteraria era) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101010),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: era.corTema, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("RELIQUIA RESTAURADA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 10)),
            const SizedBox(height: 20),
            Icon(era.iconeArtefato, size: 80, color: era.corTema),
            const SizedBox(height: 20),
            Text(era.nomeArtefato.toUpperCase(), style: TextStyle(color: era.corTema, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("O conhecimento foi totalmente recuperado!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("GUARDAR", style: TextStyle(color: era.corTema)))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("MEU GRIMÓRIO", style: TextStyle(color: Color(0xFFD4AF37))),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4AF37),
          tabs: const [
            Tab(text: "LÉXICO"),
            Tab(text: "RELICÁRIO"),
            Tab(text: "TALENTOS"),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildHeaderStatus(game),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAbaLexico(game),
                _buildAbaRelicario(game),
                _buildAbaTalentos(game),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatus(GameProvider game) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("NÍVEL ${game.nivel}", style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
              Text("${game.xp}/100 XP", style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: game.xp / 100,
            backgroundColor: Colors.white10,
            color: const Color(0xFFD4AF37),
          ),
        ],
      ),
    );
  }

  Widget _buildAbaLexico(GameProvider game) {
    final eras = game.eras;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("COMPLETE AS ERAS PARA RECOLHER OS ARTEFATOS", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 20),
        ...eras.map((era) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(era.nome.toUpperCase(), style: TextStyle(color: era.corTema, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              ...era.palavras.map((palavra) {
                final bool dominada = game.palavrasDominadas.contains(palavra.id);
                return Card(
                  color: dominada ? const Color(0xFF111111) : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: dominada ? era.corTema.withOpacity(0.3) : Colors.white10),
                  ),
                  child: ListTile(
                    leading: Icon(dominada ? Icons.auto_stories : Icons.lock_outline, color: dominada ? era.corTema : Colors.white12),
                    title: Text(dominada ? palavra.termoPrincipal : "???????", style: TextStyle(color: dominada ? Colors.white : Colors.white12)),
                    onTap: dominada ? () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF151515),
                          title: Text(palavra.termoPrincipal, style: TextStyle(color: era.corTema)),
                          content: Text(palavra.definicao, style: const TextStyle(color: Colors.white70)),
                          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("FECHAR"))],
                        ),
                      );
                    } : null,
                  ),
                );
              }).toList(),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAbaRelicario(GameProvider game) {
    final eras = game.eras;
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: eras.length,
      itemBuilder: (context, index) {
        final era = eras[index];
        final bool desbloqueada = game.erasRestauradas.contains(era.id);
        return TweenAnimationBuilder(
          duration: const Duration(seconds: 2),
          tween: Tween<double>(begin: 0.8, end: 1.0),
          curve: Curves.easeInOutSine,
          builder: (context, double valor, child) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: desbloqueada ? era.corTema.withOpacity(valor) : Colors.white10, width: desbloqueada ? 2 : 1),
                boxShadow: desbloqueada ? [BoxShadow(color: era.corTema.withOpacity(0.2 * valor), blurRadius: 10, spreadRadius: 1)] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(era.iconeArtefato, size: 50, color: desbloqueada ? era.corTema : Colors.white10),
                  const SizedBox(height: 15),
                  Text(desbloqueada ? era.nomeArtefato : "BLOQUEADO", textAlign: TextAlign.center, style: TextStyle(color: desbloqueada ? Colors.white : Colors.white24, fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAbaTalentos(GameProvider game) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFD4AF37))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("PONTOS DISPONÍVEIS:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              CircleAvatar(backgroundColor: const Color(0xFFD4AF37), radius: 15, child: Text("${game.pontosTalento}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...arvoreDeTalentos.map((talento) {
          bool jaTem = game.talentos.contains(talento.id);
          bool podeComprar = game.pontosTalento >= talento.custo;
          return Card(
            color: jaTem ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.white.withOpacity(0.05),
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(talento.icone, color: jaTem ? const Color(0xFFD4AF37) : Colors.white24),
              title: Text(talento.nome, style: TextStyle(color: jaTem ? const Color(0xFFD4AF37) : Colors.white)),
              subtitle: Text(talento.descricao, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              trailing: jaTem
                ? const Icon(Icons.check_circle, color: Color(0xFFD4AF37))
                : ElevatedButton(
                    onPressed: podeComprar ? () {
                      game.comprarTalento(talento);
                    } : null,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                    child: const Text("ADQUIRIR", style: TextStyle(color: Colors.black, fontSize: 10)),
                  ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
