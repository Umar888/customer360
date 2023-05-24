import '../../data_sources/quote_log_data_source/quote_log_data_source.dart';

class QuoteLogRepository {
  QuoteLogDataSource quoteLogDataSource;
  QuoteLogRepository({required this.quoteLogDataSource});

  Future<dynamic> getOrders(String orderId) async{
    return await quoteLogDataSource.getOrders(orderId);
  }
  Future<dynamic> getQuotesHistoryList({required String recordId,required String orderId,required loggedInUserId}) async{
    return await quoteLogDataSource.getQuotesHistoryList(recordId: recordId, orderId: orderId, loggedInUserId: loggedInUserId);
  }

}