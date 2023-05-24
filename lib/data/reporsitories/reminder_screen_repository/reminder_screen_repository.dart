import 'package:gc_customer_app/data/data_sources/reminder_screen_data_source/reminder_screen_data_source.dart';
import 'package:gc_customer_app/models/reminder_model.dart';

class ReminderScreenReponsitory {
  ReminderScreenDataSource reminderScreenDataSource =
      ReminderScreenDataSource();

  Future<List<ReminderModel>> getReminders(
      String recordId, String loggedinUserId) async {
    var response =
        await reminderScreenDataSource.getReminders(recordId, loggedinUserId);
    if (response.status ??
        true &&
            response.data['AllOpenTasks'] != null &&
            response.data['AllOpenTasks'].isNotEmpty) {
      List reminders = response.data['AllOpenTasks'];
      return reminders
          .map<ReminderModel>((r) => ReminderModel.fromJson(r))
          .toList();
    } else {
      throw Exception(response.message ?? '');
    }
  }

  Future<ReminderModel> saveReminder(
      String userId, String userRecordId, String note, DateTime dueDate,
      {String? alertType, String? accountName}) async {
    var response = await reminderScreenDataSource.saveReminder(
        userId, userRecordId, note, dueDate,
        alertType: alertType, accountName: accountName);
    if (response.status ?? true && response.data['task'] != null) {
      return ReminderModel.fromJson(response.data['task']);
    } else {
      throw Exception(response.message ?? '');
    }
  }

  Future<ReminderModel> updateReminder(String userId, String userRecordId,
      String reminderId, String note, DateTime dueDate,
      {String? alertType, String? accountName}) async {
    var response = await reminderScreenDataSource.updateReminder(
        userId, userRecordId, reminderId, note, dueDate,
        alertType: alertType, accountName: accountName);
    if (response.status ?? true && response.data['task'] != null) {
      return ReminderModel.fromJson(response.data['task']);
    } else {
      throw Exception(response.message ?? '');
    }
  }
}
