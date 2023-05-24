import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';

class OffersScreenDataSource {
  final HttpService httpService = HttpService();
  Future<HttpResponse> getCompanyOffersList() async {
    var response = await httpService.doGet(
      path: Endpoints.getOffersList(),
    );
    return response;
  }
}
