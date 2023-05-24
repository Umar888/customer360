import 'dart:ui';

import 'package:equatable/equatable.dart';

class ColorModel extends Equatable{
  String? name;
  Color? color;

  ColorModel({
    this.color,
    this.name});

@override
  List<Object?> get props => [color, name];
}