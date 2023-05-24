import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';

import '../primitives/constants.dart';
import '../primitives/padding_system.dart';
import '../primitives/size_system.dart';

class LoadingTheme extends StatelessWidget {
  LoadingTheme({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
          height: double.infinity,
          width: double.infinity,
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          alignment: Alignment.center,
          child: CircularProgressIndicator()
          // Lottie.asset(IconSystem.loading,
          //   width: 150,
          //   height: 150,
          //   fit: BoxFit.fill,)
        );
  }
}
