import 'package:gc_customer_app/data/data_sources/profile_screen/addresses_data_source.dart';
import 'package:gc_customer_app/models/address_models/address_model.dart';
import 'package:gc_customer_app/models/address_models/verification_address_model.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';

class AddressesRepository {
  AddressesDataSource addressesDataSource = AddressesDataSource();

  Future<List<AddressList>> getProfileAddresses(String recordId) async {
    var response =
        await addressesDataSource.getClientProfileAddresses(recordId);
    String message = response.message.toString();
    if (response.data['addressList'] != null &&
        response.data['addressList'].isNotEmpty) {
      return response.data['addressList']
          .map<AddressList>((c) => AddressList.fromJson(c))
          .toList();
    }
    throw Exception(message);
  }

  Future<List<AddressList>> saveProfileAddresses(
      String recordId, AddressList addressModel, bool isDefault) async {
    var response = await addressesDataSource.addNewAddress(
        recordId, addressModel, isDefault);
    String message = response.message.toString();
    if (response.data['addressList'] != null &&
        response.data['addressList'].isNotEmpty) {
      return response.data['addressList']
          .map<AddressList>((c) => AddressList.fromJson(c))
          .toList();
    }
    throw Exception(message);
  }

  Future<List<AddressList>> updateProfileAddresses(
      String recordId, AddressList addressModel, bool isDefault) async {
    var response = await addressesDataSource.updateAddress(
        recordId, addressModel, isDefault);
    String message = response.message.toString();
    if (response.data['addressList'] != null &&
        response.data['addressList'].isNotEmpty) {
      return response.data['addressList']
          .map<AddressList>((c) => AddressList.fromJson(c))
          .toList();
    }
    throw Exception(message);
  }

  Future<VerificationAddressModel> verificationAddress(
      String loggedInId, VerifyAddress verifyAddress) async {
    var response = await addressesDataSource.verificationAddress(
        loggedInId, verifyAddress);
    String message = response.message.toString();
    if (response.data['addressInfo'] != null) {
      return VerificationAddressModel.fromJson(response.data['addressInfo']);
    }
    throw Exception(message);
  }
}
