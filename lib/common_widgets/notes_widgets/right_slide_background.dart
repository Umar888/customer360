import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../primitives/icon_system.dart';

Widget slideRightBackground() {
  return Align(
    alignment: Alignment.centerLeft,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
        ),
        SvgPicture.asset(IconSystem.deleteIcon),
      ],
    ),
  );
}
