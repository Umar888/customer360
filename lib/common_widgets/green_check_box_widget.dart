import 'package:flutter/material.dart';

import '../constants/colors.dart';

class GreenCheckBoxWidget extends StatelessWidget {
  GreenCheckBoxWidget({
    Key? key,
    required this.paddingOfButton,
    required this.iconOfButton,
    required this.onPressed,
  }) : super(key: key);
  final double paddingOfButton;
  final IconData iconOfButton;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white

        ),
        child: Card(
          elevation: 2,
          color: AppColors.greenCheckboxColor,
          shape: CircleBorder(),
          child: Padding(
              padding: EdgeInsets.all(paddingOfButton),
              child: Icon(
                iconOfButton,
                color: Colors.white,
              )),
        ),
      ),
    );
  }
}
