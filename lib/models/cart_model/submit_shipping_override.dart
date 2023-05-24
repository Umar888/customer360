class SubmitShippingReason {
  String? status;
  String? loggedInProfileName;
  bool? isSuccess;

  SubmitShippingReason({this.status, this.loggedInProfileName, this.isSuccess});

  SubmitShippingReason.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    loggedInProfileName = json['loggedInProfileName'];
    isSuccess = json['isSuccess'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['loggedInProfileName'] = this.loggedInProfileName;
    data['isSuccess'] = this.isSuccess;
    return data;
  }
}
