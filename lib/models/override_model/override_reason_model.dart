class OverrideReasonsModel {
  List<String>? overrideReasonList;

  OverrideReasonsModel({this.overrideReasonList});

  OverrideReasonsModel.fromJson(Map<String, dynamic> json) {
    overrideReasonList = json['OverrideReasonList'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['OverrideReasonList'] = overrideReasonList;
    return data;
  }
}