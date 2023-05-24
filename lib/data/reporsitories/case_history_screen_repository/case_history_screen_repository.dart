import 'package:gc_customer_app/data/data_sources/case_history_screen_data_source/case_history_screen_data_source.dart/case_history_screen_data_source.dart';

class CaseHistoryScreenRepository {
  CaseHistoryScreenDataSource caseHistoryScreenDataSource =
      CaseHistoryScreenDataSource();
  Future<dynamic> getCaseHistoryChartData(String recordID) async {
    var response =
        await caseHistoryScreenDataSource.getHistoryChartData(recordID);
    return response;
  }

  Future<dynamic> getOpenCasesHistoryList(String recordID) async {
    var response = await caseHistoryScreenDataSource.getOpenCasesList(recordID);
    return response;
  }

  Future<dynamic> getCaseHistoryCases(String recordID) async {
    var response =
        await caseHistoryScreenDataSource.getHistoryCasesList(recordID);
    return response;
  }
}
