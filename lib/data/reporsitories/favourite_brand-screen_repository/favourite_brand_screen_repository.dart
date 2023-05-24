import 'dart:convert';
import 'dart:developer';

import 'package:gc_customer_app/data/data_sources/favourite_brand_screen_data_source/favourite_brand_screen_data_source.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart' as asm;

import '../../../models/favorite_brands_model/favorite_brand_detail_model.dart';
import '../../../models/favourite_brand_screen_list.dart';

class FavouriteBrandScreenRepository {
  FavouriteBrandScreenDataSource favouriteBrandScreenDataSource =
      FavouriteBrandScreenDataSource();
  Future<dynamic> getFavrouriteItems(String recordID) async {
    var response =
        await favouriteBrandScreenDataSource.getFavouriteBrandList(recordID);
    if (response.data != null) {
      FavouriteBrandScreenList favouriteBrandScreenList =
          FavouriteBrandScreenList.fromJson(response.data);
      return favouriteBrandScreenList;
    } else {}
  }

  Future<asm.Records> getProductDetail(String recordID, String skuId) async {
    var response =
        await favouriteBrandScreenDataSource.getProductDetail(recordID, skuId);
    if (response.data != null && response.data['wrapperinstance'] != null && response.data['wrapperinstance']['records'] != null && (response.data['wrapperinstance']['records']).isNotEmpty) {
      return asm.Records.fromJson(
          response.data['wrapperinstance']['records'][0]);
    }
    else{
      return asm.Records(childskus: [],quantity: "-1",productId: skuId);
    }
  }

  Future<FavoriteBrandDetailModel> getRecordDetail(String recordID, String brandName, String instrumentName) async {
    var response =
        await favouriteBrandScreenDataSource.getRecordDetail(recordID, brandName,instrumentName);
    if (response.data != null && response.data['wrapperinstance'] != null && response.data['wrapperinstance']['records'] != null && (response.data['wrapperinstance']['records']).isNotEmpty) {
      return FavoriteBrandDetailModel.fromJson(response.data);
    }
    else{
      return FavoriteBrandDetailModel(wrapperinstance: Wrapperinstance(records: []));
    }
  }
}
