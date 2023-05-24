import 'package:gc_customer_app/data/data_sources/order_history_data_source/order_history_data_source.dart';
import 'package:gc_customer_app/models/cart_model/cart_detail_model.dart';
import 'package:gc_customer_app/models/order_history/customer_order_info_model.dart';
import 'package:gc_customer_app/models/order_history/open_order_model.dart';
import 'package:gc_customer_app/models/order_history/order_accessories_model.dart';
import 'package:gc_customer_app/models/order_history/order_history_model.dart';

class OrderHistoryRepository {
  OrderHistoryDataSource orderHistoryDataSource = OrderHistoryDataSource();

  Future<CustomerOrderInfoModel> getCustomerOrderInfo(String recordId) async {
    var response = await orderHistoryDataSource.getCustomerOrderInfo(recordId);
    if (response.data != null &&
        response.status! &&
        response.data['records'] != null &&
        response.data['records'].isNotEmpty) {
      return CustomerOrderInfoModel.fromJson(response.data);
    } else {
      return CustomerOrderInfoModel(records: [], totalSize: 0);
    }
  }

  // Future<PurchaseCategory> getOrderAccessories(String recordId) async {
  //   var response = await orderHistoryDataSource.getOrderAccessories(recordId);
  //   if (response.data != null &&
  //       response.status! &&
  //       response.data['PurchaseCategory'] != null) {
  //     //log(jsonEncode(PurchaseCategory.fromJson(response.data['PurchaseCategory'])));
  //     return PurchaseCategory.fromJson(response.data['PurchaseCategory']);
  //   } else {
  //     return PurchaseCategory();
  //   }
  // }

  Future<OpenOrderModel> getOpenOrders(String recordId) async {
    var response = await orderHistoryDataSource.getOpenOrders(recordId);
    if (response.data != null &&
        response.status! &&
        response.data['OpenOrders'] != null) {
      return OpenOrderModel.fromJson(response.data);
    } else {
      return OpenOrderModel(
        openOrders: [],
      );
    }
  }

  Future<List<OrderDetail>> getOrderHistory(String recordId, int page) async {
    print("loading order hist");
    var response = await orderHistoryDataSource.getOrderHistory(recordId, page);
    if (response.data != null &&
        response.status! &&
        response.data['OrderHistory'] != null) {
      return response.data['OrderHistory']
          .map<OrderDetail>((e) => OrderDetail.fromJson(e))
          .toList();
    } else {
      return [];
    }
  }
}
