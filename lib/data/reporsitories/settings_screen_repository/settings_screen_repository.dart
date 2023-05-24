import 'package:gc_customer_app/data/data_sources/setting_screen_data_source/setting_screen_data_source.dart';

class SettingsScreenRepository {
  SettingsScreenDataSource settingsScreenDataSource =
      SettingsScreenDataSource();
  Future<dynamic> getSettingsScreenChecks(String recordID) async {
    var response = await settingsScreenDataSource.getSettingsData(recordID);
    return response;
  }

  Future<dynamic> saveSettingsBackend(
      {required String recordID, required Map latestCheckValue}) async {
    var response = await settingsScreenDataSource.saveCheckSettings(
        recordID: recordID, latestCheckValue: latestCheckValue);
    return response;
  }
}
