
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

class SearchPlacesDataSource{
  final HttpService httpService = HttpService();

  Future<dynamic> fetchSearchList(String query) async{
    String userRecordId = await SharedPreferenceService().getValue(agentId);
    final response = await httpService.doGet(path:Endpoints.searchAddress(userRecordId, query));
    return response;
  }
}