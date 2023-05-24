import 'dart:convert';

import 'package:gc_customer_app/models/address_models/address_model.dart';
import 'package:gc_customer_app/models/address_models/verification_address_model.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:gc_customer_app/services/networking/request_body.dart';

class AddressesDataSource {
  HttpService httpService = HttpService();

  Future<HttpResponse> getClientProfileAddresses(String recordId) async {
    var response =
        await httpService.doGet(path: Endpoints.getClientAddresses(recordId));
    return response;
  }

  Future<HttpResponse> getShippingMethods(
      String recordId, String orderId) async {
    var response = await httpService.doGet(
        path: Endpoints.getShippingMethods(recordId, orderId));
    return response;
  }

  Future<HttpResponse> addNewAddress(
      String recordId, AddressList addressModel, bool isDefault) async {
    var response = await httpService.doPost(
      path: Endpoints.saveAddress(),
      body: RequestBody.saveAddressBody(
          recordId: recordId,
          addressLabel: addressModel.addressLabel ?? '',
          address1: addressModel.address1!,
          address2: addressModel.address2 ?? '',
          city: addressModel.city!,
          state: addressModel.state!,
          postalCode: addressModel.postalCode!,
          contactPointId: addressModel.contactPointAddressId,
          isDefault: isDefault),
    );
    return response;
  }

  Future<HttpResponse> updateAddress(
      String recordId, AddressList addressModel, bool isDefault) async {
    var response = await httpService.doPost(
      path: Endpoints.saveAddress(),
      body: RequestBody.saveAddressBody(
          recordId: recordId,
          addressLabel: addressModel.addressLabel!,
          address1: addressModel.address1!,
          address2: addressModel.address2!,
          city: addressModel.city!,
          state: addressModel.state!,
          postalCode: addressModel.postalCode!,
          contactPointId: addressModel.contactPointAddressId,
          isDefault: isDefault),
    );
    return response;
  }

  Future<HttpResponse> verificationAddress(
      String loggedInId, VerifyAddress verifyAddress) async {
    var response = await httpService.doGet(
        path: Endpoints.verificationAddress(
            loggedInId,
            verifyAddress.addressline1 ?? '',
            verifyAddress.addressline2 ?? '',
            verifyAddress.city ?? '',
            verifyAddress.state ?? '',
            verifyAddress.postalcode ?? '',
            verifyAddress.isShipping ?? false,
            verifyAddress.isBilling ?? false));
    return response;
  }
}
