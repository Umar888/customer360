import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../../constants/constant_lists.dart';
import '../../primitives/color_system.dart';
import '../../primitives/constants.dart';

class PinnedNotesWidget extends StatelessWidget {
  PinnedNotesWidget({
    Key? key,
    required this.heightOfScreen,
    required this.widthOfScreen,
    required this.textThem,
    required this.index,
    required this.backgroundColor,
    required this.authorOfNote,
    required this.dateOfNote, required this.isLess,
  }) : super(key: key);

  final double heightOfScreen;
  final double widthOfScreen;
  final TextTheme textThem;
  final int index;
  final Color backgroundColor;
  final String authorOfNote;
  final String dateOfNote;
  final bool isLess;

  @override
  Widget build(BuildContext context) {
   
    return Row(
      children: [
        Container(
        height: isLess?heightOfScreen * 0.225:heightOfScreen * 0.3,
          width: widthOfScreen * 0.7,
          padding: EdgeInsets.symmetric(
              horizontal: widthOfScreen * 0.02, vertical: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: backgroundColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text(
              //   pinnedNotes[index]['text'],
              //   style: textThem.headline3,
              //   maxLines: 5,
              // ),
              Expanded(
                child: ReadMoreText(
                  pinnedNotes[index]['text'],
                  style: TextStyle(
                      color: Colors.black87, fontFamily: kRubik),
                  trimCollapsedText: "...Show More",
                  trimExpandedText: "  Show Less",
                  trimMode: TrimMode.Line,
                  trimLines: 4,
                  callback: (_) {},
                  textAlign: TextAlign.justify,
                  delimiter: "",
                  moreStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorSystem.lavender3,
                      fontFamily: kRubik),
                  lessStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorSystem.lavender3,
                      fontFamily: kRubik),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authorOfNote,
                    style: textThem.headline5,
                  ),
                  Text(
                    dateOfNote,
                    style: textThem.headline5,
                  ),
                ],
              )
            ],
          ),
        ),
        SizedBox(width: widthOfScreen * 0.04),
      ],
    );
  }
}
