import 'package:flutter/material.dart';

import '../../primitives/color_system.dart';

class OvalPainter extends CustomPainter {
  double page;
  int count;
  Color color;
  Color selectedColor;
  double padding;
  late Paint _circlePaint;
  late Paint _selectedPaint;
  Size? size;

  OvalPainter({
    this.page = 0.0,
    this.count = 0,
    this.color = Colors.white,
    this.selectedColor = ColorSystem.greyDark,
    this.padding = 5.0,
    this.size,
  }) {
    _circlePaint = Paint();
    _circlePaint.color = color;

    _selectedPaint = Paint();
    _selectedPaint.color = selectedColor;

    this.size ??= Size(12, 12);
  }
  double get totalWidth => count * size!.width + padding * (count - 1);

  @override
  void paint(Canvas canvas, Size size) {
    var height = this.size!.height;
    var width = this.size!.width;
    var centerWidth = size.width / 2;
    var startX = centerWidth - totalWidth / 2;
    for (var i = 0; i < count; i++) {
      var x = startX + i * (width + padding);
      var rect = Rect.fromLTWH(x, 0, width, height);
      canvas.drawOval(rect, _circlePaint);
    }

    var selectedX = startX + page * (width + padding);
    var rect = Rect.fromLTWH(selectedX, 0, width, height);
    canvas.drawOval(rect, _selectedPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}