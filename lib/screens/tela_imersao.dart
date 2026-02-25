import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../widgets/grimorio_widgets.dart';

class TelaImersao extends StatefulWidget {
  final EraLiteraria era;
  const TelaImersao({super.key, required this.era});

  @override
  State<TelaImersao> createState() => _TelaImersaoState();
}

enum EstagioGameplay { revelacao, quiz, lacuna, forja }

class _TelaImersaoState extends State<TelaImersao> with TickerProviderStateMixin {
  int _indicePalavra = 0;
  EstagioGameplay _estagio = EstagioGameplay.revelacao;
  final TextEditingController _inputController = TextEditingController();
  String? _feedbackMensagem;
  bool _feedbackPositivo = true;
  bool _mostrarBotaoAvancar = false;
  int _comboStreak = 0;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  final List<_Particula> _particulas = [];
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _shakeAnimation = Tween<double>(begin: 0, end: 10).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _shakeController.reset();
      });

    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _particleController.addListener(() {
      if (mounted) {
        setState(() {
          for (var p in _particulas) { p.update(); }
          _particulas.removeWhere((p) => p.vida <= 0);
          if (_particulas.isEmpty) _particleController.stop();
        });
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _particleController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  PalavraMestra get _palavraAtual => widget.era.palavras[_indicePalavra];

  void _spawnParticulas() {
    for (int i = 0; i < 30; i++) {
      _particulas.add(_Particula(cor: widget.era.corTema));
    }
    if (!_particleController.isAnimating) {
      _particleController.repeat();
    }
  }

  void _validarResposta(bool acertou, String mensagemSucesso, String mensagemErro) {
    if (mounted) {
      final game = Provider.of<GameProvider>(context, listen: false);
      setState(() {
        if (acertou) {
          _feedbackPositivo = true;
          _comboStreak++;
          int bonusCombo = (_comboStreak > 1) ? _comboStreak * 5 : 0;
          int xpGanho = 10 + bonusCombo;
          game.ganharXP(xpGanho); // Usando o Provider agora
          _feedbackMensagem = _comboStreak > 1 ? "$mensagemSucesso (COMBO x$_comboStreak! +$xpGanho XP)" : mensagemSucesso;
          _mostrarBotaoAvancar = true;
          _spawnParticulas();
        } else {
          _feedbackPositivo = false;
          _comboStreak = 0;
          _feedbackMensagem = "O combo foi quebrado... $mensagemErro";
          _shakeController.forward();
        }
      });
    }
  }

  void _avancarEstagio() {
    if (mounted) {
      final game = Provider.of<GameProvider>(context, listen: false);
      setState(() {
        _feedbackMensagem = null;
        _mostrarBotaoAvancar = false;
        _inputController.clear();
        if (_estagio == EstagioGameplay.revelacao) {
          _estagio = EstagioGameplay.quiz;
        } else if (_estagio == EstagioGameplay.quiz) {
          _estagio = EstagioGameplay.lacuna;
        } else if (_estagio == EstagioGameplay.lacuna) {
          _estagio = EstagioGameplay.forja;
        } else if (_estagio == EstagioGameplay.forja) {
          game.dominarPalavra(_palavraAtual.id, 200);
          if (_indicePalavra < widget.era.palavras.length - 1) {
            _indicePalavra++;
            _estagio = EstagioGameplay.revelacao;
          } else {
            game.restaurarEra(widget.era.id);
            _mostrarFimEra();
          }
        }
      });
    }
  }

  void _mostrarFimEra() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101010),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: widget.era.corTema)),
        title: Column(
          children: [
            Icon(Icons.emoji_events, size: 50, color: widget.era.corTema),
            const SizedBox(height: 10),
            Text("ERA DOMINADA!", style: TextStyle(color: widget.era.corTema, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Você absorveu todo o conhecimento desta Era.\nSeu Grimório está mais poderoso.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          Center(
            child: BotaoMagico(
              texto: "RECEBER GLÓRIA",
              cor: widget.era.corTema,
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
            ),
          )
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: widget.era.corTema),
        title: Hero(
          tag: "hero_icon_${widget.era.id}",
          child: Material(
            color: Colors.transparent,
            child: Icon(widget.era.iconeArtefato, size: 30, color: widget.era.corTema),
          ),
        ),
        centerTitle: true,
        actions: [
          if (_comboStreak > 1)
            Container(
              margin: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orangeAccent),
                boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.whatshot, color: Colors.orangeAccent, size: 20),
                  const SizedBox(width: 5),
                  Text("x$_comboStreak", style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text("Nvl ${game.nivel}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),

      body: GrimorioBackground(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value * sin(_shakeController.value * 20), 0),
                  child: child,
                );
              },
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (_estagio.index + 1) / 4,
                    backgroundColor: Colors.white10,
                    color: widget.era.corTema,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildMentorArea(),
                          const SizedBox(height: 20),
                          _buildConteudoDinamico(),
                          const SizedBox(height: 20),
                          if (_feedbackMensagem != null)
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: _feedbackPositivo ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                border: Border.all(color: _feedbackPositivo ? Colors.green : Colors.red),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(children: [
                                Icon(_feedbackPositivo ? Icons.check_circle : Icons.error, color: _feedbackPositivo ? Colors.green : Colors.red),
                                const SizedBox(width: 10),
                                Expanded(child: Text(_feedbackMensagem!, style: const TextStyle(color: Colors.white))),
                              ]),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_mostrarBotaoAvancar)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: BotaoMagico(texto: "CONTINUAR", cor: widget.era.corTema, onPressed: _avancarEstagio),
                    ),
                ],
              ),
            ),
            IgnorePointer(
              child: CustomPaint(
                painter: _ParticlePainter(_particulas),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMentorArea() {
    String fala = "";
    switch (_estagio) {
      case EstagioGameplay.revelacao: fala = "O conhecimento é a luz da alma. Observe:"; break;
      case EstagioGameplay.quiz: fala = "Sua mente está afiada? Prove."; break;
      case EstagioGameplay.lacuna: fala = "A história deixou rastros. Complete-os."; break;
      case EstagioGameplay.forja: fala = "A pena agora é sua. Escreva o futuro."; break;
    }
    return Row(children: [
      AvatarSeguro(seed: widget.era.avatarSeed, radius: 25),
      const SizedBox(width: 15),
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
          child: Text(fala, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 13)),
        ),
      ),
    ]);
  }

  Widget _buildConteudoDinamico() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.era.corTema.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: widget.era.corTema.withOpacity(0.15), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Text(_palavraAtual.termoPrincipal, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: widget.era.corTema, fontFamily: 'Georgia', letterSpacing: 3)),
          Text(_palavraAtual.classeGramatical, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Divider(color: Colors.white10, height: 30),
          if (_estagio == EstagioGameplay.revelacao)
            Column(children: [
              Text(_palavraAtual.definicao, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.5, color: Colors.white)),
              const SizedBox(height: 20),
              Text("Origem: ${_palavraAtual.etimologia}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 20),
              if(!_mostrarBotaoAvancar) BotaoMagico(texto: "COMPREENDI", cor: widget.era.corTema, onPressed: () => setState(() => _mostrarBotaoAvancar = true))
            ]),
          if (_estagio == EstagioGameplay.quiz)
            Column(children: [
              Text(_palavraAtual.perguntaQuiz, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              if (!_mostrarBotaoAvancar) ..._palavraAtual.opcoesQuiz.asMap().entries.map((e)
                => Padding(padding: const EdgeInsets.only(bottom: 10), child: BotaoMagico(texto: e.value, cor: Colors.white, onPressed: () => _validarResposta(e.key == _palavraAtual.indexCorretoQuiz, "Correto!", _palavraAtual.explicacaoErro)))),
            ]),
          if (_estagio == EstagioGameplay.lacuna)
            Column(children: [
              Text.rich(TextSpan(children: [
                TextSpan(text: _palavraAtual.fraseLacuna.split("___")[0], style: const TextStyle(fontSize: 18, color: Colors.white70)),
                const TextSpan(text: " [ ? ] ", style: TextStyle(fontSize: 18, color: Colors.amber, fontWeight: FontWeight.bold)),
                if(_palavraAtual.fraseLacuna.split("___").length > 1) TextSpan(text: _palavraAtual.fraseLacuna.split("___")[1], style: const TextStyle(fontSize: 18, color: Colors.white70)),
              ]), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text("- ${_palavraAtual.autorCitacao}", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
              const SizedBox(height: 20),
              if(!_mostrarBotaoAvancar) TextField(
                controller: _inputController, 
                style: const TextStyle(color: Colors.white), 
                decoration: InputDecoration(
                  filled: true, 
                  fillColor: Colors.black54, 
                  suffixIcon: IconButton(icon: const Icon(Icons.send, color: Colors.amber), 
                  onPressed: () {
                    bool acertou = _inputController.text.toLowerCase().trim() == _palavraAtual.termoPrincipal.toLowerCase() || _palavraAtual.aceitasFlexoes.contains(_inputController.text.toLowerCase().trim());
                    _validarResposta(acertou, "A lacuna foi preenchida.", "Tente novamente.");
                  })
                )
              ),
            ]),
          if (_estagio == EstagioGameplay.forja)
            Column(children: [
              Text(_palavraAtual.desafioCriativo, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              if(!_mostrarBotaoAvancar) Column(children: [
                TextField(controller: _inputController, maxLines: 2, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(filled: true, fillColor: Colors.black54, hintText: "Escreva aqui...")),
                const SizedBox(height: 10),
                BotaoMagico(texto: "CONSAGRAR", cor: widget.era.corTema, onPressed: () => _validarResposta(true, "Excelente criação.", ""))
              ])
            ]),
        ],
      ),
    );
  }
}

class _Particula {
  double x = Random().nextDouble() * 400; 
  double y = Random().nextDouble() * 400 + 100;
  double vx = (Random().nextDouble() - 0.5) * 5;
  double vy = (Random().nextDouble() - 1.0) * 10;
  double vida = 1.0;
  Color cor;
  _Particula({required this.cor});
  void update() {
    x += vx;
    y += vy;
    vy += 0.5;
    vida -= 0.02;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particula> particulas;
  _ParticlePainter(this.particulas);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particulas) {
      final paint = Paint()..color = p.cor.withOpacity(p.vida.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x, p.y), 3 * p.vida, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
