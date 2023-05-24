import 'dart:convert';
import 'dart:developer';

import 'package:gc_customer_app/bloc/cart_bloc/send_tax_info.dart';
import 'package:gc_customer_app/models/address_models/address_model.dart';
import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';
import 'package:gc_customer_app/models/cart_model/delete_order_model.dart';
import 'package:gc_customer_app/models/cart_model/product_eligibility_model.dart';
import 'package:gc_customer_app/models/cart_model/reason_list_model.dart';
import 'package:gc_customer_app/models/cart_model/tax_model.dart';

import '../../../models/cart_model/assign_user_model.dart';
import '../../../models/cart_model/recommended_address_model.dart';
import '../../../models/cart_model/submit_quote_model.dart';
import '../../../models/user_profile_model.dart';
import '../../data_sources/cart_data_source/cart_data_source.dart';

class CartRepository {
  CartDataSource cartDataSource;
  CartRepository({required this.cartDataSource});

  // Future<dynamic> getOrders(String orderId) async {
  //   return await cartDataSource.getCartItems(orderId);
  // }

  Future<List<UserProfile>> getCustomerSearchByEmail(String email) async {
    var response = await cartDataSource.getCustomerSearchByEmail(email);
    String message = response.message.toString();
    if (response.data != null && response.data['records'] != null) {
      return response.data['records']
          .map<UserProfile>((c) => UserProfile.fromJson(c))
          .toList();
    } else {
      return [];
    }
  }

  Future<List<UserProfile>> getCustomerSearchByPhone(String phone) async {
    var response = await cartDataSource.getCustomerSearchByPhone(phone);
    String message = response.message.toString();
    if (response.data != null && response.data['records'] != null) {
      return response.data['records']
          .map<UserProfile>((c) => UserProfile.fromJson(c))
          .toList();
    } else {
      return [];
    }
  }

  Future<List<AddressList>> saveCartAddresses(
      String recordId, AddressList addressModel, bool isDefault) async {
    var response =
        await cartDataSource.addNewAddress(recordId, addressModel, isDefault);
    String message = response.message.toString();
    if (response.data['addressList'] != null &&
        response.data['addressList'].isNotEmpty) {
      return response.data['addressList']
          .map<AddressList>((c) => AddressList.fromJson(c))
          .toList();
    }
    throw Exception(message);
  }

  Future<List<AddressList>> updateCartAddresses(
      String recordId, AddressList addressModel, bool isDefault) async {
    var response =
        await cartDataSource.updateAddress(recordId, addressModel, isDefault);
    String message = response.message.toString();
    if (response.data['addressList'] != null &&
        response.data['addressList'].isNotEmpty) {
      return response.data['addressList']
          .map<AddressList>((c) => AddressList.fromJson(c))
          .toList();
    }
    throw Exception(message);
  }

  Future<dynamic> getOverrideReasons() async {
    return await cartDataSource.getOverrideReasons();
  }

  Future<dynamic> getShippingOverrideReasons() async {
    return await cartDataSource.getShippingOverrideReasons();
  }

  Future<QuoteSubmitModel> submitQuote(
      String email,
      String phone,
      String expirationDate,
      String orderId,
      String accountId,
      String subTotal,
      String loggedinUserId) async {
    return await cartDataSource.submitQuote(email, phone, expirationDate,
        orderId, accountId, subTotal, loggedinUserId);
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
    return await cartDataSource.sendTaxInfo(
        orderId: orderId,
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        phoneName: phoneName,
        shippingAddress: shippingAddress,
        shippingCity: shippingCity,
        shippingCountry: shippingCountry,
        shippingState: shippingState,
        shippingEmail: shippingEmail,
        shippingZipCode: shippingZipCode);
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
    return await cartDataSource.sendTaxInfoAddress(
        orderId: orderId,
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        phoneName: phoneName,
        shippingAddress: shippingAddress,
        shippingAddress2: shippingAddress2,
        shippingCity: shippingCity,
        shippingCountry: shippingCountry,
        shippingState: shippingState,
        shippingEmail: shippingEmail,
        shippingMethodName: shippingMethodName,
        shippingZipCode: shippingZipCode);
  }

  Future<SendTaxInfoModel> sendTaxInfoDelivery(
      {String? orderId,
      String? storeNumber,
      String? storeCity,
      String? firstName,
      String? lastName,
      String? phone,
      String? email}) async {
    return await cartDataSource.sendTaxInfoDelivery(
        orderId: orderId,
        storeNumber: storeNumber,
        storeCity: storeCity,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone);
  }

  Future<AssignUserModel> assignUser(
      {String? orderId, String? accountId}) async {
    return await cartDataSource.assignUser(
        orderId: orderId, accountID: accountId);
  }

  Future<List<String>> getRecordOptions(
      {String? userId, String? recordType}) async {
    return await cartDataSource.getRecordOptions(
        userId: userId, recordType: recordType);
  }

  Future<SendTaxInfoModel> sendTaxInfoShippingMethod(
      {String? orderId,
      String? shippingMethodName,
      String? shippingMethodPrice,
      String? firstName,
      String? lastName,
      String? phone,
      String? email}) async {
    return await cartDataSource.sendTaxInfoShippingMethod(
        orderId: orderId,
        shippingMethodName: shippingMethodName,
        shippingMethodPrice: shippingMethodPrice,
        email: email,
        phone: phone,
        firstName: firstName,
        lastName: lastName);
  }

  Future<dynamic> updateWarranties(Warranties warranties, String itemId) async {
    return await cartDataSource.updateWarranties(warranties, itemId);
  }

