import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

class ProductivityMeter extends StatelessWidget {
  final double percentage;

  const ProductivityMeter({super.key, required this.percentage});

  Color _getColorForPercentage() {
    if (percentage >= 80) return CupertinoColors.systemGreen;
    if (percentage >= 50) return CupertinoColors.systemOrange;
    return CupertinoColors.systemRed;
  }

  String _getMessageForPercentage() {
    if (percentage >= 80) return 'Ajoyib!';
    if (percentage >= 50) return 'Yaxshi!';
    if (percentage > 0) return 'Davom eting!';
    return 'Boshlang!';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForPercentage();
    final message = _getMessageForPercentage();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Samaradorlik',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: _CircularProgressPainter(
                percentage: percentage,
                color: color,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: const TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildProgressBar(color),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress',
              style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 14),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (percentage / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double percentage;
  final Color color;

  _CircularProgressPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = const Color(0xFF2C2C2C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius - 6, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.6)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
