import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/grimorio_widgets.dart';

class TelaLeaderboard extends StatelessWidget {
  const TelaLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final leaderboard = game.leaderboard;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: const Text("RANKING DOS GUARDIÕES", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, const Color(0xFF1A1A1A).withOpacity(0.8)],
          ),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Icon(Icons.emoji_events, color: Color(0xFFD4AF37), size: 50),
            ),
            Expanded(
              child: leaderboard.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: leaderboard.length,
                    itemBuilder: (context, index) {
                      final player = leaderboard[index];
                      final isTop3 = index < 3;
                      return _buildPlayerTile(player, index + 1, isTop3);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerTile(Map<String, dynamic> player, int rank, bool isTop3) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isTop3 ? const Color(0xFFD4AF37).withOpacity(0.1) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isTop3 ? const Color(0xFFD4AF37).withOpacity(0.3) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              "#$rank",
              style: TextStyle(
                color: isTop3 ? const Color(0xFFD4AF37) : Colors.white38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          const CircleAvatar(
            backgroundColor: Colors.white10,
            radius: 20,
            child: Icon(Icons.person, color: Colors.white24, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['email'].toString().split('@')[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  "ILUMINAÇÃO NÍVEL ${player['nivel']}",
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${player['xp']} XP",
                style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 12),
            ],
          ),
        ],
      ),
    );
  }
}
