import 'package:flutter/material.dart';

class DamagePainter extends CustomPainter {
  final double normalizedX;
  final double normalizedY;
  final double normalizedWidth;
  final double normalizedHeight;
  final String label;
  final double score;
  final Color boundingBoxColor;

  DamagePainter({
    required this.normalizedX,
    required this.normalizedY,
    required this.normalizedWidth,
    required this.normalizedHeight,
    required this.label,
    required this.score,
    required this.boundingBoxColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Transformasi Normalisasi AI (0.0 - 1.0) ke Koordinat Logical Pixels
    double finalX = normalizedX * size.width;
    double finalY = normalizedY * size.height;
    double finalW = normalizedWidth * size.width;
    double finalH = normalizedHeight * size.height;

    // Koordinat Target Area
    final rect = Rect.fromLTWH(finalX, finalY, finalW, finalH);

    // 2. Konfigurasi "Kuas" Digital
    final paint = Paint()
      ..color = boundingBoxColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke; // Garis pinggir saja, bukan blok warna

    // 3. Menggambar Kotak (Bounding Box) ke Kanvas
    canvas.drawRect(rect, paint);

    // 4. Konstruksi Label Tipe Kerusakan
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      backgroundColor: boundingBoxColor,
      shadows: const [
        Shadow(
          blurRadius: 4.0,
          color: Colors.black54,
          offset: Offset(1.0, 1.0),
        ),
      ],
    );

    final textSpan = TextSpan(
      text: " $label - ${(score * 100).toStringAsFixed(0)}% ",
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    // 5. Layouting & Rendering Teks
    textPainter.layout();
    
    // Deteksi supaya teks tidak terpotong tepi layar bagian atas
    double textY = rect.top - 25;
    if (textY < 0) {
      textY = rect.bottom + 5;
    }
    
    textPainter.paint(canvas, Offset(rect.left, textY));
  }

  @override
  bool shouldRepaint(covariant DamagePainter oldDelegate) {
    // Mengembalikan true karena kita punya animasi pergerakan kotak di View
    return oldDelegate.normalizedX != normalizedX || 
           oldDelegate.normalizedY != normalizedY ||
           oldDelegate.label != label;
  }
}
