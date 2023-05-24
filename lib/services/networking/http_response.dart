class HttpResponse {
  bool? status;
  String? message;
  dynamic data;

  HttpResponse({this.status, this.message, this.data});

  factory HttpResponse.fromJson(Map<String, dynamic> json) {
    return HttpResponse(status: json['status'], message: json['message'], data: json['body']);
  }
}
