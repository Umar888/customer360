import 'package:equatable/equatable.dart';

class PrinterModel extends Equatable{
  PrinterModel({
    this.value,
    this.key,
    this.type,
  });

  String? value;
  String? key;
  String? type;

  factory PrinterModel.fromJson(Map<String, dynamic> json) => PrinterModel(
        value: json["value"],
        key: json["key"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "key": key,
        "type": type,
      };

  @override
  List<Object?> get props => [value, key, type];
}
