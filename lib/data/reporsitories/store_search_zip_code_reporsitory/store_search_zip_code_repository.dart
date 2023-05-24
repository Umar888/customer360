import '../../data_sources/store_search_zip_code_data_source/store_search_zip_code_data_source.dart';

class StoreSearchZipCodeRepository {
  StoreSearchZipCodeDataSource storeSearchZipCodeDataSource;
  StoreSearchZipCodeRepository({required this.storeSearchZipCodeDataSource});

  Future<dynamic> getAddress(String zip, String radius,String userId,String orderID) async{
    return await storeSearchZipCodeDataSource.getAddresses(zip, radius,userId,orderID);
  }
}