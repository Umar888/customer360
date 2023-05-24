import 'package:equatable/equatable.dart';

class Refinement extends Equatable {
  String? value;
  String? name;
  String? label;
  bool? isChecked;
  String? id;
  String? eRecCount;
  String? dimensionName;
  String? dimensionId;
  bool? onPressed;

  Refinement(
      {this.value,
        this.name,
        this.label,
        this.isChecked,
        this.id,
        this.eRecCount,
        this.dimensionName,
        this.dimensionId,
        this.onPressed});

  Refinement.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    name = json['name'];
    label = json['label'];
    isChecked = json['isChecked'];
    id = json['id'];
    eRecCount = json['ERecCount'].toString();
    dimensionName = json['dimensionName'];
    dimensionId = json['dimensionId'];
    onPressed = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['name'] = name;
    data['label'] = label;
    data['isChecked'] = isChecked;
    data['id'] = id;
    data['ERecCount'] = eRecCount;
    data['dimensionName'] = dimensionName;
    data['dimensionId'] = dimensionId;
    return data;
  }

  @override
  List<Object?> get props => [
    value,
    name,
    label,
    isChecked,
    id,
    eRecCount,
    dimensionName,
    dimensionId,
    onPressed
  ];
}
