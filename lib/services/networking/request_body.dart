import 'dart:convert';
import 'dart:developer';

import 'package:gc_customer_app/models/add_commission_model/create_commission_model.dart';
import 'package:gc_customer_app/models/cart_model/discount_model.dart';
import 'package:gc_customer_app/models/store_search_zip_code_model/search_store_zip.dart';
import 'package:gc_customer_app/models/task_detail_model/order.dart';
import 'package:intl/intl.dart';

import '../../intermediate_widgets/credit_card_widget/model/credit_card_model_save.dart';
import '../../models/add_commission_model/selected_employee_json_model.dart';
import '../../models/common_models/records_class_model.dart';
import '../../models/inventory_search/add_search_model.dart';

abstract class RequestBody {
  static Map<String, dynamic> getMetricsAndSmartTriggersBody(
      String tabName, String userId) {
    return {
      'TabName': tabName,
      'UserId': userId,
    };
  }

  static Map<String, dynamic> saveReminderBody({
    required String note,
    required DateTime dueDate,
    required String id,
    required String recordId,
    String? alertType,
    String? accountName,
  }) {
    final format = DateFormat('yyyy-MM-dd');
    return {
      'loggedinUserId': id,
      'recordId': recordId,
      'note': note,
      'dueDate': format.format(dueDate),
      'subject': '',
      'alertType': alertType ?? '$accountName - Internal',
    };
  }

  static Map<String, dynamic> updateReminderBody({
    required String note,
    required DateTime dueDate,
    required String id,
    required String reminderId,
    required String recordId,
    String? alertType,
    String? accountName,
  }) {
    final format = DateFormat('yyyy-MM-dd');
    return {
      'loggedinUserId': id,
      'recordId': recordId,
      'note': note,
      'taskId': reminderId,
      'dueDate': format.format(dueDate),
      'subject': '',
      'alertType': alertType ?? '$accountName - Internal',
    };
  }
  static Map<String, dynamic> getCustomTokenBody({
    String? clientId,
    String? returnUrl,
    String? deviceId,
  }) {
    return {'clientId': clientId ?? '', 'returnUrl': returnUrl ?? '', 'deviceId': deviceId ?? ''};
  }

  static Map<String, dynamic> getAssignAgentBody(
      String recordId, String agentId) {
    return {
      'recordId': recordId,
      'agentId': agentId,
    };
  }

  static Map<String, dynamic> submitQuote(
      String email,
      String phone,
      String expirationDate,
      String orderId,
      String accountId,
      String subTotal,
      String loggedinUserId) {
    return {
      "email": email,
      "phone": phone,
      "expirationDate": expirationDate,
      "orderId": orderId,
      "accountId": accountId,
      "subTotal": subTotal,
      "loggedinUserId": loggedinUserId
    };
  }

  static Map<String, dynamic> deleteOrder(String reason) {
    return {"Order_Status__c": "ClosedLost", "NLN_Reason__c": reason};
  }

  static Map<String, dynamic> sendTaxInfo({
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
  }) {
    return {
      "First_Name__c": firstName ?? "",
      "Middle_Name__c": middleName ?? "",
      "Last_Name__c": lastName ?? "",
      "Phone__c": phoneName ?? "",
      "Shipping_Address__c": shippingAddress ?? "",
      "Shipping_City__c": shippingCity ?? "",
      "Shipping_State__c": shippingState ?? "",
      "Shipping_Country__c": shippingCountry ?? "",
      "Shipping_Zip_code__c": shippingZipCode ?? "",
      "Shipping_Email__c": shippingEmail ?? ""
    };
  }

