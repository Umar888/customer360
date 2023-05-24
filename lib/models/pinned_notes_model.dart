// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:equatable/equatable.dart';

class PinnedNotes extends Equatable{
  String? textOfNote;
  String? authorOfNote;
  String? dateOfNote;
  bool? isLess;
  Color? backgroundColor;
  PinnedNotes({
    this.textOfNote,
    this.authorOfNote,
    this.isLess,
    this.dateOfNote,
    this.backgroundColor,
  });
  @override
  List<Object?> get props => [isLess,textOfNote,authorOfNote,dateOfNote,backgroundColor];

}
