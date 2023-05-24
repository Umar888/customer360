import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';

import '../../../../services/networking/endpoints.dart';

class CaseHistoryScreenDataSource {
  final HttpService httpService = HttpService();
  Future<HttpResponse> getHistoryChartData(recordID) async {
    var response = await httpService.doGet(
      path: Endpoints.getHistoryChartData(recordID),
    );
    return response;
  }

  Future<HttpResponse> getOpenCasesList(recordID) async {
    var response = await httpService.doGet(
      path: Endpoints.getOpenCasesList(recordID),
    );
    return response;
  }

  Future<HttpResponse> getHistoryCasesList(recordID) async {
    var response = await httpService.doGet(
      path: Endpoints.getHistoryCasesList(recordID),
    );
    return response;
  }
}