  static Map<String, dynamic> sendTaxInfoAddress({
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
  }) {
    return {
      "First_Name__c": firstName ?? "",
      "Middle_Name__c": middleName ?? "",
      "Last_Name__c": lastName ?? "",
      "Phone__c": phoneName ?? "",
      "Shipping_Address__c": shippingAddress ?? "",
      "Shipping_Address_2__c": shippingAddress2 ?? "",
      "Shipping_City__c": shippingCity ?? "",
      "Shipping_State__c": shippingState ?? "",
      "Shipping_Country__c": shippingCountry ?? "",
      "Shipping_Zip_code__c": shippingZipCode ?? "",
      "Shipping_Email__c": shippingEmail ?? "",
      "Shipping_Method__c": shippingMethodName,
      "Shipping_Method_Number__c":
      "${shippingMethodName == "Economy" ? "01" :
      shippingMethodName == "Second Day Express" ? "03" :
      shippingMethodName == "Next Day Air" ? "52":
      shippingMethodName == "Digital Delivery" ? "99" : ""}",
      "Delivery_Option__c":
          "${shippingMethodName == "Pick From Store" ? "Pick From Store" : "Ship To Home"}",
    };
  }

  static Map<String, dynamic> sendTaxInfoDelivery(
      {String? storeNumber,
      String? storeCity,
      String? firstName,
      String? lastName,
      String? phone,
      String? email}) {
    return {
      "First_Name__c": firstName ?? '',
      "Middle_Name__c": "",
      "Last_Name__c": lastName ?? '',
      "Phone__c": phone ?? '',
      "Shipping_Email__c": email ?? '',
      "Delivery_Option__c": "Pick From Store",
      "Shipping_Method__c": "Pick From Store",
      "Shipping_Method_Number__c": "00",
      "Store__c": storeNumber ?? "",
      "Selected_Store_City__c": storeCity ?? ""
    };
  }

  static Map<String, dynamic> assignUser({String? accountId}) {
    return {
      "Customer__c": accountId ?? "",
    };
  }

  static Map<String, dynamic> sendTaxInfoShippingMethod(
      {String? shippingMethodName,
      String? shippingMethodPrice,
      String? firstName,
      String? lastName,
      String? phone,
      String? email}) {
    return {
      "First_Name__c": firstName ?? '',
      "Middle_Name__c": "",
      "Last_Name__c": lastName ?? '',
      "Phone__c": phone ?? '',
      "Shipping_Email__c": email ?? '',
      "Shipping_Method__c": shippingMethodName,
      "Delivery_Option__c":
          "${shippingMethodName == "Pick From Store" ? "Pick From Store" : "Ship To Home"}",
      "Shipping_Method_Number__c":
          "${shippingMethodName == "Economy" ? "01" :
          shippingMethodName == "Second Day Express" ? "03" :
          shippingMethodName == "Next Day Air" ? "52":
          shippingMethodName == "Digital Delivery" ? "99" : ""}",
      "Shipping_and_Handling__c": shippingMethodPrice ?? "0"
    };
  }

  static Map<String, dynamic> getCommissionRequestBody(
      {List<SelectedEmployeeJsonModel>? selectedEmployeeJsonModel,
      String? orderId,
      String? loggedInUserId}) {
    return {
      "requestString": jsonEncode(selectedEmployeeJsonModel),
      "OrderId": orderId ?? "",
      "loggedinUserId": loggedInUserId ?? ""
    };
  }

  static Map<String, dynamic> getUpdateTaskBody({
    required String recordId,
    String? status,
    String? comment,
    String? dueDate,
    String? assignee,
    required String? feedback,
    required String feedbackDateTime,
    String? loggedinUserId,
    dynamic closureType,
  }) {
    return {
      'recordId': recordId,
      'status': status ?? '',
      'comment': comment ?? '',
      'assignee': assignee ?? '',
      'dueDate': dueDate ?? '',
      "loggedinUserId": loggedinUserId ?? '',
      "ClosureType": closureType ?? '',
      "feedback":
          "{\"comment\":\"$feedback\",\"commentDate\":\"${feedbackDateTime.isEmpty ? DateFormat('hh:mm aa dd-MM-yyyy').format(DateTime.now()) : feedbackDateTime}\"}"
    };
  }

  static Map<String, dynamic> getAgentProfileBody({
    String? id,
    String? email,
  }) {
    return {'userId': id ?? '', 'email': email ?? ''};
  }

  static Map<String, dynamic> getLoginBody({
    String? id,
    String? email,
  }) {
    return {'email': email ?? ''};
  }

  static Map<String, dynamic> getPrintLoggingBody({
    String? printerName,
    String? printData,
  }) {
    return {
      "payload":
          "{\"printerName\":\"$printerName\",\"printData\":\"$printData\"}"
    };
  }

  static Map<String, dynamic> getNotificationBody({
    String? id,
    String? token,
  }) {
    return {
      'loggedinUserId': id ?? '',
      'deviceToken': token ?? '',
      'badgeCount': "0"
    };
  }

  static Map<String, dynamic> getFilteredData(
      {String? searchName,
      String? selectedID,
      lis,
      List<dynamic>? sectionChckBoxLst}) {
    return {
      "requestParams":
          "{\"searchTxt\":\"$searchName\",\"selectedId\":\"$selectedID\",\"brandType\":\"GC\",\"selectionType\":\"isRadio\",\"sectionChckBoxLst\":$sectionChckBoxLst,\"isfirstCallOut\":false,\"isDefaultSearch\":false,\"dimensionID\":\"\"}"
    };
  }

  static Map<String, dynamic> getSortedListOfData(
      {String? searchName,
      String? sortByVal,
      List<dynamic>? sectionCheckBoxLst,
      String? selectedID}) {
    return {
      "requestParams":
          "{\"searchTxt\":\"$searchName\",\"selectedId\":\"$selectedID\",\"isSortBy\":${sortByVal!.isNotEmpty ? true : false},\"sortByVal\":\"$sortByVal\",\"pageSize\":\"30\",\"brandType\":\"GC\",\"selectionType\":\"isRadio\",\"sectionChckBoxLst\":$sectionCheckBoxLst,\"isfirstCallOut\":false,\"isDefaultSearch\":false,\"dimensionID\":\"\"}"
    };
  }

  static Map<String, dynamic> getAgentNotificationBody({
    String? id,
    String? token,
    int? badgeCount,
  }) {
    return {
      'loggedinUserId': id ?? '',
      'badgeCount': badgeCount ?? 0,
      'deviceToken': token ?? ''
    };
  }

  static Map<String, dynamic> getCreateTaskBody({
    String? parentTaskId,
    String? subject,
    String? dueDate,
    String? comment,
    String? whoId,
    String? whatId,
    String? ownerId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? feedback,
    String? feedbackDate,
    String? storeId,
    String? loggedinUserId,
    String? taskType,
    String? closureType,
    required List<Order> completedOrders,
  }) {
    var orderDetailsJson = <String>[];
    for (var order in completedOrders) {
      orderDetailsJson.add(jsonEncode(order.toJson()));
    }

    return {
      'taskId': parentTaskId ?? '',
      'subject': subject,
      'storeTaskType': taskType ?? '',
      'dueDate': dueDate,
      'comment': comment ?? '',
      'WhoId': whoId ?? '',
      'WhatId': whatId ?? '',
      'StoreId': storeId ?? '',
      'OwnerId': ownerId ?? '',
      'firstName': firstName ?? '',
      'lastName': lastName ?? '',
      'email': email ?? '',
      'phone': phone ?? '',
      'orderDetailsJson': orderDetailsJson,
      "loggedinUserId": loggedinUserId ?? '',
      "ClosureType": closureType ?? '',
      "feedback":
          "{\"comment\":\"$feedback\",\"commentDate\":\"${feedbackDate!.isEmpty ? DateFormat('hh:mm aa dd-MM-yyyy').format(DateTime.now()) : feedbackDate}\"}"
    };
  }

  static Map<String, dynamic> getSearchDataInventory(
      {int? offset, String? name}) {
    if (offset == 0) {
      return {
        "requestParams":
            "{\"searchTxt\":\"\",\"brandType\":\"GC\",\"selectionType\":\"isRadio\",\"isfirstCallOut\":true,\"isDefaultSearch\":false,\"dimensionID\":\"\",\"sectionChckBoxLst\":[]}"
      };
    } else {
      return {
        "requestParams":
            "{\"searchTxt\":\"$name\",\"selectedId\":\"\",\"brandType\":\"GC\",\"selectionType\":\"isRadio\",\"sectionChckBoxLst\":[],\"isfirstCallOut\":false,\"isDefaultSearch\":false,\"dimensionID\":\"\"}"
      };
    }
  }

  static Map<String, dynamic> getPaginationData(
      {String? searchName,
      String? selectedID,
      List<dynamic>? sectionChckBoxLst,
      String? pageSize,
      String? sortByVal,
      int? currentPage}) {
    return {
      "requestParams":
          "{\"searchTxt\":\"$searchName\",\"selectedId\":\"$selectedID\",\"sortByVal\":\"$sortByVal\",\"brandType\":\"GC\",\"selectionType\":\"isRadio\",\"sectionChckBoxLst\":$sectionChckBoxLst,\"isfirstCallOut\":false,\"pageSize\":\"$pageSize\",\"isPagination\":true,\"currentPage\":$currentPage,\"isDefaultSearch\":false,\"dimensionID\":\"\"}"
    };
  }

  static Map<String, dynamic> getSendOverrideRequest({
    String? orderLineItemID,
    String? requestedAmount,
    String? selectedOverrideReasons,
    String? userID,
    String? reset,
  }) {
    return {
      "orderLineItemId": orderLineItemID,
      "discountedMSP": "",
      "requestedAmount": requestedAmount,
      "overrideReason": selectedOverrideReasons,
      "loggedinUserId": userID,
      "reset": reset
    };
  }

  static Map<String, dynamic> getSendShippingOverrideRequest({
    String? orderId,
    String? requestedAmount,
    String? selectedOverrideReasons,
    String? userID,
    String? reset,
  }) {
    return {
      "orderId": orderId,
      "requestedAmount": requestedAmount,
      "shipmentReason": selectedOverrideReasons,
      "loggedinUserId": userID,
      "reset": reset
    };
  }

  static Map<String, dynamic> updateWarranties(
      {String? orderLineItemId,
      String? warrantyId,
      String? price,
      String? enterpriseSkuId,
      String? displayName,
      String? styleDescription1,
      String? reset}) {
    return {
      "orderLineItemId": orderLineItemId,
      "warrantyId": warrantyId,
      "price": price,
      "enterpriseSkuId": enterpriseSkuId,
      "displayName": displayName,
      "styleDescription1": styleDescription1,
      "reset": reset
    };
  }

  static Map<String, dynamic> getOrderProceedBody({
    List<CreditCardModelSave>? creditModel,
    String? orderID,
    SearchStoreListInformation? store,
    List<DiscountModel>? discount,
  }) {
    return {
      'availability': store == null ? "Unavailable" : "Available",
      "storeShippingAddress": store == null ? "{}" : jsonEncode(store),
      "orderId": orderID,
      "discountInfo": discount == null ? "[]" : jsonEncode(discount),
      "paymentInfo": jsonEncode(creditModel)
    };
  }

  static Map<String, dynamic> getUpdateCartAdd({
    int? quantity,
  }) {
    return {'Quantity__c': quantity.toString()};
  }

  static Map<String, dynamic> getAddToCartAndCreateOrder({
    required Records records,
    required String orderId,
    required String customerID,
  }) {
    return {
      "inputItemId": records.productId ?? "",
      "inputItemName": records.productName ?? "",
      "inputItemPrice": records.childskus!.first.skuPrice ?? "",
      "orderId": orderId.isNotEmpty ? orderId : null,
      "accountId": customerID.isNotEmpty ? customerID : null,
      "inputItemQuantity": "1",
      "inputBrandVal": "GC",
      "inputProdImgUrl": records.productImageUrl,
      "inputProdCond": records.childskus![0].skuCondition,
      "inputSkuId": records.childskus![0].skuENTId,
      "inputPimId": records.childskus![0].skuPIMId,
      "inputPosId": records.childskus![0].gcItemNumber,
      "inputPimStatus": records.childskus![0].pimStatus,
      "selectedInvNode": "",
      "reason": ""
    };
  }

  static Map<String, dynamic> getUpdateCartDeleted() {
    return {'Status__c': "Deleted"};
  }

  static Map<String, dynamic> saveAddressBody(
      {String? contactPointId,
      required String recordId,
      required String addressLabel,
      required String address1,
      required String address2,
      required String city,
      required String state,
      required String postalCode,
      String country = 'US',
      bool? isDefault}) {
    return {
      'contactPointId': contactPointId ?? '',
      'recordId': recordId,
      'addressLabel': addressLabel,
      'address1': address1,
      'address2': address2,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'isDefault': isDefault ?? false
    };
  }

  static Map<String, dynamic> searchByName({required String name}) {
    return {'name': name, 'brand': "GC"};
  }
  static Map<String, dynamic> searchById({required String appName,required String recordId,required String loggedinUserId}) {
    return {'recordId':recordId, 'routing': appName,
    'loggedinUserId' : loggedinUserId};
  }

  static Map<String, dynamic> searchByEmail({required String email}) {
    return {'email': email, 'brand': "GC"};
  }

  static Map<String, dynamic> searchByPhone({required String phone}) {
    return {'phone': phone, 'brand': "GC"};
  }

  static Map<String, dynamic> saveCustomerBody(
      {required String firstName,
      required String lastName,
      required String email,
      required String phone,
      required String address1,
      String? address2,
      required String city,
      String? playFrequency,
      String? proficiencyLevel,
      String? preferredInstrument,
      required String state,
      required String postalCode,
      String country = 'US'}) {
    return {
      'recordId': '',
      'address1': address1,
      'address2': address2 ?? "",
      'city': city,
      'playFrequency': playFrequency ?? "",
      'proficiencyLevel': proficiencyLevel ?? "",
      'preferredInstrument': preferredInstrument ?? "",
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone.replaceAll('(', '').replaceAll(')', '').replaceAll('-', '').replaceAll(' ', ''),
      'brandCode': 'GC'
    };
  }

  static Map<String, dynamic> saveCommissionBody(
      {required List<CommissionEmployee> employees,
      required String orderId,
      required String userId}) {
    return {
      'OrderId': orderId,
      'loggedinUserId': userId,
      'requestString': jsonEncode(employees
          .map<Map>((e) => {
                'employeeCommission':
                    (e.employeeCommission ?? 0).round().toString(),
                'employeeId': e.employeeId,
                'employeeName': e.employeeName,
                'isEditable': e.isEditable,
              })
          .toList())
    };
  }

  static Map<String, dynamic> loggedinAPIMapp(
      {required String processName,
      required String requestedUrl,
      required String requestedpayload,
      required String response,
      required String statusCode,
      required String statusName,
      required String loggedinUserId,
      required bool isPostRequest}) {
    return {
      "processName": "$processName",
      "requestedUrl": "$requestedUrl",
      "requestedpayload": isPostRequest ? "$requestedpayload" : "",
      "response": "$response",
      "statusCode": "$statusCode",
      "statusName": "$statusName",
      "loggedinUserId": "$loggedinUserId",
    };
  }
}
