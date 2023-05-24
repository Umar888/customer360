import 'dart:convert';

import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';

class SettingsScreenDataSource {
  final HttpService httpService = HttpService();
  Future<HttpResponse> getSettingsData(recordID) async {
    var response = await httpService.doGet(
      path: Endpoints.getSettingsChecks(recordID),
    );
    return response;
  }

  Future<HttpResponse> saveCheckSettings(
      {required recordID, required Map latestCheckValue}) async {
    latestCheckValue.keys;
    var response = await httpService.doPost(
        path: Endpoints.saveSettingsCheck(recordID),
        body: {
          "settingLabel": latestCheckValue['type'],
          "isChecked": latestCheckValue['isChecked'],
          "recordId": recordID,
        });
    return response;
  }
}
