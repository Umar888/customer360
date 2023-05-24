import 'package:flutter/material.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';

Widget orderStatusWidget(String status, [bool isShowBg = true]) {
  var color = ColorSystem.additionalGreen;
  switch (status) {
    case 'Delivered':
      color = ColorSystem.lavender3;
      break;
    case 'Shipped':
      color = ColorSystem.peach;
      break;
    case 'Cancelled':
    case 'Returned':
      color = ColorSystem.pureRed;
      break;
    case 'Submitted':
      color = ColorSystem.additionalPurple;
      break;
    case 'Draft':
      color = ColorSystem.primary;
      break;
    default:
  }
  return Container(
    alignment: Alignment.center,
    padding:
        isShowBg ? EdgeInsets.symmetric(vertical: 4, horizontal: 12) : null,
    decoration: isShowBg
        ? BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(100),
          )
        : null,
    child: Text(
      status,
      style: TextStyle(fontFamily: kRubik, color: color, fontSize: 16),
    ),
  );
}
