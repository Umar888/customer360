import 'dart:convert';

import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/services/networking/request_body.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';

import '../../../models/common_models/refinement_model.dart';
import '../../../models/inventory_search/add_search_model.dart';
import '../../../services/networking/endpoints.dart';
import '../../../services/networking/http_response.dart';

class InventorySearchDataSource {
  final HttpService httpService = HttpService();

  Future<dynamic> fetchSearchedData(int offset,String name) async{
    var response = await httpService
        .doPost(path: Endpoints.getSearchDetail(), body:
    RequestBody.getSearchDataInventory(
        offset: offset,
        name: name
    ));
    return response;
  }
  Future<HttpResponse> getItemEligibility(
      String itemSKuID, String loggedInUserId) async {
    var response = await httpService.doGet(
        path: Endpoints.getItemEligibility(itemSKuID, loggedInUserId));
    return response;
  }
  Future<dynamic> getPaginationInventory({required String? searchName, required String?selectedId,String? sortByVal,
      required List<Refinement>? filteredListOfRefinments,required  String? pageSize,required int? currentPage}) async{
        List<dynamic> listOfItems = [];
    List<String> sectionChckBoxLst = [];
    if (filteredListOfRefinments!.isNotEmpty) {
      for (var i = 0; i < filteredListOfRefinments.length; i++) {
        listOfItems.add(filteredListOfRefinments[i].toJson());
        sectionChckBoxLst.add(jsonEncode(listOfItems[i]['id']));
      }
    }
    print(sectionChckBoxLst);
    var response = await httpService
        .doPost(path: Endpoints.getSearchDetail(), body:
    RequestBody.getPaginationData(
        searchName: searchName,
          selectedID: selectedId,
          sortByVal: sortByVal,
          sectionChckBoxLst: sectionChckBoxLst,
          pageSize: pageSize.toString(),
          currentPage: currentPage
    ));
    return response;
  }

  Future<WarrantiesModel> getWarranties(String skuEntId) async{
    var response =await httpService
        .doGet(path: Endpoints.getWarranties(skuEntId));
    if(response != null && response.data != null && response.data["Warranties"] != null &&  response.data["Warranties"].isNotEmpty){
      return WarrantiesModel.fromJson(response.data);
    }
    else{
      return WarrantiesModel(warranties: []);
    }
  }
  Future<dynamic> addToCartAndCreateOrder(Records records,String customerID, String orderID) async{
    var response = await httpService
        .doPost(path: Endpoints.addToCartAndCreateOrder(), body: RequestBody.getAddToCartAndCreateOrder(records: records, orderId: orderID, customerID: customerID),tokenRequired: true);
    return response;
  }

  Future<dynamic> updateCartAdd(Records records,String customerID, String orderID,int quantity) async{
    var response = await httpService
        .doPatch(path: Endpoints.updateCartAndCreateOrder()+records.oliRecId!, body: json.encode(RequestBody.getUpdateCartAdd(quantity: quantity)),tokenRequired: true);
    return response;
  }

  Future<dynamic> updateCartDelete(Records records,String customerID, String orderID,int quantity) async{
    var response = await httpService
        .doPatch(path: Endpoints.updateCartAndCreateOrder()+records.oliRecId!, body: json.encode(RequestBody.getUpdateCartDeleted()),tokenRequired: true);
    return response;
  }
  Future<dynamic> getDataWithFilters(String searchName, String selectedId,
      List<Refinement>? filteredListOfRefinments) async {
    List<dynamic> listOfItems = [];
    List<String> sectionChckBoxLst = [];
    if (filteredListOfRefinments!.isNotEmpty) {
      for (var i = 0; i < filteredListOfRefinments.length; i++) {
        listOfItems.add(filteredListOfRefinments[i].toJson());
        sectionChckBoxLst.add(jsonEncode(listOfItems[i]['id']));
      }
    }
    print(sectionChckBoxLst);
    var response = await httpService.doPost(
      path: Endpoints.getSearchDetail(),
      body: RequestBody.getFilteredData(
          searchName: searchName,
          selectedID: selectedId,
          sectionChckBoxLst: sectionChckBoxLst),
    );
    return response;
  }

  Future<dynamic> getSortedListOfData(
      String searchName,
      List<Refinement>? filteredListOfRefinements,
      String? sortedByVal,
      String selectedId,
      ) async {
    List<dynamic> listOfItems = [];
    List<String> sectionCheckBoxLst = [];

    if (filteredListOfRefinements!.isNotEmpty) {
      for (var i = 0; i < filteredListOfRefinements.length; i++) {
        listOfItems.add(filteredListOfRefinements[i].toJson());
        sectionCheckBoxLst.add(jsonEncode(listOfItems[i]['id']));
      }
    }
    print(sectionCheckBoxLst);

    var response = await httpService.doPost(
      path: Endpoints.getSearchDetail(),
      body: RequestBody.getSortedListOfData(
        searchName: searchName,
        sectionCheckBoxLst: sectionCheckBoxLst,
        sortByVal: sortedByVal,
        selectedID: selectedId.isEmpty?'':selectedId,
      ),
    );
    return response;
  }
}