import 'package:equatable/equatable.dart';

class OptionsModel extends Equatable {
  final String title;
  bool onPressed;

  OptionsModel({
    required this.title,
    required this.onPressed,
  });

  @override
  List<Object?> get props => [title, onPressed];
}
