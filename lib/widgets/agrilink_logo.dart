import 'package:flutter/material.dart';

class AgriLinkLogo extends StatelessWidget {
  final double size;
  
  const AgriLinkLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF43A047),
            Color(0xFF66BB6A),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              color: Colors.white,
              size: size * 0.35,
            ),
            const SizedBox(height: 4),
            Container(
              width: size * 0.5,
              height: 2,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 4),
            Text(
              'AgriLink',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
