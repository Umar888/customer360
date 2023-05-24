import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';

class PaymentCardsDataSource {
  final HttpService httpService = HttpService();

  Future<HttpResponse> getClientProfilePaymentCards(String recordId) async {
    var response = await httpService.doGet(
        path: Endpoints.getClientProfilePaymentCards(recordId));
    return response;
  }
}
