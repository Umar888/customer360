import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/utils/double_extention.dart';

typedef SBuilder = Widget Function(
    BuildContext context, BoxConstraints constraints);

class SLayout extends StatelessWidget {
  final SBuilder desktop;
  final SBuilder mobile;

  SLayout({
    Key? key,
    required this.desktop,
    required this.mobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Size size = MediaQuery.of(context).size;
    if (screenWidth.isMobileWebDevice()) {
      return mobile(context, BoxConstraints.tight(size));
    } else {
      return desktop(context, BoxConstraints.tight(size));
    }
  }
}
