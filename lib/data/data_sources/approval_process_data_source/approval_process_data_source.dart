import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';

class ApprovalProcesssDataSource {
  final HttpService httpService = HttpService();

  Future<HttpResponse> getApproval(String loggedInId) async {
    var response = await httpService.doGet(path: Endpoints.getApprovalProcess(loggedInId));
    return response;
  }

  Future<HttpResponse> approveApproval(String approveURL) async {
    var response = await httpService.doGet(path: approveURL);
    return response;
  }

  Future<HttpResponse> rejectApproval(String rejectURL) async {
    var response = await httpService.doGet(path: rejectURL);
    return response;
  }
}
