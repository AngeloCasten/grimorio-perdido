import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../services/auth_service.dart';
import '../providers/game_provider.dart';
import '../widgets/grimorio_widgets.dart';
import 'tela_login.dart';
import 'tela_admin.dart';
import 'tela_gestao_grimorio.dart';
import 'tela_selecao_era.dart';
import 'tela_tutorial.dart';
import 'tela_grimorio.dart';

class TelaMenuPrincipal extends StatefulWidget {
  const TelaMenuPrincipal({super.key});

  @override
  State<TelaMenuPrincipal> createState() => _TelaMenuPrincipalState();
}

class _TelaMenuPrincipalState extends State<TelaMenuPrincipal> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _GalaxiaLetrasPainter(_bgController.value),
                );
              },
            ),
          ),
          
          // Botão de Login/Logout no topo
          Positioned(
            top: 40,
            right: 20,
            child: auth.isLoggedIn 
              ? IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFFD4AF37)),
                  onPressed: () => auth.logout(),
                )
              : IconButton(
                  icon: const Icon(Icons.person_outline, color: Color(0xFFD4AF37)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaLogin())),
                ),
          ),
          
          // Botão Admin (Se for admin)
          if (auth.isAdmin)
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.admin_panel_settings, color: Colors.redAccent),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaGestaoGrimorio())),
              ),
            ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_stories, size: 80, color: Color(0xFFD4AF37)),
                  const SizedBox(height: 20),
                  const Text(
                    "O GRIMÓRIO\nPERDIDO",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Color(0xFFD4AF37),
                      shadows: [Shadow(color: Colors.black, blurRadius: 10, offset: Offset(2, 2))]
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Restaure o conhecimento das eras esquecidas.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 60),
                  BotaoMagico(
                    texto: "INICIAR JORNADA",
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaSelecaoEra()));
                    },
                  ),
                  const SizedBox(height: 15),
                  BotaoMagico(
                    texto: "COMO JOGAR",
                    cor: Colors.white,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaTutorial()));
                    },
                  ),
                  const SizedBox(height: 15),
                  BotaoMagico(
                    texto: "MEU GRIMÓRIO",
                    cor: Colors.blueGrey,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TelaGrimorio()));
                    },
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person, color: Colors.white38, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          auth.isLoggedIn ? "${auth.userEmail!.split('@')[0]} - Nvl ${game.nivel}" : "Viajante - Nvl ${game.nivel}",
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _GalaxiaLetrasPainter extends CustomPainter {
  final double animationValue;
  _GalaxiaLetrasPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      double y = (random.nextDouble() * size.height + (animationValue * 100)) % size.height;
      final textSpan = TextSpan(
        text: String.fromCharCode(65 + random.nextInt(26)),
        style: TextStyle(
          color: const Color(0xFFD4AF37).withOpacity(0.1 + (random.nextDouble() * 0.2)),
          fontSize: 10 + random.nextDouble() * 20,
          fontFamily: 'serif'
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
