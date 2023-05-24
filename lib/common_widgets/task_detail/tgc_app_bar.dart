import 'package:flutter/material.dart';
import '../../primitives/color_system.dart';
import '../../primitives/constants.dart';
import '../../primitives/size_system.dart';

class TGCAppBar extends AppBar {
  final String label;
  final bool titleCentered;
  final List<Widget>? trailingActions;
  final Widget? leadingWidget;

  TGCAppBar({
    Key? key,
    this.label = '',
    this.titleCentered = true,
    this.trailingActions = const[],
    this.leadingWidget,
  }) : super(
          key: key,
          title: Text(
            label,
            style: TextStyle(
              fontSize: SizeSystem.size18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: kRubik,
            ),
          ),
          centerTitle: titleCentered,
          actions: trailingActions,
          leading: leadingWidget,
          leadingWidth: 48,
          elevation: 0,
          backgroundColor: ColorSystem.scaffoldBackgroundColor,
        );
}
