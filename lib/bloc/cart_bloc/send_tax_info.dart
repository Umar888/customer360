class SendTaxInfoModel {
  String? message;
  bool? isSuccess;

  SendTaxInfoModel({this.message, this.isSuccess});

  SendTaxInfoModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    isSuccess = json['isSuccess']??false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['isSuccess'] = this.isSuccess;
    return data;
  }
}
