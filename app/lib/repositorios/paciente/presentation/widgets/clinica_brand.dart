import 'package:flutter/material.dart';

class ClinicaBrand extends StatelessWidget {
  const ClinicaBrand({super.key, required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Clínica Vida & Saúde. Cuidando de você sempre.',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomPaint(size: Size(52, 65), painter: _RamoPainter()),
            const SizedBox(height: 10),
            Text(
              'Clínica Vida & Saúde',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'ClinicaSerif',
                fontSize: compact ? 28 : 38,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFE1E9DB),
                shadows: const [Shadow(blurRadius: 20, color: Colors.black45)],
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'CUIDANDO DE VOCÊ SEMPRE',
              style: TextStyle(
                fontSize: compact ? 9 : 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: const Color(0xFFC4D4C3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RamoPainter extends CustomPainter {
  const _RamoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDCE7D6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(23, 63)
      ..cubicTo(21, 43, 27, 24, 38, 5)
      ..moveTo(26, 42)
      ..quadraticBezierTo(7, 34, 10, 16)
      ..quadraticBezierTo(25, 23, 26, 42)
      ..moveTo(30, 29)
      ..quadraticBezierTo(29, 9, 44, 2)
      ..quadraticBezierTo(44, 20, 30, 29)
      ..moveTo(23, 53)
      ..quadraticBezierTo(29, 33, 47, 32)
      ..quadraticBezierTo(41, 47, 23, 53);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RamoPainter oldDelegate) => false;
}
