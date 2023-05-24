import 'dart:convert';
import 'dart:developer';

import 'package:gc_customer_app/bloc/cart_bloc/send_tax_info.dart';
import 'package:gc_customer_app/models/address_models/address_model.dart';
import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';
import 'package:gc_customer_app/models/cart_model/delete_order_model.dart';
import 'package:gc_customer_app/models/cart_model/reason_list_model.dart';
import 'package:gc_customer_app/models/cart_model/submit_quote_model.dart';
import 'package:gc_customer_app/models/cart_model/tax_model.dart';

import '../../../models/cart_model/assign_user_model.dart';
import '../../../models/user_profile_model.dart';
import '../../../services/networking/endpoints.dart';
import '../../../services/networking/networking_service.dart';
import '../../../services/networking/request_body.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';

class CartDataSource {
  HttpService httpService = HttpService();

  Future<dynamic> getCartItems(String orderId) async {
    var response =
        await httpService.doGet(path: Endpoints.getPastOrderDetail(orderId));
    return response;
  }

  Future<HttpResponse> getCustomerSearchByEmail(String email) async {
    var response = await httpService.doGet(
        path: Endpoints.getCustomerSearchByEmail(email));
    return response;
  }

  Future<HttpResponse> saveCustomer(
      {required UserProfile userProfile,
      String? address2,
      String? proficiencyLevel,
      String? playFrequency,
      String? playInstruments}) async {
    var response = await httpService.doPost(
      path: Endpoints.saveNewCustomer(),
      body: RequestBody.saveCustomerBody(
        firstName: userProfile.firstName!,
        playFrequency: playFrequency,
        preferredInstrument: playInstruments,
        proficiencyLevel: proficiencyLevel,
        lastName: userProfile.lastName!,
        email: userProfile.accountEmailC!,
        phone: userProfile.accountPhoneC!,
        address1: userProfile.personMailingStreet!,
        address2: address2 ?? "",
        city: userProfile.personMailingCity!,
        state: userProfile.personMailingState!,
        postalCode: userProfile.personMailingPostalCode!,
      ),
    );
    return response;
  }

  Future<HttpResponse> getCustomerSearchByPhone(String phone) async {
    var response = await httpService.doGet(
        path: Endpoints.getCustomerSearchByPhone(phone));
    return response;
  }

  Future<dynamic> getOverrideReasons() async {
    var response =
        await httpService.doGet(path: Endpoints.getOverrideReasons());
    return response;
  }

  Future<dynamic> getShippingOverrideReasons() async {
    var response =
        await httpService.doGet(path: Endpoints.getShippingOverrideReasons());
    return response;
  }

  Future<dynamic> getAddress() async {
    var response =
        await httpService.doGet(path: Endpoints.getOverrideReasons());
    return response;
  }

  Future<dynamic> fetchAddresses(String recordId) async {
    var response =
        await httpService.doGet(path: Endpoints.getOrderAddresses(recordId));
    return response;
  }

  Future<HttpResponse> getItemEligibility(
      String itemSKuID, String loggedInUserId) async {
    var response = await httpService.doGet(
        path: Endpoints.getItemEligibility(itemSKuID, loggedInUserId));
    return response;
  }

  Future<dynamic> fetchShippingMethods(String recordId, String orderId) async {
    var response = await httpService.doGet(
        path: Endpoints.getShippingMethods(recordId, orderId));
    return response;
  }

  Future<QuoteSubmitModel> submitQuote(
      String email,
      String phone,
      String expirationDate,
      String orderId,
      String accountId,
      String subTotal,
      String loggedinUserId) async {
    var response = await httpService.doPost(
        path: Endpoints.submitQuote(),
        body: RequestBody.submitQuote(email, phone, expirationDate, orderId,
            accountId, subTotal, loggedinUserId));
    if (response != null &&
        response.data != null &&
        response.data["isSuccess"] != null &&
        response.data["isSuccess"] == true) {
      return QuoteSubmitModel.fromJson(response.data);
    } else {
      return QuoteSubmitModel(isSuccess: false, message: "");
    }
  }

