import 'package:gc_customer_app/data/data_sources/order_lookup_data_source/order_lookup_data_source.dart';
import 'package:gc_customer_app/models/order_lookup_model.dart';

class OrderLookUpRepository {
  OrderLookUpDataSource orderLookUpDataSource = OrderLookUpDataSource();

  Future<List<OrderLookupModel>> getOrderLookUp(String searchText) async {
    var response = await orderLookUpDataSource.getOrderLookUp(searchText);

    if (response.data is Map && response.data['responseList'] != null) {
      List<OrderLookupModel> orders = response.data['responseList']
              ?.map<OrderLookupModel>((pr) => OrderLookupModel.fromJson(pr))
              .toList() ??
          <OrderLookupModel>[];
      return orders;
    } else {
      return [];
    }
  }

  Future<List<OrderLookupModel>> getOrderLookUpOpenOrderByOrderNumber(
      String searchText) async {
    var response = await orderLookUpDataSource
        .getOrderLookUpOpenOrderByOrderNumber(searchText);

    if (response.data['responseOpenList'] != null) {
      List<OrderLookupModel> orders = response.data['responseOpenList']
              ?.map<OrderLookupModel>((pr) => OrderLookupModel.fromJson(pr))
              .toList() ??
          <OrderLookupModel>[];
      return orders;
    } else {
      throw (Exception(response.message ?? ''));
    }
  }

  Future<List<OrderLookupModel>> getOrderLookUpOpenOrderByQouteNumber(
      String searchText) async {
    var response = await orderLookUpDataSource
        .getOrderLookUpOpenOrderByQouteNumber(searchText);

    if (response.data['responseOpenList'] != null) {
      List<OrderLookupModel> orders = response.data['responseOpenList']
              ?.map<OrderLookupModel>((pr) => OrderLookupModel.fromJson(pr))
              .toList() ??
          <OrderLookupModel>[];
      return orders;
    } else {
      throw (Exception(response.message ?? ''));
    }
  }
}
