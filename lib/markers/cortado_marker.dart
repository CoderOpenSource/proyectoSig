import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMarkerHelper {
  static Future<BitmapDescriptor> createCustomMarkerIcon(
      int index, String text, String cf, String name) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Dimensiones del marcador
    const double width = 350; // Ancho total del marcador
    const double height = 120; // Alto total del marcador

    // Colores para las secciones
    final blackPaint = Paint()
      ..color = Colors.black; // Fondo negro para el número
    final redPaint = Paint()
      ..color = Colors.red; // Fondo rojo para los detalles

    // Dimensiones del fondo negro
    const double blackBoxWidth = 70; // Ancho del fondo negro

    // Dibujar el fondo negro para el número
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTWH(0, 0, blackBoxWidth, height), // Altura igual al marcador
        topLeft: const Radius.circular(10), // Borde superior izquierdo redondeado
        bottomLeft: const Radius.circular(10), // Borde inferior izquierdo redondeado
      ),
      blackPaint,
    );

    // Dibujar el número dentro del fondo negro
    final numberPainter = TextPainter(
      text: TextSpan(
        text: '$index',
        style: const TextStyle(
          fontSize: 40, // Tamaño de fuente para el número
          color: Colors.white, // Color de texto blanco
          fontWeight: FontWeight.bold, // Texto en negrita
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    numberPainter.layout(minWidth: blackBoxWidth, maxWidth: blackBoxWidth);
    numberPainter.paint(
      canvas,
      const Offset(0, (height - 40) / 2), // Centrado vertical y horizontal
    );

    // Dibujar el fondo rojo para "CORTADO" y los detalles
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTWH(
          blackBoxWidth, // Empieza después del fondo negro
          0,
          width - blackBoxWidth, // El resto del ancho es para el fondo rojo
          height, // Altura total
        ),
        topRight: const Radius.circular(10), // Borde superior derecho redondeado
        bottomRight: const Radius.circular(10), // Borde inferior derecho redondeado
      ),
      redPaint,
    );

    // Dibujar texto "CORTADO"
    final cortadoPainter = TextPainter(
      text: const TextSpan(
        text: 'CORTADO',
        style: TextStyle(
          fontSize: 20, // Tamaño de fuente para "CORTADO"
          color: Colors.white, // Color de texto blanco
          fontWeight: FontWeight.bold, // Texto en negrita
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    cortadoPainter.layout();
    cortadoPainter.paint(
      canvas,
      const Offset(blackBoxWidth + 10, 10), // Posición en el fondo rojo
    );

    // Dibujar texto del C.F. y el nombre, truncando si es necesario
    final detailsPainter = TextPainter(
      text: TextSpan(
        text:
            'C.F.: $cf\n${_truncateText(name, 25)}', // Truncar el nombre si es necesario
        style: const TextStyle(
          fontSize: 16, // Tamaño de fuente para los detalles
          color: Colors.white, // Color de texto blanco
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    detailsPainter.layout(maxWidth: width - blackBoxWidth - 20);
    detailsPainter.paint(
      canvas,
      const Offset(blackBoxWidth + 10, 40), // Posición debajo de "CORTADO"
    );

    // Finalizar el marcador personalizado
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }

  // Método para truncar el texto si es demasiado largo
  static String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text; // Si el texto cabe, no lo trunca
    return '${text.substring(0, maxLength - 3)}...'; // Añadir "..." si es necesario
  }
}
