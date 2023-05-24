import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CaseHistoryCartDeliveryWidget extends StatelessWidget {
  CaseHistoryCartDeliveryWidget({
    Key? key,
    required this.widthOfScreen,
    required this.textOfItems,
    required this.dateOfItem,
    required this.remainingText,
    required this.twoIcons,
    required this.rightIconPath,
    required this.leftIconPath,
  }) : super(key: key);

  final double widthOfScreen;
  final String textOfItems;
  final String dateOfItem;
  final String remainingText;
  final bool twoIcons;
  final String rightIconPath;
  final String leftIconPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: widthOfScreen * 0.5,
                  child: Text(
                    textOfItems,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: 7),
                SizedBox(
                  width: twoIcons ? widthOfScreen * 0.5 : widthOfScreen * 0.61,
                  child: Row(
                    children: [
                      Text(
                        dateOfItem,
                        style: TextStyle(
                            color: Colors.black,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(
                        ' : ',
                        style: TextStyle(overflow: TextOverflow.ellipsis),
                      ),
                      Expanded(
                        child: Text(
                          remainingText,
                          style:
                              TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                twoIcons
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: SvgPicture.asset(
                          rightIconPath,
                          color: Colors.grey,
                        ),
                      )
                    : Container(),
                SizedBox(
                  width: 15,
                ),
                SizedBox(
                  height: 20,
                  width: 20,
                  child: SvgPicture.asset(
                    leftIconPath,
                    color: Colors.grey,
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}
