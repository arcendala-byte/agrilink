import 'package:flutter/material.dart';

class PremiumTractorIcon extends StatelessWidget {
  final double size;
  final Color color;
  
  const PremiumTractorIcon({
    super.key, 
    this.size = 50,
    this.color = const Color(0xFF2E7D32),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: PremiumTractorPainter(color: color),
        size: Size(size, size),
      ),
    );
  }
}

class PremiumTractorPainter extends CustomPainter {
  final Color color;
  
  PremiumTractorPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = color;
    
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..isAntiAlias = true
      ..color = color;
    
    // Tractor Body - Main frame
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.45,
        size.width * 0.4,
        size.height * 0.3,
      ),
      Radius.circular(size.width * 0.08),
    );
    canvas.drawRRect(bodyRect, paint);
    
    // Tractor Cabin - Top section
    final cabinRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.45,
        size.height * 0.25,
        size.width * 0.25,
        size.height * 0.25,
      ),
      Radius.circular(size.width * 0.05),
    );
    canvas.drawRRect(cabinRect, paint);
    
    // Cabin Windows
    final windowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.3);
    final windowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.48,
        size.height * 0.3,
        size.width * 0.08,
        size.height * 0.15,
      ),
      Radius.circular(size.width * 0.02),
    );
    canvas.drawRRect(windowRect, windowPaint);
    
    final windowRect2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.58,
        size.height * 0.3,
        size.width * 0.08,
        size.height * 0.15,
      ),
      Radius.circular(size.width * 0.02),
    );
    canvas.drawRRect(windowRect2, windowPaint);
    
    // Exhaust Pipe
    final exhaustPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.8);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.32,
        size.height * 0.2,
        size.width * 0.06,
        size.height * 0.25,
      ),
      exhaustPaint,
    );
    
    // Exhaust Pipe Top
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.2),
      size.width * 0.04,
      exhaustPaint,
    );
    
    // Grille
    final grillePaint = Paint()..style = PaintingStyle.fill..color = color.withOpacity(0.6);
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * 0.28,
          size.height * 0.52 + i * size.height * 0.045,
          size.width * 0.05,
          size.height * 0.02,
        ),
        grillePaint,
      );
    }
    
    // Headlight
    final lightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFD54F);
    canvas.drawCircle(
      Offset(size.width * 0.29, size.height * 0.48),
      size.width * 0.045,
      lightPaint,
    );
    
    // Headlight glow
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFD54F).withOpacity(0.3);
    canvas.drawCircle(
      Offset(size.width * 0.29, size.height * 0.48),
      size.width * 0.07,
      glowPaint,
    );
    
    // Large Rear Wheel
    final wheelPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF555555);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.75),
      size.width * 0.18,
      wheelPaint,
    );
    
    // Rear Wheel Rim
    final rimPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF888888);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.75),
      size.width * 0.08,
      rimPaint,
    );
    
    // Rear Wheel Hub
    final hubPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFAAAAAA);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.75),
      size.width * 0.035,
      hubPaint,
    );
    
    // Rear Wheel Tread
    final treadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025
      ..color = const Color(0xFF333333);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.75), radius: size.width * 0.14),
      0,
      3.14159 * 2,
      false,
      treadPaint,
    );
    
    // Small Front Wheel
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.75),
      size.width * 0.1,
      wheelPaint,
    );
    
    // Front Wheel Rim
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.75),
      size.width * 0.045,
      rimPaint,
    );
    
    // Front Wheel Hub
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.75),
      size.width * 0.02,
      hubPaint,
    );
    
    // Connecting Rod between wheels
    final rodPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.7);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.65,
        size.width * 0.2,
        size.height * 0.03,
      ),
      rodPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
