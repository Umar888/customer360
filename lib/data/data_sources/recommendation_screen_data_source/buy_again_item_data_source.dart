import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';

class BuyAgainItemsDataSource {
  final HttpService httpService = HttpService();
  Future<HttpResponse> getBuyItemsList(String recordID) async {
    var response = await httpService.doGet(
      path: Endpoints.getBuyItemsPageList(recordID),
    );
    return response;
  }
}
