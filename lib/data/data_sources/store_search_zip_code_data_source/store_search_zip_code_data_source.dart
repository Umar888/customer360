import 'dart:convert';

import '../../../services/networking/endpoints.dart';
import '../../../services/networking/networking_service.dart';

class StoreSearchZipCodeDataSource {
  final HttpService httpService = HttpService();

  Future<dynamic> getAddresses(
      String zip, String radius, String userId, String orderId) async {
    print(Endpoints.getStoreZipAddress() +
        "?recordType=search&loggedinUserId=$userId&numberOfRecords=10&pageNumber=1&orderId=$orderId&postalCode=$zip&miles=$radius");
    var response = await httpService.doGet(
        path: Endpoints.getStoreZipAddress() +
            "?recordType=search&loggedinUserId=$userId&numberOfRecords=10&pageNumber=1&orderId=$orderId&postalCode=$zip&miles=$radius");
    return response;
  }
}
