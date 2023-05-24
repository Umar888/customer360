import 'package:flutter/material.dart';

class BottomNavigationBarPainter extends CustomPainter {
  BuildContext context;
  BottomNavigationBarPainter({required this.context});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color =Theme.of(context).primaryColorDark
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 10);

    final width = size.width;

    path.quadraticBezierTo(0, 0, width * 0.05, 0);
    path.lineTo(width * 0.35, 0);
    path.quadraticBezierTo(width * 0.4, 0, width * 0.4, 10);
    path.arcToPoint(Offset(width * 0.6, 10),
        radius: Radius.circular(1), clockwise: false);
    path.quadraticBezierTo(width * 0.6, 0, width * 0.65, 0);
    path.lineTo(width * 0.95, 0);
    path.quadraticBezierTo(width, 0, width, 10);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Theme.of(context).primaryColor, 10, true);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}