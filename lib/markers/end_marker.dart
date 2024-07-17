import 'package:flutter/material.dart';

class EndMarkerPainter extends CustomPainter {
  final int kilometers;
  final String destination;

  EndMarkerPainter({required this.kilometers, required this.destination});

  @override
  void paint(Canvas canvas, Size size) {
    final blackPaint = Paint()..color = Colors.black;

    final whitePaint = Paint()..color = Colors.white;

    const double circleBlackRadius = 20;
    const double circleWhiteRadius = 7;

    // Circulo Negro
    canvas.drawCircle(Offset(size.width * 0.5, size.height - circleBlackRadius),
        circleBlackRadius, blackPaint);

    // Circulo Blanco
    canvas.drawCircle(Offset(size.width * 0.5, size.height - circleBlackRadius),
        circleWhiteRadius, whitePaint);

    // Dibujar caja blanca
    final path = Path();
    path.moveTo(40, 20);
    path.lineTo(size.width - 10, 20);
    path.lineTo(size.width - 10, 120);
    path.lineTo(40, 120);

    // Sombra
    canvas.drawShadow(path, Colors.black, 10, false);

    // Caja
    canvas.drawPath(path, whitePaint);

    // Caja Negra
    const blackBox = Rect.fromLTWH(10, 20, 70, 100);
    canvas.drawRect(blackBox, blackPaint);

    // Textos
    // Kilometers
    final textSpan = TextSpan(
        style: const TextStyle(
            color: Colors.white,
            fontSize: 50,
            fontWeight: FontWeight.w600), // Aumentar el tamaño de fuente
        text: '$kilometers');

    final kilometersPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center)
      ..layout(minWidth: 70, maxWidth: 70);

    kilometersPainter.paint(
        canvas, const Offset(10, 45)); // Ajustar la posición vertical

    final locationText = TextSpan(
        style: const TextStyle(
            color: Colors.black, fontSize: 30, fontWeight: FontWeight.w300),
        text: destination);

    final locationPainter = TextPainter(
        maxLines: 2,
        ellipsis: '...',
        text: locationText,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left)
      ..layout(minWidth: size.width - 95, maxWidth: size.width - 95);

    final double offsetY = (destination.length > 25) ? 35 : 48;

    locationPainter.paint(canvas, Offset(90, offsetY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;
}
