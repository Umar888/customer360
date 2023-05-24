import 'package:flutter/material.dart';
import 'package:gc_customer_app/primitives/color_system.dart';

class RRectPainter extends CustomPainter {
  double page;
  int count;
  Color color;
  Color selectedColor;
  double padding;
  late Paint _circlePaint;
  late Paint _selectedPaint;
  Size? size;
  Size? cornerSize;

  RRectPainter({
    this.page = 0.0,
    this.count = 0,
    this.color = Colors.white,
    this.selectedColor = ColorSystem.greyDark,
    this.padding = 5.0,
    this.size,
    this.cornerSize,
  }) {
    _circlePaint = Paint();
    _circlePaint.color = color;

    _selectedPaint = Paint();
    _selectedPaint.color = selectedColor;

    size ??= Size(12, 12);
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
      var rect = Rect.fromLTWH(x, 1, width, 2);
      var rrect = RRect.fromRectAndRadius(
        rect,
        Radius.elliptical(cornerSize!.width, cornerSize!.height),
      );
      canvas.drawRRect(rrect, _circlePaint);
    }

    var selectedX = startX + page * (width + padding);
    var rect = Rect.fromLTWH(selectedX,4, width, -4);
    var rrect = RRect.fromRectAndRadius(
      rect,
      Radius.elliptical(cornerSize!.width, cornerSize!.height),
    );
    canvas.drawRRect(rrect, _selectedPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}