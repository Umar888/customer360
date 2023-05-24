import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';

Widget slideLeftBackground() {
  return Align(
    alignment: Alignment.centerRight,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children:  [
        SvgPicture.asset(IconSystem.pinIcon),
       
        SizedBox(
          width: 20,
        ),
      ],
    ),
  );
}
