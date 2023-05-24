
import '../../../services/networking/endpoints.dart';
import '../../../services/networking/networking_service.dart';

class QuoteLogDataSource {
  final HttpService httpService = HttpService();

  Future<dynamic> getOrders(String orderId) async{
    var response =await httpService
        .doGet(path: Endpoints.getPastOrderDetail(orderId));
    return response;
  }

  Future<dynamic> getQuotesHistoryList({required String recordId,required String orderId,required loggedInUserId}) async{
    var response =await httpService
        .doGet(path: Endpoints.getQuotesHistoryList(recordID: recordId, orderId: orderId, loggedInUserId: loggedInUserId));
    return response;
  }

}