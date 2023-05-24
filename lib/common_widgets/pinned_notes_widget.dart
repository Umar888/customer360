import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:readmore/readmore.dart';


import '../models/pinned_notes_model.dart';

class PinnedNotesWidget extends StatelessWidget {
  PinnedNotesWidget({
    Key? key,
    required this.heightOfScreen,
    required this.widthOfScreen,
    required this.textThem,
    required this.pinnedNotes,
    required this.index, required this.backgroundColor, required this.authorOfNote, required this.dateOfNote,
  }) : super(key: key);

  final double heightOfScreen;
  final double widthOfScreen;
  final TextTheme textThem;
  final int index;
  final List<PinnedNotes> pinnedNotes;
  final Color backgroundColor;
  final String authorOfNote;
  final String dateOfNote;


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: pinnedNotes[index].isLess!?heightOfScreen * 0.225:heightOfScreen * 0.3,
          width: widthOfScreen * 0.7,
          padding: EdgeInsets.symmetric(
              horizontal: widthOfScreen * 0.02,
              vertical: heightOfScreen * 0.02),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: backgroundColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ReadMoreText(
                  pinnedNotes[index].textOfNote??"",
                  style: TextStyle(color: Colors.black87,
                      fontFamily: kRubik),
                  trimCollapsedText: "...Show More",
                  trimExpandedText: "  Show Less",
                  trimMode: TrimMode.Line,
                  trimLines: 4,
                  callback: (_){
                    BlocProvider.of<LandingScreenBloc>(context).add(PinnedNotesChange(index: index));
                  },
                  textAlign: TextAlign.justify,
                  delimiter: "",
                  moreStyle:  TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: ColorSystem.lavender3, fontFamily: kRubik),
                  lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: ColorSystem.lavender3, fontFamily: kRubik),
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
      ],
    );
  }
}
