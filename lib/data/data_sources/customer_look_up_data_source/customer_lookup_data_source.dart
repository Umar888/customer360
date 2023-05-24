import 'dart:convert';

import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/services/networking/request_body.dart';

class CustomerLookUpDataSource {
  final HttpService httpService = HttpService();

  Future<HttpResponse> getCustomerSearchByPhone(String phone) async {
    var response = await httpService.doGet(
        path: Endpoints.getCustomerSearchByPhone(phone));
    return response;
  }
  Future<List<String>> getRecordOptions({String? userId, String? recordType}) async {
    var response = await httpService.doGet(path: Endpoints.getRecordOptions(userId!,recordType!));
    if (response.data != null) {
      List<String> list = [];
      if(recordType == "ProficiencyLevel"){
        if(response.data["ProficiencyLevel"] != null){
          for(int k=0;k<response.data["ProficiencyLevel"].length;k++){
            list.add(response.data["ProficiencyLevel"][k].toString());
          }
          return list;
        }
        else{
          return [];
        }
      }
      else if(recordType == "PreferredInstrument"){
        if(response.data["PreferredInstrument"] != null){
          for(int k=0;k<response.data["PreferredInstrument"].length;k++){
            list.add(response.data["PreferredInstrument"][k].toString());
          }
          return list;
        }
        else{
          return [];
        }
      }
      else if(recordType == "PlayFrequency"){
        if(response.data["PlayFrequency"] != null){
          for(int k=0;k<response.data["PlayFrequency"].length;k++){
            list.add(response.data["PlayFrequency"][k].toString());
          }
          return list;
        }
        else{
          return [];
        }
      }
      else{
        return [];
      }
    }
    else {
      return [];
    }
  }

  Future<HttpResponse> getCustomerSearchByEmail(String email) async {
    var response = await httpService.doGet(
        path: Endpoints.getCustomerSearchByEmail(email));
    return response;
  }

  Future<HttpResponse> getCustomerSearchByName(String name, int offset) async {
    var response = await httpService.doGet(
        path: Endpoints.getCustomerSearchByName(name, offset));
    return response;
  }

  Future<HttpResponse> getCustomerSearchByNamePost(String name) async {
    var response = await httpService.doPost(
        path: Endpoints.getCustomerSearchPost(),
        body: RequestBody.searchByName(name: name));
    return response;
  }

  Future<HttpResponse> getCustomerSearchByEmailPost(String email) async {
    var response = await httpService.doPost(
        path: Endpoints.getCustomerSearchPost(),
        body: RequestBody.searchByEmail(email: email));
    return response;
  }

  Future<HttpResponse> getCustomerSearchByPhonePost(String phone) async {
    var response = await httpService.doPost(
        path: Endpoints.getCustomerSearchPost(),
        body: RequestBody.searchByPhone(phone: phone));
    return response;
  }

  Future<HttpResponse> saveCustomer(UserProfile userProfile,String? proficiencyLevel,String? playFrequency,String? playInstruments) async {
    var response = await httpService.doPost(
      path: Endpoints.saveNewCustomer(),
      body: RequestBody.saveCustomerBody(
        firstName: userProfile.firstName!,
        lastName: userProfile.lastName!,
        playFrequency: playFrequency,
        preferredInstrument: playInstruments,
        proficiencyLevel: proficiencyLevel,
        email: userProfile.accountEmailC!,
        phone: userProfile.accountPhoneC!,
        address1: userProfile.personMailingStreet!,
        address2: userProfile.personMailingStreet2,
        city: userProfile.personMailingCity!,
        state: userProfile.personMailingState!,
        postalCode: userProfile.personMailingPostalCode!,
      ),
    );
    return response;
  }
}
