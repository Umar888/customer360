import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';

class RecommendedItems extends StatelessWidget {
  RecommendedItems(
      {Key? key,
      required this.widthOfScreen,
      required this.heightOfScreen,
      required this.pathOfImage,
      required this.check})
      : super(key: key);

  final double widthOfScreen;
  final double heightOfScreen;
  final String pathOfImage;
  final bool check;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            Card(
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widthOfScreen * 0.05),
              ),
              child: Container(
                width: widthOfScreen * 0.3,
                height: heightOfScreen * 0.2,
                padding: EdgeInsets.only(
                  left: widthOfScreen * 0.06,
                  right: widthOfScreen * 0.06,
                  bottom: widthOfScreen * 0.03,
                ),
                child: Image.asset(pathOfImage),
              ),
            ),
            SizedBox(
              width: widthOfScreen * 0.01,
            )
          ],
        ),
        check
            ? Positioned(
                right: widthOfScreen * 0.04,
                bottom: widthOfScreen * 0.04,
                child: SvgPicture.asset(
                  IconSystem.tickIcon,
                  package: 'gc_customer_app',
                ))
            : Container()
      ],
    );
  }
}
