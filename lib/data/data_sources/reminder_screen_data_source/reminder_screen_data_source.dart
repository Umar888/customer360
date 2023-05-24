import 'dart:convert';

import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/services/networking/request_body.dart';

class ReminderScreenDataSource {
  final HttpService httpService = HttpService();

  Future<HttpResponse> getReminders(
      String recordId, String loggedinUserId) async {
    var response = await httpService.doGet(
        path: Endpoints.getReminders(recordId, loggedinUserId));
    return response;
  }

  Future<HttpResponse> saveReminder(
      String userId, String userRecordId, String note, DateTime dueDate,
      {String? alertType, String? accountName}) async {
    var response = await httpService.doPost(
        path: Endpoints.saveReminder(),
        body: RequestBody.saveReminderBody(
            note: note,
            dueDate: dueDate,
            id: userId,
            recordId: userRecordId,
            alertType: alertType,
            accountName: accountName),
        tokenRequired: true);
    return response;
  }

  Future<HttpResponse> updateReminder(String userId, String userRecordId,
      String reminderId, String note, DateTime dueDate,
      {String? alertType, String? accountName}) async {
    var response = await httpService.doPost(
        path: Endpoints.saveReminder(),
        body: RequestBody.updateReminderBody(
            note: note,
            dueDate: dueDate,
            id: userId,
            reminderId: reminderId,
            recordId: userRecordId,
            alertType: alertType,
            accountName: accountName),
        tokenRequired: true);
    return response;
  }
}
