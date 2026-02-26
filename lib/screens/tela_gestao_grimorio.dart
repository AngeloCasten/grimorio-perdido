import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../widgets/grimorio_widgets.dart';
import 'tela_admin.dart';

class TelaGestaoGrimorio extends StatefulWidget {
  const TelaGestaoGrimorio({super.key});

  @override
  State<TelaGestaoGrimorio> createState() => _TelaGestaoGrimorioState();
}

class _TelaGestaoGrimorioState extends State<TelaGestaoGrimorio> {
  String? _selectedEraId;

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final eras = game.eras;

    return Scaffold(
      appBar: AppBar(
        title: const Text("GESTÃO DO GRIMÓRIO", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          _buildEraSelector(eras),
          const Divider(color: Colors.white10),
          Expanded(
            child: _selectedEraId == null
                ? const Center(child: Text("Selecione uma Era para gerenciar", style: TextStyle(color: Colors.white38)))
                : _buildWordList(game),
          ),
        ],
      ),
      floatingActionButton: _selectedEraId != null
          ? FloatingActionButton(
              backgroundColor: Colors.redAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelaAdmin(initialEraId: _selectedEraId),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEraSelector(List<EraLiteraria> eras) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: eras.length,
        itemBuilder: (context, index) {
          final era = eras[index];
          final isSelected = _selectedEraId == era.id;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(era.nome),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedEraId = selected ? era.id : null;
                });
              },
              selectedColor: Colors.redAccent.withOpacity(0.3),
              backgroundColor: Colors.white05,
              labelStyle: TextStyle(color: isSelected ? Colors.redAccent : Colors.white38, fontSize: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWordList(GameProvider game) {
    final era = game.eras.firstWhere((e) => e.id == _selectedEraId);
    final palavras = era.palavras;

    if (palavras.isEmpty) {
      return const Center(child: Text("Nenhuma palavra nesta era.", style: TextStyle(color: Colors.white24)));
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: palavras.length,
      onReorder: (oldIndex, newIndex) {
        game.reordenarPalavras(era.id, oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final palavra = palavras[index];
        return Card(
          key: ValueKey(palavra.id),
          color: Colors.white.withOpacity(0.05),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.drag_indicator, color: Colors.white24),
            title: Text(palavra.termoPrincipal, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text("${palavra.classeGramatical} • ${palavra.xpValor} XP", style: const TextStyle(color: Colors.white38, fontSize: 11)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TelaAdmin(
                          palavraParaEditar: palavra,
                          initialEraId: era.id,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                  onPressed: () => _confirmarExclusao(context, game, era.id, palavra),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmarExclusao(BuildContext context, GameProvider game, String eraId, PalavraMestra palavra) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151515),
        title: const Text("Excluir Sabedoria?", style: TextStyle(color: Colors.redAccent)),
        content: Text("Tem certeza que deseja apagar '${palavra.termoPrincipal}' do Grimório?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR")),
          TextButton(
            onPressed: () {
              game.removerPalavra(eraId, palavra.id);
              Navigator.pop(ctx);
            },
            child: const Text("EXCLUIR", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