  Future<AddressesModel> fetchAddresses(String recordId) async {
    var response = await cartDataSource.fetchAddresses(recordId);
    if (response != null &&
        response.data != null &&
        response.data["addressList"] != null) {
      return AddressesModel.fromJson(response.data);
    } else {
      return AddressesModel(addressList: [], message: "No Addresses Found");
    }
  }

  Future<ProductEligibility> getItemEligibility(
      String recordId, String userId) async {
    var response = await cartDataSource.getItemEligibility(recordId, userId);
    if (response != null &&
        response.data != null &&
        response.data["moreInfo"] != null) {
      return ProductEligibility.fromJson(response.data);
    } else {
      return ProductEligibility(moreInfo: []);
    }
  }

  Future<ReasonsListModel> getReasonsList() async {
    return await cartDataSource.getReasonsList();
  }

  Future<DeleteOrderModel> deleteOrder(String orderId, String reason) async {
    return await cartDataSource.deleteOrder(orderId, reason);
  }

  Future<dynamic> removeWarranties(Warranties warranties, String itemId) async {
    return await cartDataSource.removeWarranties(warranties, itemId);
  }

  Future<WarrantiesModel> getWarranties(String skuEntId) async {
    return await cartDataSource.getWarranties(skuEntId);
  }

  Future<dynamic> updateCartAdd(
      Items records, String customerID, String orderID, int quantity) async {
    print("call me");
    return await cartDataSource.updateCartAdd(
        records, customerID, orderID, quantity);
  }

  Future<dynamic> updateCartDelete(
      Items records, String customerID, String orderID) async {
    return await cartDataSource.updateCartDelete(records, customerID, orderID);
  }

  Future<dynamic> sendOverrideReasons(
      String orderLineItemID,
      String requestedAmount,
      String reset,
      String selectedOverrideReasons,
      String userID) async {
    print("reset in repo $reset");
    return await cartDataSource.sendOverrideReasons(orderLineItemID,
        requestedAmount, selectedOverrideReasons, reset, userID);
  }

  Future<RecommendedAddressModel> getRecommendedAddress(
      String address1,
      String address2,
      String city,
      String state,
      String postalCode,
      String country,
      bool isShipping,
      bool isBilling) async {
    var response = await cartDataSource.getRecommendedAddress(address1,
        address2, city, state, postalCode, country, isShipping, isBilling);
    if (response.data != null && response.data["addressInfo"] != null) {
      RecommendedAddressModel addressInfo =
          RecommendedAddressModel.fromJson(response.data);
      return addressInfo;
    } else {
      return RecommendedAddressModel(message: "Recommended address not found");
    }
  }

  Future<dynamic> sendShippingOverrideReasons(
      String orderId,
      String requestedAmount,
      String reset,
      String selectedOverrideReasons,
      String userID) async {
    print("reset in repo $reset");
    return await cartDataSource.sendShippingOverrideReasons(
        orderId, requestedAmount, selectedOverrideReasons, reset, userID);
  }

  Future<dynamic> getGiftCardsBalance(String cardNumber, String pin) async {
    var httpResponse =
        await cartDataSource.getGiftCardsBalance(cardNumber, pin);
    return httpResponse.data;
  }

  Future<dynamic> getCOABalance(String email) async {
    var httpResponse = await cartDataSource.getCOABalance(email);
    return httpResponse.data;
  }

  Future<dynamic> getCardsFinancial(String orderId, String loggedUserId) async {
    var httpResponse =
        await cartDataSource.getCardsFinancial(orderId, loggedUserId);
    return httpResponse.data;
  }

  Future<dynamic> getEssentialFinanceMessage(String orderId,
      String loggedUserId, String cardNumber, String pin, String amount) async {
    var httpResponse = await cartDataSource.getEssentialFinanceMessage(
        orderId, loggedUserId, cardNumber, pin, amount);
    return httpResponse.data;
  }

  Future<dynamic> getGearFinanceMessage(
      String orderId, String cardNumber, String pin, String amount) async {
    var httpResponse = await cartDataSource.getGearFinanceMessage(
        orderId, cardNumber, pin, amount);
    return httpResponse.data;
  }

  Future<dynamic> getTaxCalculate(String orderId, String loggedUserId) async {
    var httpResponse =
        await cartDataSource.getTaxCalculate(orderId, loggedUserId);
    return httpResponse.data;
  }

  Future<dynamic> getExistingCards(String email) async {
    var httpResponse = await cartDataSource.getExistingCards(email);
    return httpResponse.data;
  }

  Future<dynamic> applyCoupon(String orderId, String couponId) async {
    var httpResponse = await cartDataSource.applyCoupon(orderId, couponId);
    print('coupon: ${httpResponse.data}');
    return httpResponse.data;
  }

  Future<dynamic> removeCoupon(String orderId) async {
    var httpResponse = await cartDataSource.removeCoupon(orderId);
    return httpResponse.data;
  }

  Future<UserProfile> saveCustomer(
      UserProfile addressModel,
      String address2,
      String proficiencyLevel,
      String playFrequency,
      String playInstruments) async {
    var response = await cartDataSource.saveCustomer(
        userProfile: addressModel,
        address2: address2,
        playFrequency: playFrequency,
        playInstruments: playInstruments,
        proficiencyLevel: proficiencyLevel);
    String message = response.message.toString();
    log(jsonEncode(response.data));
    if (response.data != null &&
        response.data['isSuccess'] != null &&
        response.data['isSuccess'] &&
        response.data['customer'] != null) {
      return UserProfile.fromJson(response.data['customer']);
    } else {
      return UserProfile(id: "N/A", name: "Cannot create new user");
    }
  }
}
