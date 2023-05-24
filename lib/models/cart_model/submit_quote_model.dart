class QuoteSubmitModel {
  String? message;
  bool? isSuccess;

  QuoteSubmitModel({this.message, this.isSuccess});

  QuoteSubmitModel.fromJson(Map<String, dynamic> json) {
    message = json['message']??"";
    isSuccess = json['isSuccess']??false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['isSuccess'] = this.isSuccess;
    return data;
  }
}
