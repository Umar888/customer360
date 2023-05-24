// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../models/pinned_notes_model.dart';

class AllNotesWidget extends StatelessWidget {
  AllNotesWidget({
    Key? key,
    required this.heightOfScreen,
    required this.widthOfScreen,
    required this.textThem,
    required this.index,
    required this.backgroundColor,
    required this.authorOfNote,
    required this.dateOfNote,
    required this.allNotesList,
  }) : super(key: key);

  final double heightOfScreen;
  final double widthOfScreen;
  final TextTheme textThem;
  final int index;
  final Color backgroundColor;
  final String authorOfNote;
  final String dateOfNote;
  final List<PinnedNotes> allNotesList;

//   @override
//   State<AllNotesWidget> createState() => _AllNotesWidgetState();
// }

// class _AllNotesWidgetState extends State<AllNotesWidget> {
//   @override
//   void initState() {
//     super.initState();
//     isExpand = false;
//   }

  // bool? isExpand;
  @override
  Widget build(BuildContext context) {
    // return Row(
    //   children: [
    //     isPressed!
    //         ? GestureDetector(
    //             // onTap: () => setState(() {
    //             //   isExpand = !isExpand!;
    //             // }
    //             // ),
    //             child: Container(
    //               width: widthOfScreen * 0.95,
    //               padding: EdgeInsets.symmetric(
    //                   horizontal: widthOfScreen * 0.02,
    //                   vertical: heightOfScreen * 0.02),
    //               decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(15),
    //                   color: backgroundColor),
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Text(
    //                     allNotesList[index]['text'],
    //                     style: textThem.headline3,
    //                     maxLines: 10,
    //                     softWrap: true,
    //                   ),
    //                   SizedBox(
    //                     height: 10,
    //                   ),
    //                   Padding(
    //                     padding: EdgeInsets.symmetric(horizontal: 8.0),
    //                     child: Row(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Text(
    //                           authorOfNote,
    //                           style: textThem.headline5,
    //                         ),
    //                         Text(
    //                           dateOfNote,
    //                           style: textThem.headline5,
    //                         ),
    //                       ],
    //                     ),
    //                   )
    //                 ],
    //               ),
    //             ),
    //           )
    //         : GestureDetector(
    //             // onTap: () => setState(() {
    //             //   isExpand = !isExpand!;
    //             // }),
    //             child: Container(
    //               width: widthOfScreen * 0.95,
    //               padding: EdgeInsets.symmetric(
    //                   horizontal: widthOfScreen * 0.02,
    //                   vertical: heightOfScreen * 0.02),
    //               decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(15),
    //                   color: backgroundColor),
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Text(
    //                     allNotesList[index]['text'],
    //                     style: textThem.headline3,
    //                     maxLines: 1,
    //                   ),
    //                   SizedBox(
    //                     height: 10,
    //                   ),
    //                   Padding(
    //                     padding: EdgeInsets.symmetric(horizontal: 8.0),
    //                     child: Row(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Text(
    //                           authorOfNote,
    //                           style: textThem.headline5,
    //                         ),
    //                         Text(
    //                           dateOfNote,
    //                           style: textThem.headline5,
    //                         ),
    //                       ],
    //                     ),
    //                   )
    //                 ],
    //               ),
    //             ),
    //           ),
    //   ],
    // );
    return Row(
      children: [
        // !allNotesList[index].isLess!
        //     ?
        Container(
          width: widthOfScreen * 0.95,
          // width: widthOfScreen * 0.95,
          padding: EdgeInsets.symmetric(
              horizontal: widthOfScreen * 0.02,
              vertical: heightOfScreen * 0.02),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: backgroundColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                allNotesList[index].textOfNote!,
                style: textThem.headline3,
                maxLines: allNotesList[index].isLess! ?1:10,
                softWrap: true,
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                ),
              )
            ],
          ),
        )
        // : Container(
        //     width: widthOfScreen * 0.95,
        //     padding: EdgeInsets.symmetric(
        //         horizontal: widthOfScreen * 0.02,
        //         vertical: heightOfScreen * 0.02),
        //     decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(15),
        //         color: backgroundColor),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Text(
        //           allNotesList[index].textOfNote!,
        //           style: textThem.headline3,
        //           maxLines: 1,
        //         ),
        //         SizedBox(
        //           height: 10,
        //         ),
        //         Padding(
        //           padding: EdgeInsets.symmetric(horizontal: 8.0),
        //           child: Row(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: [
        //               Text(
        //                 authorOfNote,
        //                 style: textThem.headline5,
        //               ),
        //               Text(
        //                 dateOfNote,
        //                 style: textThem.headline5,
        //               ),
        //             ],
        //           ),
        //         )
        //       ],
        //     ),
        //   ),
      ],
    );
  }
}
