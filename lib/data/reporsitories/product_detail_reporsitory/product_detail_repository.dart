import 'package:gc_customer_app/data/data_sources/product_detail_data_source/product_detail_data_source.dart';
import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';
import 'package:gc_customer_app/models/cart_model/product_eligibility_model.dart';

import 'package:gc_customer_app/models/common_models/records_class_model.dart';
import 'package:gc_customer_app/models/product_detail_model/bundle_model.dart';

class ProductDetailRepository {
  ProductDetailDataSource productDetailDataSource;
  ProductDetailRepository({required this.productDetailDataSource});

  Future<dynamic> getAddress(String skuENTId) async {
    return await productDetailDataSource.getAddresses(skuENTId);
  }

  Future<WarrantiesModel> showProCoverageModel(String skuENTId) async {
    return await productDetailDataSource.getWarranties(skuENTId);
  }

  Future<ProductDetailBundlesModel> getProductBundle(String skuENTId) async {
    var response = await productDetailDataSource.getBundles(skuENTId);
    if (response.data != null &&
        response.data['productRecommands'] != null &&
        response.data['productRecommands'].isNotEmpty) {
      return ProductDetailBundlesModel.fromJson(response.data);
    } else {
      return ProductDetailBundlesModel(productRecommands: []);
    }
  }

  Future<ProductEligibility> getItemEligibility(
      String recordId, String userId) async {
    var response =
        await productDetailDataSource.getItemEligibility(recordId, userId);
    if (response != null &&
        response.data != null &&
        response.data["moreInfo"] != null) {
      return ProductEligibility.fromJson(response.data);
    } else {
      return ProductEligibility(moreInfo: []);
    }
  }

  Future<Records> getProductDetail(String recordID, String skuId) async {
    var response =
        await productDetailDataSource.getProductDetail(recordID, skuId);
    if (response.data != null &&
        response.data['wrapperinstance'] != null &&
        response.data['wrapperinstance']['records'] != null &&
        (response.data['wrapperinstance']['records']).isNotEmpty) {
      return Records.fromJson(response.data['wrapperinstance']['records'][0]);
    } else {
      return Records(childskus: [], quantity: "-1", productId: skuId);
    }
  }

  Future<dynamic> addToCartAndCreateOrder(
      Records records, String customerID, String orderID) async {
    return await productDetailDataSource.addToCartAndCreateOrder(
        records, customerID, orderID);
  }

  Future<dynamic> updateCartAdd(
      Records records, String customerID, String orderID, int quantity) async {
    return await productDetailDataSource.updateCartAdd(
        records, customerID, orderID, quantity);
  }

  Future<dynamic> updateCartDelete(
      Records records, String customerID, String orderID, int quantity) async {
    return await productDetailDataSource.updateCartDelete(
        records, customerID, orderID, quantity);
  }

  Future selectInventoryReason(String orderId, String nodeId, int stockLevel,
      String sourcingReason) async {
    return await productDetailDataSource.selectInventoryReason(
        orderId, nodeId, stockLevel, sourcingReason);
  }
}
