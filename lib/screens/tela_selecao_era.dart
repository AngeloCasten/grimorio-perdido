import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../data/game_data.dart';
import '../widgets/grimorio_widgets.dart';
import 'tela_imersao.dart';

class TelaSelecaoEra extends StatefulWidget {
  const TelaSelecaoEra({super.key});

  @override
  State<TelaSelecaoEra> createState() => _TelaSelecaoEraState();
}

class _TelaSelecaoEraState extends State<TelaSelecaoEra> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPage = _pageController.page!;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final eras = game.eras;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("LINHA DO TEMPO", style: TextStyle(color: Color(0xFFD4AF37), letterSpacing: 2)),
        centerTitle: true,
      ),
      body: GrimorioBackground(
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _LinhaTempoPainter())),
            Center(
              child: SizedBox(
                height: 500,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: eras.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    double relativePosition = index - _currentPage;
                    double scale = (1 - (relativePosition.abs() * 0.2)).clamp(0.8, 1.0);
                    double opacity = (1 - (relativePosition.abs() * 0.5)).clamp(0.3, 1.0);
                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: _CardEra(era: eras[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardEra extends StatelessWidget {
  final EraLiteraria era;
  const _CardEra({required this.era});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    double progressoReal = 0.0;
    int total = era.palavras.length;
    int dominadas = era.palavras.where((p) => game.palavrasDominadas.contains(p.id)).length;
    if (total > 0) progressoReal = dominadas / total;


    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: era.corTema.withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: era.corTema.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      era.corTema.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: "hero_icon_${era.id}",
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black38,
                        border: Border.all(color: era.corTema),
                      ),
                      child: Icon(era.iconeArtefato, size: 50, color: era.corTema),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    era.nome,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: era.corTema,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    era.descricao,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, height: 1.5),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: progressoReal,
                          backgroundColor: Colors.black,
                          color: era.corTema,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "$dominadas / $total Restauradas",
                            style: const TextStyle(color: Colors.white38, fontSize: 10),
                          ),
                          if (progressoReal == 1.0) const Icon(Icons.star, color: Colors.amber, size: 14),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  BotaoMagico(
                    texto: "ABRIR CAPÍTULO",
                    cor: era.corTema,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TelaImersao(era: era)));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinhaTempoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height * 0.5);
    for (double i = 0; i < size.width; i++) {
      path.lineTo(i, size.height * 0.5 + sin(i * 0.02) * 50);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
