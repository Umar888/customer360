import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CircularAddButton extends StatelessWidget {
  CircularAddButton({
    Key? key,
    required this.buttonColor,
    required this.onPressed,
  }) : super(key: key);

  final Color buttonColor;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return SizedBox.shrink();
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: buttonColor,
        ),
        child: Padding(
          padding: EdgeInsets.all(9.0),
          child: Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
    // Card(
    //   elevation: 2,
    //   color: buttonColor,
    //   shape: CircleBorder(),
    //   child: InkWell(
    //     onTap: () => onPressed(),
    //     child: Padding(
    //       padding: EdgeInsets.all(padding),
    //       child: Text(
    //         centerText,
    //         style: TextStyle(
    //           fontSize: SizeSystem.size24,
    //           fontWeight: FontWeight.w500,
    //           color: Colors.white,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}