import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safe_driver/login.dart'; // Importa sua tela de login real

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Adiciona 'SingleTickerProviderStateMixin' para controle da animação
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // Controlador para a animação
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configura o controlador da animação de fade-in
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Inicia a animação e a navegação
    _startSplash();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Libera os recursos do controlador
    super.dispose();
  }

  void _startSplash() async {
    // Inicia a animação de fade-in
    _animationController.forward();

    // Aguarda 3.5 segundos no total antes de navegar
    await Future.delayed(const Duration(milliseconds: 3500));

    if (mounted) {
      // Usa pushReplacement para que o usuário não possa voltar para a splash screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack( // Usamos Stack para sobrepor a animação e o texto
        children: [
          // ANIMAÇÃO DAS LINHAS DA ESTRADA
          const RoadLinesAnimation(),

          // NOME DO APP COM ANIMAÇÃO DE FADE
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'Safe Driver',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: Colors.black87,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// WIDGET SEPARADO PARA A ANIMAÇÃO DA ESTRADA
class RoadLinesAnimation extends StatefulWidget {
  const RoadLinesAnimation({super.key});

  @override
  State<RoadLinesAnimation> createState() => _RoadLinesAnimationState();
}

class _RoadLinesAnimationState extends State<RoadLinesAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(); // Faz a animação repetir em loop

    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: RoadPainter(animationValue: _animation.value),
        );
      },
    );
  }
}

// PINTOR CUSTOMIZADO PARA DESENHAR AS LINHAS
class RoadPainter extends CustomPainter {
  final double animationValue;

  RoadPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final double centerX = size.width / 2;
    final double lineHeight = 40;
    final double gapHeight = 60;
    final double totalPatternHeight = lineHeight + gapHeight;

    // Calcula o deslocamento inicial baseado no valor da animação
    final double startYOffset = (animationValue * totalPatternHeight) % totalPatternHeight;

    // Desenha múltiplas linhas que preenchem a tela
    for (double y = startYOffset - totalPatternHeight; y < size.height; y += totalPatternHeight) {
      canvas.drawLine(
        Offset(centerX, y),
        Offset(centerX, y + lineHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Sempre redesenha para a animação fluir
  }
}