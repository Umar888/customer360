import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';

class ProfileScreenDataSource {
  final HttpService httpService = HttpService();

  Future<HttpResponse> getClientProfile(String userId) async {
    var response = await httpService.doGet(
        path: Endpoints.getClientProfileDetails(userId));
    return response;
  }
}
