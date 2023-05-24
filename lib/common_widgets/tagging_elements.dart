import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/constants/colors.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';

class TaggingElements extends StatelessWidget {
  TaggingElements({
    Key? key,
    required this.widthOfScreen,
    required this.taggingText,
    required this.imagePath,
    required this.chipColor,
  }) : super(key: key);

  final double widthOfScreen;
  final String taggingText;
  final String imagePath;
  final bool chipColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chip(
        //   backgroundColor: chipColor
        //       ? AppColors.selectedChipColor.withOpacity(0.2)
        //       : AppColors.unselectedChipcolor.withOpacity(0.2),
        //   side: BorderSide(
        //       color: chipColor
        //           ? AppColors.selectedChipColor.withOpacity(0.2)
        //           : AppColors.unselectedChipcolor.withOpacity(0.2),
        //       width: 1),
        //   avatar: Row(
        //     children: [
        //       chipColor
        //           ? Icon(Icons.check_rounded,
        //               color: ColorSystem.additionalGreen)
        //           : Icon(Icons.close_rounded, color: ColorSystem.pureRed),
        //       SvgPicture.asset(
        //         imagePath,
        //         width: 20,
        //         height: 20,
        //       ),
        //     ],
        //   ),
        //   padding: EdgeInsets.only(left: 10, right: 10),
        //   label: Text(
        //     taggingText,
        //   ),
        //   elevation: 1,
        // ),
        Material(
          borderRadius: BorderRadius.circular(50),
          elevation: 1,
          child: Container(
            height: 35,
            padding: EdgeInsets.only(left: 8, right: 9),
            decoration: BoxDecoration(
              color: chipColor
                  ? AppColors.selectedChipColor.withOpacity(0.2)
                  : AppColors.unselectedChipcolor.withOpacity(0.2),
              border: Border.all(
                  color: chipColor
                      ? AppColors.selectedChipColor.withOpacity(0.2)
                      : AppColors.unselectedChipcolor.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(50),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.grey,
              //     offset: Offset(0.0, 1.0), //(x,y)
              //     blurRadius: 6.0,
              //   ),
              // ],
            ),
            child: Row(
              children: [
                chipColor
                    ? Icon(Icons.check_rounded,
                        color: ColorSystem.additionalGreen)
                    : Icon(Icons.close_rounded, color: ColorSystem.pureRed),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: SvgPicture.asset(
                    imagePath,
                    package: 'gc_customer_app',
                    width: 20,
                    height: 20,
                  ),
                ),
                Text(
                  taggingText,
                  style: TextStyle(fontFamily: kRubik),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 7,
        )
      ],
    );
  }
}
