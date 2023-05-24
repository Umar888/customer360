import 'package:flutter/material.dart';
import 'package:gc_customer_app/primitives/constants.dart';

import '../primitives/color_system.dart';

class AppBarWidget extends StatelessWidget {
  AppBarWidget({
    Key? key,
    required this.paddingFromleftLeading,
    required this.textThem,
    required this.leadingWidget,
    required this.onPressedLeading,
    required this.titletxt,
    required this.actionsWidget,
    required this.actionOnPress,
    required this.paddingFromRightActions,
    this.backgroundColor,
  }) : super(key: key);

  final double paddingFromleftLeading;
  final double paddingFromRightActions;
  final TextTheme textThem;
  final Widget leadingWidget;
  final Function onPressedLeading;
  final String titletxt;
  final Widget actionsWidget;
  final void Function() actionOnPress;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? ColorSystem.scaffoldBackgroundColor,
      leading: Padding(
        padding: EdgeInsets.only(left: paddingFromleftLeading),
        child: InkWell(onTap: () => onPressedLeading(), child: leadingWidget),
      ),
      centerTitle: true,
      title: Text(titletxt,
          style: TextStyle(
              fontFamily: kRubik,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              fontSize: 15)),
      elevation: 0,
      actions: [
        GestureDetector(
          onTap: actionOnPress,
          child: Padding(
              padding: EdgeInsets.only(right: paddingFromRightActions),
              child: actionsWidget),
        )
      ],
    );
  }
}
