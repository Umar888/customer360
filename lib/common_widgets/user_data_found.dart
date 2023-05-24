import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';

import '../primitives/constants.dart';
import '../primitives/padding_system.dart';
import '../primitives/size_system.dart';

class UserDataFound extends StatelessWidget {
  final double fontSize;
  UserDataFound({Key? key,required this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
      Flexible(child: SvgPicture.asset(IconSystem.noDataFound)),
      SizedBox(height: PaddingSystem.padding20),
       Text(
        'CUSTOMER INFO NOT FOUND !',
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: kRubik),
      )
    ]);
  }
}
