class ReasonsListModel {
  List<String>? nlnReasonList;
  String? message;

  ReasonsListModel({this.nlnReasonList, this.message});

  ReasonsListModel.fromJson(Map<String, dynamic> json) {
    nlnReasonList = json['nlnReasonList'].cast<String>();
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nlnReasonList'] = this.nlnReasonList;
    data['message'] = this.message;
    return data;
  }
}
