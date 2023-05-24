import 'dart:convert';
import 'dart:developer';
import 'package:gc_customer_app/data/data_sources/search_places/search_places_data_source.dart';
import '../../../models/search_places/search_places_model.dart';


class SearchPlacesRepository {

  SearchPlacesDataSource searchPlacesDataSource =  SearchPlacesDataSource();

  Future<SearchPlacesListModel> fetchEventList(query) async{
    var response  = await searchPlacesDataSource.fetchSearchList(query);
    log(jsonEncode(response.data));
    if(response.data != null && response.data["autoCompleteAddressList"] != null){
      SearchPlacesListModel searchPlacesListModel=  SearchPlacesListModel.fromJson(response.data);
      return searchPlacesListModel;
    }
    else{
      return SearchPlacesListModel(autoCompleteAddressList:[]);
    }
  }
}