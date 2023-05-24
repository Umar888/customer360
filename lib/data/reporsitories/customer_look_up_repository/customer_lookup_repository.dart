import 'package:gc_customer_app/data/data_sources/customer_look_up_data_source/customer_lookup_data_source.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';

class CustomerLookUpRepository {
  CustomerLookUpDataSource customerLookUpDataSource =
      CustomerLookUpDataSource();

  Future<List<UserProfile>> getCustomerSearchByEmail(String email) async {
    var response = await customerLookUpDataSource.getCustomerSearchByEmail(email);
        await customerLookUpDataSource.getCustomerSearchByEmailPost(email);
    String message = response.message.toString();
    if (response.data['records'] != null) {
      return response.data['records']
          .map<UserProfile>((c) => UserProfile.fromJson(c))
          .toList();
    }
    throw Exception(message);
  }

  Future<List<String>> getRecordOptions(
      {String? userId, String? recordType}) async {
    return await customerLookUpDataSource.getRecordOptions(
        userId: userId, recordType: recordType);
  }

  Future<List<UserProfile>> getCustomerSearchByPhone(String phone) async {
    var response =
    await customerLookUpDataSource.getCustomerSearchByPhone(phone);
        await customerLookUpDataSource.getCustomerSearchByPhonePost(phone);
    String message = response.message.toString();
    if (response.data['records'] != null) {
      return response.data['records']
          .map<UserProfile>((c) => UserProfile.fromJson(c))
          .toList();
    }
    throw Exception(message);
  }

  Future<List<UserProfile>> getCustomerSearchByName(
      String name, int offset) async {
    var response = await customerLookUpDataSource.getCustomerSearchByName(name, offset);
     await customerLookUpDataSource.getCustomerSearchByNamePost(name);
    String message = response.message.toString();

    if (response.data != null && response.data['records'] != null) {
      return response.data['records']
          .map<UserProfile>((c) => UserProfile.fromJson(c))
          .toList();
    }
    throw [];
  }

  Future<UserProfile> saveCustomer(
      UserProfile addressModel,
      String proficiencyLevel,
      String playFrequency,
      String playInstruments) async {
    var response = await customerLookUpDataSource.saveCustomer(
        addressModel, proficiencyLevel, playFrequency, playInstruments);
    String message = response.message.toString();
    if (response.data != null &&
        response.data['isSuccess'] != null &&
        response.data['isSuccess'] &&
        response.data['customer'] != null) {
      return UserProfile.fromJson(response.data['customer']);
    } else {
      return UserProfile(
          id: "N/A",
          name: response.data["message"] ?? "Cannot create new user");
    }
  }
}
