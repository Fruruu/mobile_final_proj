import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class PaperPainter extends CustomPainter {
  final bool showLines;
  final bool showFold;
  final Color paperColor;
  final Color lineColor;
  final Color shadowColor;

  PaperPainter({
    this.showLines = true,
    this.showFold = true,
    this.paperColor = const Color(0xFFFFFBF5),
    this.lineColor = const Color(0xFFE8DCCA),
    this.shadowColor = const Color(0xFF4A4A4A),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 1. Base paper color with subtle grain gradient
    final grainShader = LinearGradient(
      colors: [
        paperColor,
        paperColor.withOpacity(0.98),
        paperColor,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    paint.shader = grainShader;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(24),
      ),
      paint,
    );

    // 2. Irregular border (hand-torn effect)
    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(24),
    ));
    paint
      ..shader = null
      ..color = const Color(0xFFE8E3DC).withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);

    // 3. Faint horizontal lines for notebook paper
    if (showLines) {
      paint
        ..color = lineColor.withOpacity(0.4)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      final lineSpacing = size.height / 30; // ~30 lines max
      for (double y = 40; y < size.height - 40; y += lineSpacing) {
        canvas.drawLine(Offset(24, y), Offset(size.width - 24, y), paint);
      }
    }

    // 4. Folded bottom-right corner
    if (showFold) {
      // Fold shadow triangle
      final foldPath = Path()
        ..moveTo(size.width - 20, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - 20)
        ..close();
      final foldGradient = RadialGradient(
        colors: [
          shadowColor.withOpacity(0.15),
          Colors.transparent,
        ],
      );
      paint
        ..shader = foldGradient.createShader(foldPath.getBounds())
        ..style = PaintingStyle.fill;
      canvas.drawPath(foldPath, paint);

      // Fold crease line
      paint
        ..shader = null
        ..color = shadowColor.withOpacity(0.1)
        ..strokeWidth = 0.8;
      canvas.drawLine(
        Offset(size.width - 25, size.height - 25),
        Offset(size.width - 5, size.height - 5),
        paint,
      );
    }

    // 5. Subtle inner highlight and drop shadow overlay
    final highlightGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        paperColor.withOpacity(1.02),
        paperColor,
        paperColor.withOpacity(0.98),
      ],
    );
    paint
      ..shader = highlightGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(24),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

