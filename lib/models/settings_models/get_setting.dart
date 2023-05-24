import 'package:equatable/equatable.dart';

class GetSettingsModel extends Equatable {
  GetSettingsModel({
    required this.settings,
    required this.message,
  });
  late final List<Settings> settings;
  late final String message;

  GetSettingsModel.fromJson(Map<String, dynamic> json) {
    if (json['Settings'] != null && json['Settings'].isNotEmpty) {
      settings =
          List.from(json['Settings']).map((e) => Settings.fromJson(e)).toList();
    } else {
      settings = [];
    }

    message = json['message']??'';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['Settings'] = settings.map((e) => e.toJson()).toList();
    data['message'] = message;
    return data;
  }

  @override
  List<Object?> get props => [settings, message];
}

class Settings extends Equatable {
  Settings({
    required this.type,
    required this.isDisabled,
    required this.isSaving,
    required this.isChecked,
    required this.onClickButton,
  });
  late final String type;
  late final bool isDisabled;
  bool? isChecked;
  bool? isSaving;
  bool? onClickButton;

  Settings.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    isDisabled = json['isDisabled'];
    isChecked = json['isChecked'];
    isSaving = false;
    onClickButton=true;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['isDisabled'] = isDisabled;
    data['isChecked'] = isChecked;
    return data;
  }

  @override
  List<Object?> get props => [
        type,
        isChecked,
        isDisabled,
        isSaving,
      ];
}
