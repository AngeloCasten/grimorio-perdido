import 'package:flutter/material.dart';
import '../widgets/grimorio_widgets.dart';

class TelaTutorial extends StatefulWidget {
  const TelaTutorial({super.key});

  @override
  State<TelaTutorial> createState() => _TelaTutorialState();
}

class _TelaTutorialState extends State<TelaTutorial> {
  final PageController _controller = PageController();
  int _paginaAtual = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      "titulo": "VIAJE NO TEMPO",
      "texto": "Navegue pelas Eras Literárias Brasileiras. Do descobrimento ao modernismo, recupere palavras perdidas.",
      "icone": Icons.access_time_filled,
      "cor": Colors.blueAccent
    },
    {
      "titulo": "DESAFIOS",
      "texto": "Cada palavra tem 4 fases: Revelação (Aprender), Quiz (Testar), Lacuna (Completar) e Forja (Criar).",
      "icone": Icons.psychology,
      "cor": Colors.purpleAccent
    },
    {
      "titulo": "COMBO MÍSTICO",
      "texto": "Acerte seguidamente para acender a Chama do Conhecimento. Erros quebram o combo e o bônus de XP!",
      "icone": Icons.whatshot,
      "cor": Colors.orangeAccent
    },
    {
      "titulo": "SEU GRIMÓRIO",
      "texto": "Colecione palavras no Léxico e desbloqueie Artefatos Raros completando as Eras.",
      "icone": Icons.auto_stories,
      "cor": Color(0xFFD4AF37)
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GrimorioBackground(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              onPageChanged: (idx) {
                if (mounted) {
                  setState(() => _paginaAtual = idx);
                }
              },
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: slide["cor"].withOpacity(0.1),
                          border: Border.all(color: slide["cor"], width: 2),
                          boxShadow: [BoxShadow(color: slide["cor"].withOpacity(0.4), blurRadius: 30)]
                        ),
                        child: Icon(slide["icone"], size: 80, color: slide["cor"]),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        slide["titulo"],
                        style: TextStyle(
                          color: slide["cor"],
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFamily: 'Georgia'
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        slide["texto"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              bottom: 150,
              left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: _paginaAtual == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _paginaAtual == index ? const Color(0xFFD4AF37) : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 30, right: 30,
              child: BotaoMagico(
                texto: _paginaAtual == _slides.length - 1 ? "COMEÇAR AVENTURA" : "PRÓXIMO",
                cor: const Color(0xFFD4AF37),
                onPressed: () {
                  if (_paginaAtual < _slides.length - 1) {
                    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
