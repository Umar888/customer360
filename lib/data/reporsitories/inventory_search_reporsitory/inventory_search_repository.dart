import 'dart:developer';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';

import '../../../models/cart_model/product_eligibility_model.dart';
import '../../../models/common_models/refinement_model.dart';
import '../../../models/inventory_search/add_search_model.dart';
import '../../data_sources/inventory_search_data_source/inventory_search_data_source.dart';

class InventorySearchRepository {
  InventorySearchDataSource inventorySearchDataSource;
  InventorySearchRepository({required this.inventorySearchDataSource});

  Future<dynamic> fetchSearchedData(String name, int offset) async {
    if(!Platform.environment.containsKey("FLUTTER_TEST")) {
      FirebaseAnalytics.instance.logEvent(name: 'inventory_look_up', parameters: {'name': name});
    }
    return await inventorySearchDataSource.fetchSearchedData(offset, name);
  }

  Future<ProductEligibility> getItemEligibility(
      String recordId, String userId) async {
    var response =
        await inventorySearchDataSource.getItemEligibility(recordId, userId);
    if (response != null &&
        response.data != null &&
        response.data["moreInfo"] != null) {
      return ProductEligibility.fromJson(response.data);
    } else {
      return ProductEligibility(moreInfo: []);
    }
  }

  Future<dynamic> fetchPaginationData(
      {required String searchName,
      required String selectedId,
      required String sortByVal,
      required List<Refinement>? filteredListOfRefinements,
      required String pageSize,
      required int currentPage}) async {
    return await inventorySearchDataSource.getPaginationInventory(
        searchName: searchName,
        selectedId: selectedId,
        sortByVal: sortByVal,
        filteredListOfRefinments: filteredListOfRefinements,
        pageSize: pageSize,
        currentPage: currentPage);
  }

  Future<dynamic> addToCartAndCreateOrder(
      Records records, String customerID, String orderID) async {
    return await inventorySearchDataSource.addToCartAndCreateOrder(
        records, customerID, orderID);
  }

  Future<WarrantiesModel> getWarranties(String skuEntId) async {
    return await inventorySearchDataSource.getWarranties(skuEntId);
  }

  Future<dynamic> updateCartAdd(
      Records records, String customerID, String orderID, int quantity) async {
    return await inventorySearchDataSource.updateCartAdd(
        records, customerID, orderID, quantity);
  }

  Future<dynamic> fetchDataBySearchName({
    required String searchName,
    required String selectedId,
    required String sortedByVal,
    required List<Refinement>? filteredListOfRefinements,
  }) async {
    return await inventorySearchDataSource.getSortedListOfData(
        searchName, filteredListOfRefinements, sortedByVal, selectedId);
  }

  Future<dynamic> updateCartDelete(
      Records records, String customerID, String orderID, int quantity) async {
    log("fom inventory");
    return await inventorySearchDataSource.updateCartDelete(
        records, customerID, orderID, quantity);
  }

  Future<dynamic> applyFilters({
    required String searchName,
    required String selectedId,
    required List<Refinement>? filteredListOfRefinements,
    required String sortedByVal,
  }) async {
    return await inventorySearchDataSource.getSortedListOfData(
        searchName, filteredListOfRefinements, sortedByVal, selectedId);
  }

  Future<dynamic> getDataBySorting(
    String searchName,
    String selectedId,
    String sortedByVal,
    List<Refinement>? filteredListOfRefinements,
  ) async {
    return await inventorySearchDataSource.getSortedListOfData(
        searchName, filteredListOfRefinements, sortedByVal, selectedId);
  }
}
