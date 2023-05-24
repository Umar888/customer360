import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/primitives/color_system.dart';

class ActivityButton extends StatelessWidget {
  ActivityButton({
    Key? key,
    required this.heightOfScreen,
    required this.widthOfScreen,
    required this.buttonColor,
    this.iconImage,
    required this.text,
    required this.isLoading,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  final double heightOfScreen;
  final double widthOfScreen;
  final bool isLoading;
  final Color buttonColor;
  final Widget? iconImage;
  final String text;
  final void Function() onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: heightOfScreen * 0.07,
//          width: widthOfScreen * 0.2,
          padding: EdgeInsets.symmetric(
              horizontal: kIsWeb ? 0 : widthOfScreen * 0.04,
              vertical: heightOfScreen * 0.02),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: buttonColor,
              border: Border.all(
                  color: isSelected
                      ? ColorSystem.pieChartRed
                      : Colors.transparent)),
          child: Center(
            child: isLoading
                ? CupertinoActivityIndicator(
                    color: Colors.black,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (iconImage != null)
                        Row(
                          children: [
                            iconImage!,
                            // SvgPicture.asset(iconImage!),
                            SizedBox(width: 5),
                          ],
                        ),
                      Text(
                        text,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
