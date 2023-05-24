import 'package:gc_customer_app/models/recommendation_Screen_model/buy_again_model.dart';
import '../../data_sources/recommendation_screen_data_source/buy_again_item_data_source.dart';

class BuyAgainItemRepository {
  BuyAgainItemsDataSource buyAgainItemsDataSource = BuyAgainItemsDataSource();
  Future<dynamic> getBuyItemsModel(String recordID) async {
    var response = await buyAgainItemsDataSource.getBuyItemsList(recordID);
    if (response.data != null && response.status == true) {
      BuyAgainModel buyAgainModel = BuyAgainModel.fromJson(response.data);
      return buyAgainModel;
    } else {}
  }
}
