import 'package:flutter/material.dart';

class DashGenerator extends StatelessWidget {
  final int numberOfDashes;
  final Color color;

  DashGenerator({Key? key, this.numberOfDashes = 4, this.color = Colors.black87}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        numberOfDashes,
            (index) => Container(
          margin: EdgeInsets.only(
            left: 10,
            right: 10,
            top: 1,
            bottom: 1,
          ),
          height: 4,
          width: 1,
          color: color,
        ),
      ),
    );
  }
}