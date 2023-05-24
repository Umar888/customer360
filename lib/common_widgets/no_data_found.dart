import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';

import '../primitives/constants.dart';
import '../primitives/padding_system.dart';
import '../primitives/size_system.dart';

class NoDataFound extends StatelessWidget {
  final double fontSize;
  NoDataFound({Key? key, required this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Flexible(
          child: SvgPicture.asset(
        IconSystem.noDataFound,
        package: 'gc_customer_app',
      )),
      SizedBox(height: PaddingSystem.padding20),
      Text(
        'NO DATA FOUND !',
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: kRubik),
      )
    ]);
  }
}