  Future<HttpResponse> addNewAddress(
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

  Future<WarrantiesModel> getWarranties(String skuEntId) async {
    var response =
        await httpService.doGet(path: Endpoints.getWarranties(skuEntId));
    if (response != null &&
        response.data != null &&
        response.data["Warranties"] != null &&
        response.data["Warranties"].isNotEmpty) {
      return WarrantiesModel.fromJson(response.data);
    } else {
      return WarrantiesModel(warranties: []);
    }
  }

  Future<ReasonsListModel> getReasonsList() async {
    var response = await httpService.doGet(path: Endpoints.getReasons());
    if (response != null &&
        response.data != null &&
        response.data["nlnReasonList"] != null &&
        response.data["nlnReasonList"].isNotEmpty) {
      return ReasonsListModel.fromJson(response.data);
    } else {
      return ReasonsListModel(nlnReasonList: []);
    }
  }

  Future<DeleteOrderModel> deleteOrder(String orderId, String reason) async {
    var response = await httpService.doPatch(
        path: Endpoints.deleteOrder(orderId),
        body: json.encode(RequestBody.deleteOrder(reason)));
    if (response != null &&
        response.data != null &&
        response.data["order"] != null) {
      return DeleteOrderModel.fromJson(response.data);
    } else {
      return DeleteOrderModel(
          message: "Failed to delete order", order: Order(id: "-1"));
    }
  }

  Future<SendTaxInfoModel> sendTaxInfo({
    String? orderId,
    String? firstName,
    String? middleName,
    String? lastName,
    String? phoneName,
    String? shippingAddress,
    String? shippingCity,
    String? shippingState,
    String? shippingCountry,
    String? shippingZipCode,
    String? shippingEmail,
  }) async {
    var response = await httpService.doPatch(
        path: Endpoints.sendTaxInfo(orderId!),
        body: json.encode(RequestBody.sendTaxInfo(
            firstName: firstName,
            lastName: lastName,
            middleName: middleName,
            phoneName: phoneName,
            shippingAddress: shippingAddress,
            shippingCity: shippingCity,
            shippingCountry: shippingCountry,
            shippingState: shippingState,
            shippingEmail: shippingEmail,
            shippingZipCode: shippingZipCode)));
    if (response != null &&
        response.data != null &&
        response.data["isSuccess"] != null) {
      return SendTaxInfoModel.fromJson(response.data);
    } else {
      return SendTaxInfoModel(isSuccess: false);
    }
  }

  Future<SendTaxInfoModel> sendTaxInfoAddress({
    String? orderId,
    String? firstName,
    String? middleName,
    String? lastName,
    String? phoneName,
    String? shippingAddress,
    String? shippingAddress2,
    String? shippingCity,
    String? shippingState,
    String? shippingCountry,
    String? shippingZipCode,
    String? shippingMethodName,
    String? shippingEmail,
  }) async {
    var response = await httpService.doPatch(
        path: Endpoints.sendTaxInfo(orderId!),
        body: json.encode(RequestBody.sendTaxInfoAddress(
            firstName: firstName,
            lastName: lastName,
            middleName: middleName,
            phoneName: phoneName,
            shippingAddress: shippingAddress,
            shippingAddress2: shippingAddress2,
            shippingMethodName: shippingMethodName,
            shippingCity: shippingCity,
            shippingCountry: shippingCountry,
            shippingState: shippingState,
            shippingEmail: shippingEmail,
            shippingZipCode: shippingZipCode)));
    if (response != null &&
        response.data != null &&
        response.data["isSuccess"] != null) {
      return SendTaxInfoModel.fromJson(response.data);
    } else {
      return SendTaxInfoModel(isSuccess: false);
    }
  }

  Future<SendTaxInfoModel> sendTaxInfoDelivery(
      {String? orderId,
      String? storeNumber,
      String? storeCity,
      String? firstName,
      String? lastName,
      String? phone,
      String? email}) async {
    print(jsonEncode(RequestBody.sendTaxInfoDelivery(
        storeCity: storeCity,
        storeNumber: storeNumber,
        email: email,
        phone: phone,
        firstName: firstName,
        lastName: lastName)));
    var response = await httpService.doPatch(
        path: Endpoints.sendTaxInfo(orderId!),
        body: json.encode(RequestBody.sendTaxInfoDelivery(
            storeCity: storeCity,
            storeNumber: storeNumber,
            email: email,
            phone: phone,
            firstName: firstName,
            lastName: lastName)));
    if (response != null &&
        response.data != null &&
        response.data["isSuccess"] != null) {
      return SendTaxInfoModel.fromJson(response.data);
    } else {
      return SendTaxInfoModel(isSuccess: false);
    }
  }

  Future<AssignUserModel> assignUser(
      {String? accountID, String? orderId}) async {
    var response = await httpService.doPatch(
        path: Endpoints.sendTaxInfo(orderId!),
        body: json.encode(RequestBody.assignUser(accountId: accountID)));
    if (response != null &&
        response.data != null &&
        response.data["isSuccess"] != null) {
      log(jsonEncode(response.data));
      return AssignUserModel.fromJson(response.data);
    } else {
      return AssignUserModel(isSuccess: false);
    }
  }

  Future<List<String>> getRecordOptions(
      {String? userId, String? recordType}) async {
    var response = await httpService.doGet(
        path: Endpoints.getRecordOptions(userId!, recordType!));
    if (response.data != null) {
      log(jsonEncode(response.data));
      List<String> list = [];
      if (recordType == "ProficiencyLevel") {
        if (response.data["ProficiencyLevel"] != null) {
          for (int k = 0; k < response.data["ProficiencyLevel"].length; k++) {
            list.add(response.data["ProficiencyLevel"][k].toString());
          }
          return list;
        } else {
          return [];
        }
      } else if (recordType == "PreferredInstrument") {
        if (response.data["PreferredInstrument"] != null) {
          for (int k = 0;
              k < response.data["PreferredInstrument"].length;
              k++) {
            list.add(response.data["PreferredInstrument"][k].toString());
          }
          return list;
        } else {
          return [];
        }
      } else if (recordType == "PlayFrequency") {
        if (response.data["PlayFrequency"] != null) {
          for (int k = 0; k < response.data["PlayFrequency"].length; k++) {
            list.add(response.data["PlayFrequency"][k].toString());
          }
          return list;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<SendTaxInfoModel> sendTaxInfoShippingMethod(
      {String? orderId,
      String? shippingMethodName,
      String? shippingMethodPrice,
      String? firstName,
      String? lastName,
      String? phone,
      String? email}) async {
    print(jsonEncode(RequestBody.sendTaxInfoShippingMethod(
        shippingMethodName: shippingMethodName,
        shippingMethodPrice: shippingMethodPrice,
        email: email,
        phone: phone,
        firstName: firstName,
        lastName: lastName)));
    var response = await httpService.doPatch(
        path: Endpoints.sendTaxInfo(orderId!),
        body: json.encode(RequestBody.sendTaxInfoShippingMethod(
            shippingMethodName: shippingMethodName,
            shippingMethodPrice: shippingMethodPrice,
            email: email,
            phone: phone,
            firstName: firstName,
            lastName: lastName)));
    if (response != null &&
        response.data != null &&
        response.data["isSuccess"] != null) {
      return SendTaxInfoModel.fromJson(response.data);
    } else {
      return SendTaxInfoModel(isSuccess: false);
    }
  }

  Future<dynamic> updateWarranties(Warranties warranties, String itemId) async {
    var response = await httpService.doPost(
        path: Endpoints.updateWarranties(),
        body: RequestBody.updateWarranties(
            orderLineItemId: itemId,
            warrantyId: warranties.id!,
            price: warranties.price.toString(),
            enterpriseSkuId: warranties.enterpriseSkuId,
            displayName: warranties.displayName,
            styleDescription1: warranties.styleDescription1,
            reset: ""));
    return response;
  }

  Future<dynamic> removeWarranties(Warranties warranties, String itemId) async {
    var response = await httpService.doPost(
        path: Endpoints.updateWarranties(),
        body: RequestBody.updateWarranties(
            orderLineItemId: itemId,
            warrantyId: warranties.id!,
            price: warranties.price.toString(),
            enterpriseSkuId: warranties.enterpriseSkuId,
            displayName: warranties.displayName,
            styleDescription1: warranties.styleDescription1,
            reset: "reset"));
    return response;
  }

  Future<dynamic> sendOverrideReasons(
      String orderLineItemID,
      String requestedAmount,
      String selectedOverrideReasons,
      String reset,
      String userID) async {
    print("reset in source $reset");
    var response = await httpService.doPost(
        path: Endpoints.sendOverrideRequest(),
        body: RequestBody.getSendOverrideRequest(
            orderLineItemID: orderLineItemID,
            requestedAmount: requestedAmount,
            reset: reset,
            selectedOverrideReasons: selectedOverrideReasons,
            userID: userID));
    return response;
  }

  Future<dynamic> getRecommendedAddress(
      String address1,
      String address2,
      String city,
      String state,
      String postalCode,
      String country,
      bool isShipping,
      bool isBilling) async {
    var response = await httpService.doGet(
        path: Endpoints.getRecommendedAddress(address1, address2, city, state,
            postalCode, country, isShipping, isBilling));
    return response;
  }

  Future<dynamic> sendShippingOverrideReasons(
      String orderId,
      String requestedAmount,
      String selectedOverrideReasons,
      String reset,
      String userID) async {
    print("reset in source $reset");
    var response = await httpService.doPost(
        path: Endpoints.sendShippingOverrideRequest(),
        body: RequestBody.getSendShippingOverrideRequest(
            orderId: orderId,
            requestedAmount: requestedAmount,
            reset: reset,
            selectedOverrideReasons: selectedOverrideReasons,
            userID: userID));
    return response;
  }

  Future<dynamic> updateCartAdd(
      Items records, String customerID, String orderID, int quantity) async {
    var response = await httpService.doPatch(
        path: Endpoints.updateCartAndCreateOrder() + records.itemId!,
        body: json.encode(RequestBody.getUpdateCartAdd(quantity: quantity)),
        tokenRequired: true);
    return response;
  }

  Future<dynamic> updateCartDelete(
      Items records, String customerID, String orderID) async {
    print("del me");
    var response = await httpService.doPatch(
        path: Endpoints.updateCartAndCreateOrder() + records.itemId!,
        body: json.encode(RequestBody.getUpdateCartDeleted()),
        tokenRequired: true);
    return response;
  }

  Future<HttpResponse> getGiftCardsBalance(
      String cardNumber, String pin) async {
    var response = await httpService.doGet(
        path: Endpoints.getGiftCardsBalance(cardNumber, pin));
    return response;
  }

  Future<HttpResponse> getCOABalance(String email) async {
    var response =
        await httpService.doGet(path: Endpoints.getCOABalance(email));
    return response;
  }

  Future<HttpResponse> getCardsFinancial(
      String orderId, String loggedUserId) async {
    print(Endpoints.getFinancialCards(orderId, loggedUserId));
    var response = await httpService.doGet(
        path: Endpoints.getFinancialCards(orderId, loggedUserId));
    return response;
  }

  Future<HttpResponse> getEssentialFinanceMessage(String orderId,
      String loggedUserId, String cardNumber, String pin, String amount) async {
    print(Endpoints.getEssentialFinanceMessage(
        orderId, loggedUserId, cardNumber, pin, amount));
    var response = await httpService.doGet(
        path: Endpoints.getEssentialFinanceMessage(
            orderId, loggedUserId, cardNumber, pin, amount));
    return response;
  }

  Future<HttpResponse> getGearFinanceMessage(
      String orderId, String cardNumber, String pin, String amount) async {
    var response = await httpService.doGet(
        path:
            Endpoints.getGearFinanceMessage(orderId, cardNumber, pin, amount));
    return response;
  }

  Future<HttpResponse> getTaxCalculate(
      String orderId, String loggedUserId) async {
    var response = await httpService.doGet(
        path: Endpoints.getCalculatedTax(orderId, loggedUserId));
    return response;
  }

  Future<HttpResponse> getExistingCards(String email) async {
    var response =
        await httpService.doGet(path: Endpoints.getExistingCards(email));
    return response;
  }

  Future<HttpResponse> applyCoupon(String orderId, String couponId) async {
    var response = await httpService.doPatch(
        path: Endpoints.applyCoupon(orderId),
        body: json.encode({'Discount_Code__c': couponId}));
    return response;
  }

  Future<HttpResponse> removeCoupon(String orderId) async {
    var response = await httpService.doPatch(
        path: Endpoints.applyCoupon(orderId),
        body: json.encode({
          "Discount_Code__c": "",
          "Discount_Codes__c": "",
          "Discounts__c": ""
        }));
    return response;
  }
}
