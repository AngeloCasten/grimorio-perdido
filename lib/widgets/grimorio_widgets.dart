import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class GrimorioBackground extends StatelessWidget {
  final Widget child;
  const GrimorioBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F0F0F), // Preto quase total
            Color(0xFF1A1A1A), // Cinza muito escuro
            Color(0xFF050505), // Preto total
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _RuidoPainter(),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class _RuidoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    final paint = Paint()..color = Colors.white.withOpacity(0.03);
    for (int i = 0; i < 100; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BotaoMagico extends StatefulWidget {
  final String texto;
  final VoidCallback onPressed;
  final Color cor;
  final bool bloqueado;

  const BotaoMagico({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cor = const Color(0xFFD4AF37),
    this.bloqueado = false,
  });

  @override
  State<BotaoMagico> createState() => _BotaoMagicoState();
}

class _BotaoMagicoState extends State<BotaoMagico> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => !widget.bloqueado ? _controller.forward() : null,
      onTapUp: (_) {
        if (!widget.bloqueado) {
          _controller.reverse();
          widget.onPressed();
        }
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.bloqueado ? Colors.grey.withOpacity(0.1) : widget.cor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.bloqueado ? Colors.grey.withOpacity(0.3) : widget.cor,
              width: 1.5,
            ),
            boxShadow: widget.bloqueado ? [] : [
              BoxShadow(color: widget.cor.withOpacity(0.2), blurRadius: 10, spreadRadius: 1)
            ],
          ),
          child: Text(
            widget.bloqueado ? "BLOQUEADO" : widget.texto.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.bloqueado ? Colors.white38 : widget.cor,
              fontFamily: 'Georgia',
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class TextoDatilografado extends StatefulWidget {
  final String texto;
  final TextStyle? style;
  final VoidCallback? onFinished;

  const TextoDatilografado(this.texto, {super.key, this.style, this.onFinished});

  @override
  State<TextoDatilografado> createState() => _TextoDatilografadoState();
}

class _TextoDatilografadoState extends State<TextoDatilografado> {
  String _exibido = "";
  int _charIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _iniciarDigitacao();
  }

  @override
  void didUpdateWidget(covariant TextoDatilografado oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.texto != widget.texto) {
      _iniciarDigitacao();
    }
  }

  void _iniciarDigitacao() {
    _exibido = "";
    _charIndex = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_charIndex < widget.texto.length) {
        if (mounted) {
          setState(() {
            _charIndex++;
            _exibido = widget.texto.substring(0, _charIndex);
          });
        }
      } else {
        timer.cancel();
        widget.onFinished?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_exibido, style: widget.style);
  }
}

class AvatarSeguro extends StatelessWidget {
  final String seed;
  final double radius;

  const AvatarSeguro({super.key, required this.seed, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final int hash = seed.codeUnits.fold(0, (p, c) => p + c);
    final color = Colors.primaries[hash % Colors.primaries.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withOpacity(0.2),
      child: Text(
        seed.substring(0, 1).toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: radius),
      ),
    );
  }
}
