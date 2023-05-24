import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';

class OrderLookUpDataSource {
  final HttpService httpService = HttpService();

  Future<HttpResponse> getOrderLookUp(String searchText) async {
    var response =
        await httpService.doGet(path: Endpoints.getOrderLookUp(searchText));
    return response;
  }

  Future<HttpResponse> getOrderLookUpOpenOrderByOrderNumber(
      String searchText) async {
    var response = await httpService.doGet(
        path: Endpoints.getOrderLookUpOpenOrderByOrderNumber(searchText));
    return response;
  }

  Future<HttpResponse> getOrderLookUpOpenOrderByQouteNumber(
      String searchText) async {
    var response = await httpService.doGet(
        path: Endpoints.getOrderLookUpOpenOrderByQouteNumber(searchText));
    return response;
  }
}
