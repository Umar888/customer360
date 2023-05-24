class SubmitOverrideRequest {
  String? status;
  String? loggedInProfileName;
  bool? isSuccess;
  bool? isStoreIdAvailable;

  SubmitOverrideRequest(
      {this.status,
        this.loggedInProfileName,
        this.isSuccess,
        this.isStoreIdAvailable});

  SubmitOverrideRequest.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    loggedInProfileName = json['loggedInProfileName'];
    isSuccess = json['isSuccess'];
    isStoreIdAvailable = json['isStoreIdAvailable'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['loggedInProfileName'] = loggedInProfileName;
    data['isSuccess'] = isSuccess;
    data['isStoreIdAvailable'] = isStoreIdAvailable;
    return data;
  }
}