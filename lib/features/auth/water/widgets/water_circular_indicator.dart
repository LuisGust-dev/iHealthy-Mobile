import 'package:flutter/material.dart';
import 'dart:math';

class WaterCircularIndicator extends StatelessWidget {
  final int totalMl;
  final int goalMl;

  const WaterCircularIndicator({
    super.key,
    required this.totalMl,
    required this.goalMl,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = (totalMl / goalMl).clamp(0, 1);
    final int percentText = (percent * 100).toInt();

    return Column(
      children: [
        const SizedBox(height: 10),

        // Título igual ao Figma
        const Text(
          "Hidratação 💧",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Mantenha-se hidratado ao longo do dia",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontStyle: FontStyle.italic,
          ),
        ),

        const SizedBox(height: 20),

        // CÍRCULO
        SizedBox(
          height: 180,
          width: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // BACKGROUND (cinza)
              SizedBox(
                height: 180,
                width: 180,
                child: CustomPaint(
                  painter: _CirclePainter(
                    percent: 1,
                    color: Colors.grey.shade300,
                    strokeWidth: 14,
                  ),
                ),
              ),

              // PROGRESSO (azul)
              SizedBox(
                height: 180,
                width: 180,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: percent),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return CustomPaint(
                      painter: _CirclePainter(
                        percent: value,
                        color: Colors.blueAccent,
                        strokeWidth: 14,
                      ),
                    );
                  },
                ),
              ),

              // TEXTO CENTRAL
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$percentText%",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$totalMl ml de $goalMl ml",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double percent;
  final Color color;
  final double strokeWidth;

  _CirclePainter({required this.percent, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * percent,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) =>
      oldDelegate.percent != percent;
}
