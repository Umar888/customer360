import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/cart_bloc/cart_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart' as isb;
import 'package:gc_customer_app/data/data_sources/cart_data_source/cart_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/cart_reporsitory/cart_repository.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/model/credit_card_model_save.dart';
import 'package:gc_customer_app/models/address_models/address_model.dart';
import 'package:gc_customer_app/models/address_models/delivery_model.dart';
import 'package:gc_customer_app/models/cart_model/cart_popup_menu.dart';
import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';
import 'package:gc_customer_app/models/cart_model/discount_model.dart';
import 'package:gc_customer_app/models/cart_model/submit_quote_model.dart';
import 'package:gc_customer_app/models/cart_model/tax_model.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/store_search_zip_code_model/search_store_zip.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension on String {
  String get escape => RegExp.escape(this);
}

class MockInventorySearchBloc extends Mock implements isb.InventorySearchBloc {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CartBloc cartBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  OrderDetail dummyOrderDetail = OrderDetail.fromJson({
    "TotalLineDiscount": 0.0,
    "TotalDiscount": 0.0,
    "Total": 524.33,
    "TaxExempt": false,
    "Tax": 35.44,
    "Subtotal": 267.3,
    "StoreId": null,
    "SourceCode": "GCSTORE",
    "ShippingZipcode": "91360-5405",
    "ShippingTax": 0.0,
    "ShippingState": "California",
    "ShippingMethodNumber": "01",
    "ShippingMethod": "Economy",
    "ShippingFee": 0.0,
    "ShippingEmail": "ankit.kumar@guitarcenter.com",
    "ShippingCountry": "United States",
    "ShippingCity": "Thousand Oaks",
    "ShippingAndHandling": 0.0,
    "ShippingAdjustment": null,
    "ShippingAddress2": null,
    "ShippingAddress": "418 Wilbur Rd",
    "ShipmentOverrideReason": null,
    "SelectedStoreCity": null,
    "Phone": "3233046476",
    "PaymentMethodTotal": 0.0,
    "PaymentMethods": null,
    "OrderOverrideReason": null,
    "OrderNumber": "GCSFU0000016398",
    "OrderDate": "2023-03-14",
    "OrderCreatedDate": "2023-03-14",
    "OrderApprovalRequest": null,
    "OrderAdjustment": null,
    "MiddleName": null,
    "Lastname": "Kumar",
    "Items": [
      {
        "WarrantyStyleDesc": "24 MONTH",
        "WarrantySkuId": "J02478000001000",
        "WarrantyPrice": 13.98,
        "WarrantyId": "site51379945714388",
        "WarrantyDisplayName": "PCGU 50-75.99 24 MONTH ADH REPLACEMENT PLAN 24 MONTH",
        "UnitPrice": 29.99,
        "SourcingReason": null,
        "ReservationLocationStock": null,
        "ReservationLocation": null,
        "Quantity": 2.0,
        "ProductId": "site51274115039668",
        "PosSkuId": "109706192",
        "PimSkuId": "1274115039668",
        "OverridePriceReason": null,
        "OverridePriceApproval": null,
        "OverridePrice": null,
        "MarginValue": 2.54,
        "Margin": 8.47,
        "ItemStatus": "R1",
        "ItemNumber": "423794000010000",
        "ItemId": "a1N6C000001hQTKUA2",
        "ItemDesc": "Rogue QAREGR1  RA-090 Dreadnought Acoustic Guitar Natural",
        "DiscountedMarginValue": -27.45,
        "DiscountedMargin": null,
        "Cost": 27.45,
        "Condition": "New"
      },
      {
        "WarrantyStyleDesc": "24 MONTH",
        "WarrantySkuId": "J02450000001000",
        "WarrantyPrice": 23.99,
        "WarrantyId": "site51379945714346",
        "WarrantyDisplayName": "PCGU 100-149.99 24 MONTH ADH REPLACEMENT PLAN 24 MONTH",
        "UnitPrice": 267.3,
        "SourcingReason": null,
        "ReservationLocationStock": null,
        "ReservationLocation": null,
        "Quantity": 3.0,
        "ProductId": "site51275425409510",
        "PosSkuId": "107223406",
        "PimSkuId": "1275425409510",
        "OverridePriceReason": null,
        "OverridePriceApproval": null,
        "OverridePrice": null,
        "MarginValue": 75.06,
        "Margin": 68.45,
        "ItemStatus": "R1",
        "ItemNumber": "519266000030000",
        "ItemId": "a1N6C000001hQTPUA2",
        "ItemDesc": "Rogue Starter Acoustic Guitar Blue Burst",
        "DiscountedMarginValue": -34.6,
        "DiscountedMargin": null,
        "Cost": 34.6,
        "Condition": "New"
      }
    ],
    "FirstName": "Ankit",
    "DiscountType": "Order",
    "Discounts": null,
    "DiscountCodes": null,
    "DiscountCode": null,
    "Discount": 0.0,
    "DeliveryOption": "Ship To Home",
    "DeliveryFeeEligible": true,
    "CustomerId": "0014M00001nv3BwQAI",
    "BrandCode": "GC",
    "BillingZipcode": null,
    "BillingState": null,
    "BillingPhone": null,
    "BillingEmail": null,
    "BillingCountry": null,
    "BillingCity": null,
    "BillingAddress2": null,
    "BillingAddress": null,
    "ApprovalRequest": null
  });

  DeliveryModel pickupDeliveryModel = DeliveryModel(type: "Pick-up", address: "", isSelected: false, price: "0", time: "");
  List<DeliveryModel> dummyDeliveryModels = [
    pickupDeliveryModel,
    DeliveryModel(type: "Economy", address: "Economy - Free", isSelected: true, price: "", time: ""),
    DeliveryModel(type: "Second Day Express", address: "Second Day Express - \$ 51.65", isSelected: false, price: "", time: ""),
    DeliveryModel(type: "Next Day Air", address: "Next Day Air - \$ 63.41", isSelected: false, price: "", time: ""),
  ];

  late bool successScenario;
  setUp(
    () {
      var cartDataSource = CartDataSource();
      cartDataSource.httpService.client = MockClient((request) async {
        if(successScenario) {
          if (RegExp('${Endpoints.kBaseURL}${Endpoints.kItemAvailability}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(json.encode({}), 200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kSubmitQuote}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(json.encode(QuoteSubmitModel(message: "123XP", isSuccess: true).toJson()), 200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kClientOrderCalculation}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "ShippingMethod": [
                    {"values": "Economy", "Label": "Economy - Free"},
                    {"values": "Second Day Express", "Label": "Second Day Express - \$ 51.65"},
                    {"values": "Next Day Air", "Label": "Next Day Air - \$ 63.41"}
                  ],
                  "promoCode": [
                    {
                      "PromoName": "PLC promos",
                      "promoDesc": [
                        {
                          "rank": "1",
                          "promoTitle": "6 Months Promotional Financing",
                          "promoDescription": "6-month special financing + learn how to earn 5% back in rewards. Valid through",
                          "planCode": "106",
                          "isSpecialFinancing": true
                        },
                        {
                          "rank": "3",
                          "promoTitle": "24 Month Equal Pay",
                          "promoDescription":
                          "0% Interest for 24 months* + learn how to earn 5% back in rewards. 24 equal monthly payments required. Valid through",
                          "planCode": "424",
                          "isSpecialFinancing": true
                        },
                        {
                          "rank": "13",
                          "promoTitle": "12 Months Promotional Financing",
                          "promoDescription": "Special 12-month financing + learn how to earn 5% back in rewards. Valid through",
                          "planCode": "112",
                          "isSpecialFinancing": true
                        }
                      ]
                    },
                    {
                      "PromoName": "Fortiva promos",
                      "promoDesc": [
                        {
                          "rank": "7",
                          "promoTitle": "Pay with my Guitar Center Essentials Card without any Promotional Financing",
                          "promoDescription": "Divide your purchase into 24 equal payments and receive 24 months of interest free financing.",
                          "planCode": "0200",
                          "isSpecialFinancing": true
                        }
                      ]
                    }
                  ],
                  "OrderDetail": dummyOrderDetail.toJson(),
                  "gcOrder": {
                    "attributes": {"type": "GC_Order__c", "url": "/services/data/v57.0/sobjects/GC_Order__c/a1O6C000001OKAaUAO"},
                    "Source_Code__c": "GCSTORE",
                    "QuoteAmount__c": 267.3,
                    "LastModifiedDate": "2023-03-14T11:57:52.000+0000",
                    "TotalLineAmount__c": 267.3,
                    "Order_Status__c": "Draft",
                    "Shipping_Zip_code__c": "91360-5405",
                    "Tax_Exempt__c": false,
                    "Shipping_City__c": "Thousand Oaks",
                    "Order_Number__c": "GCSFU0000016398",
                    "OrderEmployee__c": "110085",
                    "accountId__c": "0014M00001nv3Bw",
                    "Customer__c": "0014M00001nv3BwQAI",
                    "OrderingStore__c": null,
                    "Payment_Method_Total__c": 0.0,
                    "Shipping_Country__c": "US",
                    "Shipping_Address__c": "418 Wilbur Rd",
                    "Shipping_and_Handling__c": 0.0,
                    "Discount_Type__c": "Order",
                    "Site_Id__c": "5",
                    "Shipping_Tax__c": 0.0,
                    "TotalLineDiscount__c": 0.0,
                    "UnAppliedDiscountTotal__c": 0.0,
                    "Shipping_Email__c": "ankit.kumar@guitarcenter.com",
                    "QuoteNumber__c":
                    "_HL_ENCODED_/lightning/cmp/c__GC_viewCart?uid=a1O6C000001OKAa&c__accountId=0014M00001nv3Bw&ws=%2Flightning%2Fr%2FAccount%2F0014M00001nv3Bw%2Fview_HL_ _HL__self_HL_",
                    "ShippingTotal__c": 0.0,
                    "OrderNumber__c":
                    "_HL_ENCODED_/lightning/cmp/c__GC_viewCart?uid=a1O6C000001OKAa&c__accountId=0014M00001nv3Bw&c__tabheader=GCSFU0000016398&ws=%2Flightning%2Fr%2FAccount%2F0014M00001nv3Bw%2Fview_HL_GCSFU0000016398_HL__self_HL_",
                    "Final_Amount__c": 267.3,
                    "Shipping_State__c": "CA",
                    "Shipping_Fee__c": 0.0,
                    "Total__c": 524.33,
                    "DeliveryFeeEligible__c": true,
                    "Discount__c": 0.0,
                    "Shipping_Method__c": "Economy",
                    "Total_Discount__c": 0.0,
                    "LevelOfService__c": "01",
                    "Phone__c": "3233046476",
                    "CreatedDate": "2023-03-14T11:25:00.000+0000",
                    "Shipping_Method_Number__c": "01",
                    "First_Name__c": "Ankit",
                    "Id": "a1O6C000001OKAaUAO",
                    "Delivery_Option__c": "Ship To Home",
                    "Channel__c": "CC",
                    "Tax__c": 35.44,
                    "Brand_Code__c": "GC",
                    "Last_Name__c": "Kumar"
                  },
                  "ErrorCode": {"errorMsg": "Success", "errorCode": "200"},
                  "discountParam": [DiscountModel()]
                }),
                200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kOrderDetail}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "OrderDetail": dummyOrderDetail.toJson(),
                  "message": "Record found.",
                }),
                200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kClientAddress}'.escape + r'$').hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            // Save Addresses
            return Response(
                json.encode({
                  "addressList": [
                    AddressList(
                      address1: "418 E Wilbur Rd",
                      address2: "",
                      addressLabel: "",
                      city: "Thousand Oaks",
                      state: "California",
                      postalCode: "91360-5405",
                      addAddress: false,
                      isPrimary: true,
                    ).toJson()
                  ]
                }),
                200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kClientAddress}'.escape + r'\?recordId=.+$').hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            // Get Order Addresses
            return Response(
                json.encode({
                  "addressList": [
                    AddressList(
                      address1: "418 E Wilbur Rd",
                      address2: "",
                      addressLabel: "",
                      city: "Thousand Oaks",
                      state: "California",
                      postalCode: "91360-5405",
                      addAddress: false,
                      isPrimary: true,
                    ).toJson()
                  ]
                }),
                200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kReasonList}'.escape + r'/.+$').hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            if (request.method == "GET") {
              return Response(
                  json.encode({
                    "nlnReasonList": ["reason 1", "reason 2", "reason 3", "reason 4"]
                  }),
                  200);
            } else if (request.body.contains("NLN_Reason__c")) {
              // Delete Order
              return Response(
                  json.encode({
                    "order": {
                      "Id": "123",
                    },
                    "message": "success",
                  }),
                  200);
            } else if (request.body.contains("Shipping_Address_2__c")) {
              // Send Tax Info Address
              return Response(json.encode({"isSuccess": true}), 200);
            } else if (request.body.contains("Selected_Store_City__c")) {
              // Send Tax Info Delivery
              return Response(json.encode({
                "isSuccess": true,
              }), 200);
            } else if (request.body.contains("Customer__c")) {
              // Assign user
              return Response(
                  json.encode({
                    "order": {
                      "attributes": {
                        "type": "",
                        "url": "",
                      },
                      "Id": "",
                      "Customer__c": "",
                    },
                    "message": "",
                    "isSuccess": true,
                  }),
                  200);
            } else if (request.body.contains("Shipping_and_Handling__c")) {
              // Send Tax Info Shipping Method
              return Response(json.encode({
                "isSuccess": true,
              }), 200);
            } else if (request.body.contains("Discount_Code__c")) {
              // Apply / Delete Coupon
              return Response(
                  json.encode({
                    "isSuccess": true,
                  }),
                  200);
            } else {
              print("API call not mocked: ${request.url}");
              return Response(json.encode({}), 205);
            }
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kClientAddress}'.escape + r"\?recordType=RecommendedAddress.+$")
              .hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "message": "record found.",
                  "addressInfo": {
                    "recommendedAddress": {
                      "state": "California",
                      "postalcode": "91360-5405",
                      "isSuccess": true,
                      "isShipping": true,
                      "isBilling": false,
                      "country": "United States",
                      "city": "Thousand Oaks",
                      "addressline2": "",
                      "addressline1": "418 E Wilbur Rd"
                    },
                    "hasDifference": true,
                    "existingAddress": {
                      "state": "California",
                      "postalcode": "91360-5405",
                      "isSuccess": null,
                      "isShipping": true,
                      "isBilling": false,
                      "country": "United States",
                      "city": "Thousand Oaks",
                      "addressline2": "",
                      "addressline1": "418 Wilbur Rd",
                    },
                  },
                }),
                200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kUpdateCartAndProductOrder}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "OrderLineItem": {
                    "attributes": {"type": "GC_OrderLineItem__c", "url": "/services/data/v55.0/sobjects/GC_OrderLineItem__c/a1N6C000001hQaGUAU"},
                    "Id": "a1N6C000001hQaGUAU",
                    "GC_Order__c": "a1O6C000001OKGiUAO",
                    "Name": "Oli-0032713",
                    "GC_Order__r": {
                      "attributes": {"type": "GC_Order__c", "url": "/services/data/v55.0/sobjects/GC_Order__c/a1O6C000001OKGiUAO"},
                      "Id": "a1O6C000001OKGiUAO",
                      "OwnerId": "0054M000004UMmEQAW"
                    },
                    "Quantity__c": 2
                  },
                  "message": "Record saved successfully.",
                }),
                200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kOverrideReasons}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            if (request.method == "GET") {
              return Response(
                  json.encode({
                    "OverrideReasonList": [
                      "reason 1",
                      "reason 2",
                      "reason 3",
                      "reason 4",
                    ]
                  }),
                  200);
            } else {
              return Response(
                  json.encode({
                    "isSuccess": true,
                  }),
                  200);
            }
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kShippingOverrideReasons}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            if (request.method == "GET") {
              return Response(
                  json.encode({
                    "shippingOverrideReasonList": [
                      "reason 1",
                      "reason 2",
                      "reason 3",
                      "reason 4",
                    ]
                  }),
                  200);
            } else {
              return Response(
                  json.encode({
                    "isSuccess": true,
                  }),
                  200);
            }
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kWarranties}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(
                json.encode(
                  {
                    "Warranties": [
                      {
                        "styleDescription1": "",
                        "price": null,
                        "id": "",
                        "enterpriseSkuId": "",
                        "enterprisePIMId": "",
                        "displayName": "",
                      }
                    ],
                    "message": "Success",
                  },
                ),
                200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kWarrantiesUpdate}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(json.encode({}), 200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kShippingOverrideRequests}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(json.encode({}), 200);
          } else if (RegExp('${Endpoints.kBaseURL}${Endpoints.kCustomerInfo.replaceAll(" ", "%20")}'.escape).hasMatch(request.url.toString())) {
            print("Success: ${request.url}");
            return Response(json.encode({}), 200);
          } else {
            print("API call not mocked: ${request.url}");
            return Response(json.encode({}), 205);
          }
        } else {
          print("Failed: ${request.url}");
          return Response(json.encode({}), 205);
        }
      });
      cartBloc = CartBloc(cartRepository: CartRepository(cartDataSource: cartDataSource));
      cartBloc.landingScreenRepository.landingScreenDataSource.httpService.client = cartDataSource.httpService.client;
      cartBloc.favouriteBrandScreenRepository.favouriteBrandScreenDataSource.httpService.client = cartDataSource.httpService.client;
    },
  );

  group(
    "Success Scenarios",
    () {
      setUp(() => successScenario = true);
      blocTest<CartBloc, CartState>(
        "Update Add address",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateAddAddress(value: true)),
        expect: () {
          return [
            CartState(addAddress: true),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Update Warranty",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateWarranty(itemsId: "123", warranties: Warranties(id: "123"))),
        expect: () {
          return [];
        },
      );

      blocTest<CartBloc, CartState>(
        "Get Product Eligibility",
        build: () => cartBloc,
        act: (bloc) => bloc.add(GetProductEligibility(itemSKUId: "xyz")),
        expect: () {
          return [
            CartState(moreInfo: [], mainNodeData: [], fetchMoreInfo: true),
            CartState(moreInfo: [], mainNodeData: [], fetchMoreInfo: false),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Update Loading Screen",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateLoadingScreen(value: true)),
        expect: () {
          return [
            CartState(loadingScreen: true),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Update Show Add Card",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateShowAddCard(value: true)),
        expect: () {
          return [
            CartState(showAddCard: true),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Update Show Message Field",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateShowMessageField(value: true)),
        expect: () {
          return [
            CartState(showMessageField: true),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Update Submit Quote Done",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateSubmitQuoteDone(value: true)),
        expect: () {
          return [
            CartState(submitQuoteDone: true),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Update Current Quote",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateCurrentQuote(value: "123")),
        expect: () {
          return [
            CartState(currentQuoteID: "123"),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Submit Quote",
        build: () => cartBloc,
        act: (bloc) => bloc.add(SubmitQuote(email: "abc.mail.com", expiration: "123", orderId: "1234", phone: "09000000", subtotal: "1000")),
        expect: () {
          return [
            CartState(submittingQuote: true),
            CartState(submittingQuote: false, submitQuoteDone: true, currentQuoteID: "123XP", message: "Quote saved successfully"),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Update Delete Done",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateDeleteDone(value: true)),
        expect: () {
          return [
            CartState(deleteDone: true),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Get Recommended Addresses",
        build: () => cartBloc,
        act: (bloc) => bloc.add(GetRecommendedAddresses(
          orderId: "a1O6C000001OKGiUAO",
          recordId: "0014M00001nv3BwQAI",
          index: 2,
          address1: "418 Wilbur Rd",
          address2: "",
          country: "United States",
          city: "Thousand Oaks",
          state: "California",
          postalCode: "91360-5405",
          isShipping: true,
          isBilling: false,
        )),
        expect: () {
          return [
            CartState(
              recommendedAddress: "",
              proceedingOrder: true,
              recommendedAddressLine1: "",
              recommendedAddressLine2: "",
              recommendedLabel: "",
              recommendedContactPointAddressId: "",
              recommendedAddressLineCity: "",
              recommendedAddressLineCountry: "",
              recommendedAddressLineState: "",
              recommendedAddressLineZipCode: "",
              orderAddressLine1: "",
              orderAddressLine2: "",
              orderLabel: "",
              orderContactPointAddressId: "",
              orderAddressLineCity: "",
              orderAddressLineCountry: "",
              orderAddressLineState: "",
              orderAddressLineZipCode: "",
              showRecommendedDialog: false,
              orderAddress: "",
              updateIndex: 2,
            ),
            CartState(
              recommendedAddress: "418 E Wilbur Rd, , Thousand Oaks, California, United States, 91360-5405",
              orderAddress: "418 Wilbur Rd, , Thousand Oaks, California, United States, 91360-5405",
              proceedingOrder: false,
              showRecommendedDialog: true,
              recommendedLabel: "",
              recommendedAddressLine1: "418 E Wilbur Rd",
              recommendedContactPointAddressId: "",
              recommendedAddressLine2: "",
              recommendedAddressLineCity: "Thousand Oaks",
              recommendedAddressLineCountry: "United States",
              recommendedAddressLineState: "California",
              recommendedAddressLineZipCode: "91360-5405",
              orderContactPointAddressId: "",
              orderAddressLine1: "418 Wilbur Rd",
              orderAddressLine2: "",
              orderAddressLineCity: "Thousand Oaks",
              orderAddressLineCountry: "United States",
              orderAddressLineState: "California",
              orderAddressLineZipCode: "91360-5405",
              updateIndex: 2,
            ),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Clear Recommended Addresses",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ClearRecommendedAddresses()),
        expect: () {
          return [
            CartState(
              recommendedAddress: "",
              orderAddress: "",
              recommendedAddressLine1: "",
              recommendedAddressLine2: "",
              recommendedLabel: "",
              recommendedContactPointAddressId: "",
              recommendedAddressLineCity: "",
              recommendedAddressLineCountry: "",
              recommendedAddressLineState: "",
              recommendedAddressLineZipCode: "",
              orderAddressLine1: "",
              orderAddressLine2: "",
              orderLabel: "",
              orderContactPointAddressId: "",
              orderAddressLineCity: "",
              orderAddressLineCountry: "",
              orderAddressLineState: "",
              orderAddressLineZipCode: "",
              updateIndex: 0,
            ),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Hide Recommended Addresses",
        build: () => cartBloc,
        act: (bloc) => bloc.add(HideRecommendedDialog()),
        expect: () {
          return [CartState(showRecommendedDialog: false)];
        },
      );

      blocTest<CartBloc, CartState>(
        "Set Selected Addresses",
        build: () => cartBloc,
        act: (bloc) => bloc.add(SetSelectedAddress(
          address1: "Address 1",
          address2: "Address 2",
          city: "City",
          state: "State",
          postalCode: "12345-123",
        )),
        expect: () {
          return [
            CartState(
              selectedAddress1: "Address 1",
              selectedAddress2: "Address 2",
              selectedAddressCity: "City",
              selectedAddressState: "State",
              selectedAddressPostalCode: "12345-123",
            )
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Delete Order",
        build: () => cartBloc,
        act: (bloc) => bloc.add(
          DeleteOrder(
            orderId: "123X",
            reason: "Dummy reason",
            inventorySearchBloc: MockInventorySearchBloc(),
            onSuccess: () {},
          ),
        ),
        expect: () {
          return [
            CartState(deleteDone: false, loadingScreen: true),
            CartState(deleteDone: true, loadingScreen: false, message: "Order Deleted Successfully"),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Add To Cart",
        build: () => cartBloc,
        act: (bloc) => bloc.add(AddToCart(
          records: Items(
            itemStatus: "R1",
            posSkuId: "123456",
            productId: "site1231321",
            condition: "New",
            warrantyPrice: 0.0,
            unitPrice: 499.99,
            quantity: 3.0,
            pimSkuId: "123124141243",
            overridePrice: 0.0,
            marginValue: 290.99,
            margin: 58.2,
            itemNumber: "J123123123",
            itemId: "",
            itemDesc: "Dummy description",
            discountedMarginValue: -290.0,
            discountedMargin: 0.0,
          ),
          inventorySearchBloc: MockInventorySearchBloc(),
          customerID: "0014M00001nv3BwQAI",
          orderID: "a1O6C000001OKGiUAO",
          quantity: -1,
        )),
        expect: () {
          return [
            CartState(message: "", isUpdating: true, updateID: ""),
            CartState(
              message: "Record saved successfully.",
              total: 283.2,
              subtotal: 267.3,
              proCoverage: 99.93,
              overrideDiscount: 0.0,
              deliveryModels: [
                DeliveryModel(isSelected: false, address: "", type: "Pick-up", price: "0", time: ""),
                DeliveryModel(isSelected: true, address: "Economy - Free", type: "Economy", price: "", time: ""),
                DeliveryModel(isSelected: false, address: "Second Day Express - \$ 51.65", type: "Second Day Express", price: "", time: ""),
                DeliveryModel(isSelected: false, address: "Next Day Air - \$ 63.41", type: "Next Day Air", price: "", time: ""),
              ],
              orderDetailModel: [dummyOrderDetail],
              isUpdating: false,
              updateID: "",
            ),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Get Override Reasons",
        build: () => cartBloc,
        act: (bloc) => bloc.add(GetOverrideReasons()),
        expect: () => [
          CartState(overrideReasons: ["reason 1", "reason 2", "reason 3", "reason 4"], isOverrideLoading: false)
        ],
      );

      blocTest<CartBloc, CartState>(
        "Get Shipping Override Reasons",
        build: () => cartBloc,
        act: (bloc) => bloc.add(GetShippingOverrideReasons()),
        expect: () => [
          CartState(isOverrideLoading: true),
          CartState(overrideReasons: ["reason 1", "reason 2", "reason 3", "reason 4"], isOverrideLoading: false)
        ],
      );

      blocTest<CartBloc, CartState>(
        "Clear Whole Cart",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ClearWholeCart(
          orderID: "123",
          inventorySearchBloc: MockInventorySearchBloc(),
          customerID: "123",
          e: [],
          onCompleted: () {},
        )),
        expect: () => [
          CartState(loadingScreen: true),
          CartState(loadingScreen: false, orderDetailModel: []),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Get Delete Reasons",
        build: () => cartBloc,
        act: (bloc) => bloc.add(GetDeleteReasons()),
        expect: () => [
          CartState(fetchingReason: true),
          CartState(reasonList: ["reason 1", "reason 2", "reason 3", "reason 4"], fetchingReason: false),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Clear Override Reason List",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ClearOverrideReasonList()),
        expect: () => [
          CartState(reasonList: []),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Get Warranties",
        build: () => cartBloc,
        act: (bloc) => bloc.add(GetWarranties(index: 2, skuEntId: "123")),
        expect: () => [
          CartState(orderDetailModel: [], message: "done"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Change Override Reason",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ChangeOverrideReason(reason: "Dummy reason")),
        expect: () => [
          CartState(selectedOverrideReasons: "Dummy reason"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Change Delete Reason",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ChangeDeleteReason(reason: "dummy reason")),
        expect: () => [
          CartState(selectedReason: "dummy reason"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Empty Message",
        build: () => cartBloc,
        act: (bloc) => bloc.add(EmptyMessage()),
        expect: () => [
          CartState(message: ""),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update State Message",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateStateMessage()),
        expect: () => [
          CartState(message: "done", saveCustomerStatus: CartSaveCustomerStatus.saving),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Change Is Overridden",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ChangeIsOverridden(value: true, item: Items())),
        expect: () => [
          CartState(orderDetailModel: []),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Change Is Expanded",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ChangeIsExpanded(value: true, item: Items())),
        expect: () => [
          CartState(orderDetailModel: []),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Change Is Expanded Bottom Sheet",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ChangeIsExpandedBottomSheet(value: true)),
        expect: () => [
          CartState(isExpanded: true),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Save As Default Address",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateSaveAsDefaultAddress(value: true)),
        expect: () => [
          CartState(isDefaultAddress: true),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Same As Billing",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateSameAsBilling(value: true)),
        expect: () => [
          CartState(sameAsBilling: true),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Add Card Amount",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateAddCardAmount(value: "100")),
        expect: () => [
          CartState(addCardAmount: "100"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Card Holder Name",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateCardHolderName(value: "Dummy name")),
        expect: () => [
          CartState(cardHolderName: "Dummy name"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Card Number",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateCardNumber(value: "0000")),
        expect: () => [
          CartState(cardNumber: "0000"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Card Amount",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateCardAmount(value: "100")),
        expect: () => [
          CartState(cardAmount: "100"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Expiry Year",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateExpiryYear(value: "2025")),
        expect: () => [
          CartState(expiryYear: "2025"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Cvv Code",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateCvvCode(value: "123")),
        expect: () => [
          CartState(cvvCode: "123"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Expiry Month",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateExpiryMonth(value: "12")),
        expect: () => [
          CartState(expiryMonth: "12"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Is Cvv Focused",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateIsCvvFocused(value: true)),
        expect: () => [
          CartState(isCvvFocused: true),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Heading",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateHeading(value: "Dummy heading")),
        expect: () => [
          CartState(heading: "Dummy heading"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update State",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateState(value: "state")),
        expect: () => [
          CartState(state: "state"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Address",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateAddress(value: "address")),
        expect: () => [
          CartState(address: "address"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Zip Code",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateZipCode(value: "123-456")),
        expect: () => [
          CartState(zipCode: "123-456"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update City",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateCity(value: "city")),
        expect: () => [
          CartState(city: "city"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Number Of Cart Items",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateNumberOfCartItems(value: "5")),
        expect: () => [
          CartState(numberOfCartItems: "5"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Selected State",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateSelectedState(value: "state")),
        expect: () => [
          CartState(selectedState: "state"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Selected City",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateSelectedCity(value: "city")),
        expect: () => [
          CartState(selectedCity: "city"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Proceeding Order",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateProceedingOrder(value: true)),
        expect: () => [
          CartState(proceedingOrder: true),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Complete Order",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateCompleteOrder(value: true)),
        expect: () => [
          CartState(callCompleteOrder: true),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Obscure Card Number",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateObscureCardNumber(value: true)),
        expect: () => [
          CartState(obscureCardNumber: true),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Active Step",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateActiveStep(value: 1)),
        expect: () => [
          CartState(activeStep: 1),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Remove Credit Card Model Save",
        build: () => cartBloc,
        act: (bloc) => bloc.add(RemoveCreditCardModelSave(value: CreditCardModelSave(cardNumber: "0000", cvvCode: "123"))),
        expect: () => [
          CartState(),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Add In Address Model",
        build: () => cartBloc,
        act: (bloc) => bloc.add(AddInAddressModel(value: AddressList())),
        expect: () => [
          CartState(addressModel: [AddressList()]),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Add In Credit Card Model",
        build: () => cartBloc,
        act: (bloc) => bloc.add(AddInCreditCardModel(value: CreditCardModelSave(cardNumber: "0000", cvvCode: "123"))),
        expect: () => [
          CartState(creditCardModelSave: [CreditCardModelSave(cardNumber: "0000", cvvCode: "123")]),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Change Address Is Selected",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ChangeAddressIsSelected()),
        expect: () => [
          CartState(addressModel: []),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Animated Hide",
        build: () => cartBloc,
        act: (bloc) => bloc.add(AnimatedHide(value: true)),
        expect: () => [
          CartState(isExpanded: true, initialExtent: 0.2),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Page Load",
        build: () => cartBloc,
        act: (bloc) => bloc.add(PageLoad(orderID: "", inventorySearchBloc: MockInventorySearchBloc(), customerId: CustomerInfoModel())),
        expect: () {
          return [
            CartState(
              cartStatus: CartStatus.loadState,
              orderDetailModel: [OrderDetail(items: [Items(
                isCartAdding: false, quantity: 0,
              )])],
              customerInfoModel: CustomerInfoModel(records: [Records(id: null)]),
            ),
            CartState(
              cartStatus: CartStatus.loadState,
              total: 283.2,
              subtotal: 0.0,
              proCoverage: 0.0,
              orderDetailModel: [OrderDetail(items: [Items(isCartAdding: false, quantity: 0)])],
              customerInfoModel: CustomerInfoModel(records: [Records()], done: false),
              activeStep: 0,
              maxExtent: 0.385,
              minExtent: 0.2,
              initialExtent: 0.2,
              isExpanded: false,
              message: "done",
            ),
            CartState(
              cartStatus: CartStatus.successState,
              total: 283.2,
              subtotal: 267.3,
              proCoverage: 99.93,
              maxExtent: 0.38,
              orderDetailModel: [dummyOrderDetail],
              customerInfoModel: CustomerInfoModel(records: [Records(id: null)],done: false),
              addressModel: [
                AddressList(
                  address1: "",
                  city: "",
                  state: "",
                  postalCode: "",
                  addressLabel: "",
                  addAddress: true,
                  isSelected: false,
                )
              ],
              deliveryModels: [
                DeliveryModel(type: "Pick-up", address: "", isSelected: false, price: "0", time: ""),
              ],
              message: "done",
            ),
            CartState(
              cartStatus: CartStatus.successState,
              appliedCouponDiscount: [DiscountModel()],
              total: 283.2,
              subtotal: 267.3,
              proCoverage: 99.93,
              maxExtent: 0.38,
              orderDetailModel: [dummyOrderDetail],
              customerInfoModel: CustomerInfoModel(records: [Records(id: null)], done: false),
              addressModel: [
                AddressList(
                  address1: "",
                  city: "",
                  state: "",
                  postalCode: "",
                  addressLabel: "",
                  addAddress: true,
                  isSelected: false,
                )
              ],
              deliveryModels: [
                DeliveryModel(type: "Pick-up", address: "", isSelected: false, price: "0", time: ""),
                DeliveryModel(type: "Economy", address: "Economy - Free", isSelected: true, price: "", time: ""),
                DeliveryModel(type: "Second Day Express", address: "Second Day Express - \$ 51.65", isSelected: false, price: "", time: ""),
                DeliveryModel(type: "Next Day Air", address: "Next Day Air - \$ 63.41", isSelected: false, price: "", time: ""),
              ],
              message: "done"
            ),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Reload Cart",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ReloadCart(inventorySearchBloc: MockInventorySearchBloc(), orderID: "123")),
        expect: () {
          return [
            CartState(),
            CartState(
              total: 283.2,
              subtotal: 267.3,
              proCoverage: 99.93,
              deliveryModels: [
                DeliveryModel(type: "Pick-up", address: "", isSelected: false, price: "0", time: ""),
                DeliveryModel(type: "Economy", address: "Economy - Free", isSelected: true, price: "", time: ""),
                DeliveryModel(type: "Second Day Express", address: "Second Day Express - \$ 51.65", isSelected: false, price: "", time: ""),
                DeliveryModel(type: "Next Day Air", address: "Next Day Air - \$ 63.41", isSelected: false, price: "", time: ""),
              ],
              orderDetailModel: [dummyOrderDetail],
            ),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Save Addresses Data",
        build: () => cartBloc,
        act: (bloc) => bloc.add(SaveAddressesData(
          orderId: "123",
          addressModel: AddressList(
            address1: "418 E Wilbur Rd",
            address2: "",
            addressLabel: "",
            city: "Thousand Oaks",
            state: "California",
            postalCode: "91360-5405",
            addAddress: false,
            isPrimary: true,
          ),
          isDefault: true,
          email: "abc@email.com",
          phone: "123456789",
          firstName: "John",
          lastName: "Wick",
        )),
        expect: () {
          return [
            CartState(proceedingOrder: true),
            CartState(
              addAddress: false,
              selectedAddressIndex: 1,
              proceedingOrder: false,
              total: 283.2,
              subtotal: 267.3,
              proCoverage: 99.93,
              deliveryModels: [
                DeliveryModel(type: "Pick-up", address: "", isSelected: false, price: "0", time: ""),
                DeliveryModel(type: "Economy", address: "Economy - Free", isSelected: true, price: "", time: ""),
                DeliveryModel(type: "Second Day Express", address: "Second Day Express - \$ 51.65", isSelected: false, price: "", time: ""),
                DeliveryModel(type: "Next Day Air", address: "Next Day Air - \$ 63.41", isSelected: false, price: "", time: ""),
              ],
              orderDetailModel: [dummyOrderDetail],
              selectedAddress1: "418 Wilbur Rd",
              selectedAddressCity: "Thousand Oaks",
              selectedAddressState: "California",
              selectedAddressPostalCode: "91360-5405",
              addressModel: [
                AddressList(
                  address1: "",
                  city: "",
                  state: "",
                  postalCode: "",
                  addressLabel: "",
                  addAddress: true,
                  isSelected: false,
                ),
                AddressList(
                  address1: "418 E Wilbur Rd",
                  address2: "",
                  city: "Thousand Oaks",
                  country: "",
                  state: "California",
                  postalCode: "91360-5405",
                  addressLabel: "",
                  addAddress: false,
                  isSelected: true,
                  isPrimary: true,
                ),
              ],
            ),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Fetch Shipping Methods",
        build: () => cartBloc,
        act: (bloc) => bloc.add(FetchShippingMethods(orderId: "123", inventorySearchBloc: MockInventorySearchBloc())),
        expect: () {
          return [
            CartState(fetchingAddresses: true),
            CartState(
              fetchingAddresses: false,
              selectedAddressIndex: 1,
              total: 283.2,
              subtotal: 267.3,
              proCoverage: 99.93,
              deliveryModels: [
                DeliveryModel(type: "Pick-up", address: "", isSelected: false, price: "0", time: ""),
                DeliveryModel(type: "Economy", address: "Economy - Free", isSelected: true, price: "", time: ""),
                DeliveryModel(type: "Second Day Express", address: "Second Day Express - \$ 51.65", isSelected: false, price: "", time: ""),
                DeliveryModel(type: "Next Day Air", address: "Next Day Air - \$ 63.41", isSelected: false, price: "", time: ""),
              ],
              orderDetailModel: [dummyOrderDetail],
              selectedAddress1: "418 Wilbur Rd",
              selectedAddressCity: "Thousand Oaks",
              selectedAddressState: "California",
              selectedAddressPostalCode: "91360-5405",
              addressModel: [
                AddressList(
                  address1: "",
                  city: "",
                  state: "",
                  postalCode: "",
                  addressLabel: "",
                  addAddress: true,
                  isSelected: false,
                ),
                AddressList(
                  address1: "418 E Wilbur Rd",
                  address2: "",
                  city: "Thousand Oaks",
                  country: "",
                  state: "California",
                  postalCode: "91360-5405",
                  addressLabel: "",
                  addAddress: false,
                  isSelected: true,
                  isPrimary: true,
                ),
              ],
            ),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Change Address Is Selected With Address",
        build: () => cartBloc,
        setUp: () => cartBloc..add(AddInAddressModel(value: AddressList(
          address1: "",
          address2: "",
          city: "",
          country: "",
          state: "",
          postalCode: "",
          addressLabel: "",
          addAddress: false,
          isSelected: false,
          isPrimary: true,
        )))..add(AddInAddressModel(value: AddressList(
          address1: "418 E Wilbur Rd",
          address2: "",
          city: "Thousand Oaks",
          country: "",
          state: "California",
          postalCode: "91360-5405",
          addressLabel: "",
          addAddress: false,
          isSelected: false,
          isPrimary: true,
        ))),
        act: (bloc) => bloc.add(ChangeAddressIsSelectedWithAddress(
            addressModel: AddressList(
              address1: "418 E Wilbur Rd",
              address2: "",
              city: "Thousand Oaks",
              country: "",
              state: "California",
              postalCode: "91360-5405",
              addressLabel: "",
              addAddress: false,
              isSelected: true,
              isPrimary: true,
            ),
            index: 1,
            orderID: "123",
            email: "abc@email.com",
            phone: "123456789",
            firstName: "John",
            lastName: "Wick",
          )),
        expect: () {
          return [
            CartState(
              addressModel: [
              AddressList(
                address1: "",
                address2: "",
                city: "",
                country: "",
                state: "",
                postalCode: "",
                addressLabel: "",
                addAddress: false,
                isSelected: false,
                isPrimary: true,
              ),
              AddressList(
                address1: "418 E Wilbur Rd",
                address2: "",
                city: "Thousand Oaks",
                country: "",
                state: "California",
                postalCode: "91360-5405",
                addressLabel: "",
                addAddress: false,
                isSelected: true,
                isPrimary: true,
              ),
            ],
              selectedAddressIndex: 0,
              savingAddress: false,
            ),
            CartState(
              addressModel: [
              AddressList(
                address1: "",
                address2: "",
                city: "",
                country: "",
                state: "",
                postalCode: "",
                addressLabel: "",
                addAddress: false,
                isSelected: false,
                isPrimary: true,
              ),
              AddressList(
                address1: "418 E Wilbur Rd",
                address2: "",
                city: "Thousand Oaks",
                country: "",
                state: "California",
                postalCode: "91360-5405",
                addressLabel: "",
                addAddress: false,
                isSelected: true,
                isPrimary: true,
              ),
            ],
              selectedAddressIndex: 1,
              savingAddress: true,
            ),
            CartState(
              total: 283.2,
              subtotal: 267.3,
              deliveryModels: [
                DeliveryModel(type: "Pick-up", address: "", isSelected: false, price: "0", time: ""),
                DeliveryModel(type: "Economy", address: "Economy - Free", isSelected: true, price: "", time: ""),
                DeliveryModel(type: "Second Day Express", address: "Second Day Express - \$ 51.65", isSelected: false, price: "", time: ""),
                DeliveryModel(type: "Next Day Air", address: "Next Day Air - \$ 63.41", isSelected: false, price: "", time: ""),
              ],
              proCoverage: 99.93,
              selectedAddress1: "418 E Wilbur Rd",
              selectedAddressCity: "Thousand Oaks",
              selectedAddressState: "California",
              selectedAddressPostalCode: "91360-5405",
              selectedAddressIndex: 1,
              savingAddress: false,
              orderDetailModel: [dummyOrderDetail],
              addressModel: [
                AddressList(
                  address1: "",
                  address2: "",
                  city: "",
                  country: "",
                  state: "",
                  postalCode: "",
                  addressLabel: "",
                  addAddress: false,
                  isSelected: false,
                  isPrimary: true,
                ),
                AddressList(
                  address1: "418 E Wilbur Rd",
                  address2: "",
                  city: "Thousand Oaks",
                  country: "",
                  state: "California",
                  postalCode: "91360-5405",
                  addressLabel: "",
                  addAddress: false,
                  isSelected: true,
                  isPrimary: true,
                ),
              ],
            ),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Remove From Cart",
        build: () => cartBloc,
        act: (bloc) async => bloc.add(RemoveFromCart(
          orderID: "123",
          customerID: "123",
          records: Items(
            itemStatus: "R1",
            posSkuId: "123456",
            productId: "site1231321",
            condition: "New",
            warrantyPrice: 0.0,
            unitPrice: 499.99,
            quantity: 3.0,
            pimSkuId: "123124141243",
            overridePrice: 0.0,
            marginValue: 290.99,
            margin: 58.2,
            itemNumber: "J123123123",
            itemId: "",
            itemDesc: "Dummy description",
            discountedMarginValue: -290.0,
            discountedMargin: 0.0,
          ),
          inventorySearchBloc: MockInventorySearchBloc(),
        )),
        expect: () => [
          CartState(isUpdating: true, updateID: "", message: ""),
          CartState(
            message: "Record saved successfully.",
            total: 283.2,
            subtotal: 267.3,
            proCoverage: 99.93,
            deliveryModels: dummyDeliveryModels,
            orderDetailModel: [dummyOrderDetail],
            isUpdating: false,
            updateID: "",
          )
        ],
      );

      blocTest<CartBloc, CartState>(
        "Change Warranties",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ChangeWarranties(
          orderID: "123",
          index: 1,
          warranties: Warranties(id: "123"),
          warrantyPrice: "123",
          orderItem: "",
          warrantyId: "123",
          warrantyName: "name",
          inventorySearchBloc: MockInventorySearchBloc(),
        )),
        expect: () => [
          CartState(orderDetailModel: [], message: "done"),
          CartState(
            total: 283.2,
            subtotal: 267.3,
            proCoverage: 99.93,
            deliveryModels: dummyDeliveryModels,
            orderDetailModel: [dummyOrderDetail],
            message: "done",
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Remove Warranties",
        build: () => cartBloc,
        act: (bloc) => bloc.add(RemoveWarranties(
          orderID: "123",
          index: 1,
          warranties: Warranties(id: "123"),
          warrantyPrice: "123",
          orderItem: "",
          warrantyId: "123",
          warrantyName: "name",
          inventorySearchBloc: MockInventorySearchBloc(),
        )),
        expect: () => [
          CartState(orderDetailModel: [], message: "done"),
          CartState(
            total: 283.2,
            subtotal: 267.3,
            proCoverage: 99.93,
            deliveryModels: dummyDeliveryModels,
            orderDetailModel: [dummyOrderDetail],
            message: "done",
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Pick Up Zip",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdatePickUpZip(
          orderID: "123",
          phone: "",
          email: "",
          firstName: "",
          lastName: "",
          searchStoreList: SearchStoreList(postalCode: "123-456"),
          searchStoreListInformation: SearchStoreListInformation(),
        )),
        expect: () => [
          CartState(
            selectedPickupStore: SearchStoreListInformation(),
            selectedPickupStoreList: SearchStoreList(postalCode: "123-456"),
            deliveryModels: [],
            pickUpZip: "123-456",
            savingAddress: true,
          ),
          CartState(
            selectedPickupStore: SearchStoreListInformation(),
            selectedPickupStoreList: SearchStoreList(postalCode: "123-456"),
            pickUpZip: "123-456",
            total: 267.3,
            subtotal: 267.3,
            proCoverage: 99.93,
            deliveryModels: dummyDeliveryModels,
            orderDetailModel: [dummyOrderDetail],
            savingAddress: false,
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Order User",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateOrderUser(
          index: 1,
          orderId: "123",
          accountId: "123",
        )),
        expect: () => [
          CartState(loadingScreen: true),
          CartState(loadingScreen: false),
          CartState(
            total: 283.2,
            subtotal: 267.3,
            proCoverage: 99.93,
            deliveryModels: dummyDeliveryModels,
            orderDetailModel: [dummyOrderDetail],
            loadingScreen: false,
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Change Recommended Address",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ChangeRecommendedAddress(
          index: 1,
          orderID: "123",
          address: "",
          email: "abc@mail.com",
          phone: "123456789",
          firstName: "John",
          lastName: "Wick",
        )),
        expect: () => [
          CartState(proceedingOrder: true),
          CartState(
              total: 283.2,
              subtotal: 267.3,
              deliveryModels: dummyDeliveryModels,
              callCompleteOrder: true,
              proceedingOrder: false,
              updateIndex: 1,
              proCoverage: 99.93,
              overrideDiscount: 0.0,
              orderDetailModel: [dummyOrderDetail],
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Change Delivery Model Is Selected With Delivery",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ChangeDeliveryModelIsSelectedWithDelivery(
            orderId: "123", firstName: "", lastName: "", email: "", phone: "", deliveryModel: DeliveryModel(type: "", address: ""))),
        expect: () => [
          CartState(deliveryModels: [], savingAddress: true),
          CartState(
            total: 267.3,
            subtotal: 267.3,
            savingAddress: false,
            proCoverage: 99.93,
            orderDetailModel: [dummyOrderDetail],
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Send Override Reason",
        build: () => cartBloc,
        act: (bloc) => bloc.add(SendOverrideReason(
          orderID: "123",
          item: Items(),
          orderLineItemID: "1",
          requestedAmount: "",
          selectedOverrideReasons: "",
          userID: "",
          inventorySearchBloc: MockInventorySearchBloc(),
          onCompleted: () {},
        )),
        expect: () => [
          CartState(isOverrideSubmitting: true),
          CartState(
            isOverrideSubmitting: false,
            total: 283.2,
            subtotal: 267.3,
            proCoverage: 99.93,
            deliveryModels: dummyDeliveryModels,
            orderDetailModel: [dummyOrderDetail],
            message: "Override Request Submitted",
            selectedOverrideReasons: "",
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Send Shipping Override Reason",
        build: () => cartBloc,
        act: (bloc) => bloc.add(SendShippingOverrideReason(
          orderID: "123",
          requestedAmount: "",
          selectedOverrideReasons: "",
          userID: "",
          onCompleted: () {},
        )),
        expect: () => [
          CartState(isOverrideSubmitting: true),
          CartState(
            isOverrideSubmitting: false,
            total: 283.2,
            subtotal: 267.3,
            proCoverage: 99.93,
            deliveryModels: dummyDeliveryModels,
            orderDetailModel: [dummyOrderDetail],
            message: "Shipping & Handling Override Request Submitted",
            selectedOverrideReasons: "",
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Reset Shipping Override Reason",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ResetShippingOverrideReason(
          orderID: "123",
          userID: "",
          onException: () {},
        )),
        expect: () => [
          CartState(
            isOverrideSubmitting: true,
            smallLoadingId: "123",
            smallLoading: true,
          ),
          CartState(
            isOverrideSubmitting: false,
            total: 283.2,
            subtotal: 267.3,
            proCoverage: 99.93,
            deliveryModels: dummyDeliveryModels,
            orderDetailModel: [dummyOrderDetail],
            message: "Shipping & Handling Override Request Deleted",
            selectedOverrideReasons: "",
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Reset Override Reason",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ResetOverrideReason(
          orderID: "123",
          userID: "",
          selectedOverrideReasons: "",
          requestedAmount: "",
          orderLineItemID: "",
          item: Items(),
          inventorySearchBloc: MockInventorySearchBloc(),
        )),
        expect: () => [
          CartState(
            isOverrideSubmitting: true,
            loadingScreen: true,
          ),
          CartState(
            isOverrideSubmitting: false,
            total: 283.2,
            subtotal: 267.3,
            proCoverage: 99.93,
            deliveryModels: dummyDeliveryModels,
            orderDetailModel: [dummyOrderDetail],
            message: "Override Request Deleted",
            selectedOverrideReasons: "",
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Refresh Shipping Override Reason",
        build: () => cartBloc,
        act: (bloc) => bloc.add(RefreshShippingOverrideReason(
          orderID: "123",
          onException: () {},
        )),
        expect: () => [
          CartState(isOverrideSubmitting: true, smallLoadingId: "123", smallLoading: true),
          CartState(
            isOverrideSubmitting: false,
            smallLoadingId: "",
            smallLoading: false,
            message: "",
            selectedOverrideReasons: "",
            total: 283.2,
            subtotal: 267.3,
            proCoverage: 99.93,
            deliveryModels: dummyDeliveryModels,
            orderDetailModel: [dummyOrderDetail],
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Add Coupon",
        build: () => cartBloc,
        act: (bloc) => bloc.add(AddCoupon(orderId: "123", couponId: "456")),
        expect: () => [
          CartState(isOverrideSubmitting: true),
          CartState(
            isOverrideSubmitting: false,
            isCouponSubmitDone: true,
            orderDetailModel: [dummyOrderDetail],
            total: 283.2,
            subtotal: 861.8800000000001,
            deleteDone: false,
            proCoverage: 99.93,
            message: "Coupon Applied\nSuccessfully",
            selectedOverrideReasons: "",
            appliedCouponDiscount: [DiscountModel()],
          ),
          CartState(
            total: 283.2,
            subtotal: 861.8800000000001,
            isCouponSubmitDone: false,
            proCoverage: 99.93,
            message: "Coupon Applied\nSuccessfully",
            appliedCouponDiscount: [DiscountModel()],
            orderDetailModel: [dummyOrderDetail],
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Remove Coupon",
        build: () => cartBloc,
        act: (bloc) => bloc.add(RemoveCoupon(orderId: "123")),
        expect: () => [
          CartState(isOverrideSubmitting: true),
          CartState(
            total: 283.2,
            subtotal: 861.8800000000001,
            isCouponSubmitDone: false,
            proCoverage: 99.93,
            message: "Coupon removed successfully",
            orderDetailModel: [dummyOrderDetail],
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Notify Contact Is Missing",
        build: () => cartBloc,
        act: (bloc) => bloc.add(NotifyContactIsMissing()),
        expect: () => [
          CartState(isContactMissing: true),
          CartState(isContactMissing: false),
        ],
      );

      late GlobalKey<FormState> formKey;
      blocTest<CartBloc, CartState>(
        "Set Shipping Credential",
        build: () => cartBloc,
        setUp: () => formKey = GlobalKey(),
        act: (bloc) => bloc.add(SetShippingCredential(
          shippingEmail: "abc@mail.com",
          shippingFName: "John",
          shippingLName: "Wick",
          shippingPhone: "123456789",
          shippingFormKey: formKey,
        )),
        expect: () => [
          CartState(
            shippingEmail: "abc@mail.com",
            shippingFName: "John",
            shippingLName: "Wick",
            shippingPhone: "123456789",
            shippingFormKey: formKey,
          ),
        ],
      );
    },
  );


  group(
    "Failure Scenarios",
    () {
      setUp(() => successScenario = false);

      blocTest<CartBloc, CartState>(
        "Submit Quote Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(SubmitQuote(email: "abc.mail.com", expiration: "123", orderId: "1234", phone: "09000000", subtotal: "1000")),
        expect: () {
          return [
            CartState(submittingQuote: true),
            CartState(submittingQuote: false, submitQuoteDone: true, currentQuoteID: "", message: "Quote failed to submit"),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Get Recommended Addresses Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(GetRecommendedAddresses(
          orderId: "a1O6C000001OKGiUAO",
          recordId: "0014M00001nv3BwQAI",
          index: 2,
          address1: "418 Wilbur Rd",
          address2: "",
          country: "United States",
          city: "Thousand Oaks",
          state: "California",
          postalCode: "91360-5405",
          isShipping: true,
          isBilling: false,
        )),
        expect: () {
          return [
            CartState(
              recommendedAddress: "",
              proceedingOrder: true,
              recommendedAddressLine1: "",
              recommendedAddressLine2: "",
              recommendedLabel: "",
              recommendedContactPointAddressId: "",
              recommendedAddressLineCity: "",
              recommendedAddressLineCountry: "",
              recommendedAddressLineState: "",
              recommendedAddressLineZipCode: "",
              orderAddressLine1: "",
              orderAddressLine2: "",
              orderLabel: "",
              orderContactPointAddressId: "",
              orderAddressLineCity: "",
              orderAddressLineCountry: "",
              orderAddressLineState: "",
              orderAddressLineZipCode: "",
              showRecommendedDialog: false,
              orderAddress: "",
              updateIndex: 2,
            ),
            CartState(
                message: "Recommended address not found",
                recommendedAddress: "",
                recommendedAddressLine1: "418 Wilbur Rd",
                recommendedAddressLineCity: "Thousand Oaks",
                recommendedAddressLineCountry: "United States",
                recommendedAddressLineState: "California",
                proceedingOrder: false,
                recommendedAddressLineZipCode: "91360-5405",
                showRecommendedDialog: false,
                orderAddress: "",
                updateIndex: 2,
            ),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Delete Order Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(
          DeleteOrder(
            orderId: "123X",
            reason: "Dummy reason",
            inventorySearchBloc: MockInventorySearchBloc(),
            onSuccess: () {},
          ),
        ),
        expect: () {
          return [
            CartState(deleteDone: false, loadingScreen: true),
            CartState(deleteDone: false, loadingScreen: false, message: "Failed to delete order"),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Add To Cart Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(AddToCart(
          records: Items(
            itemStatus: "R1",
            posSkuId: "123456",
            productId: "site1231321",
            condition: "New",
            warrantyPrice: 0.0,
            unitPrice: 499.99,
            quantity: 3.0,
            pimSkuId: "123124141243",
            overridePrice: 0.0,
            marginValue: 290.99,
            margin: 58.2,
            itemNumber: "J123123123",
            itemId: "",
            itemDesc: "Dummy description",
            discountedMarginValue: -290.0,
            discountedMargin: 0.0,
          ),
          inventorySearchBloc: MockInventorySearchBloc(),
          customerID: "0014M00001nv3BwQAI",
          orderID: "a1O6C000001OKGiUAO",
          quantity: -1,
        )),
        expect: () {
          return [
            CartState(message: "", isUpdating: true, updateID: ""),
            CartState(
              isUpdating: false,
              updateID: "",
              message: "Cannot update cart. Check your network connection!",
            ),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Get Override Reasons Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(GetOverrideReasons()),
        expect: () => [
          CartState(overrideReasons: [], isOverrideLoading: false)
        ],
      );

      blocTest<CartBloc, CartState>(
        "Get Shipping Override Reasons Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(GetShippingOverrideReasons()),
        expect: () => [
          CartState(isOverrideLoading: true),
          CartState(overrideReasons: [], isOverrideLoading: false)
        ],
      );

      blocTest<CartBloc, CartState>(
        "Get Delete Reasons Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(GetDeleteReasons()),
        expect: () => [
          CartState(fetchingReason: true),
          CartState(reasonList: [], fetchingReason: false),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Get Warranties Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(GetWarranties(index: 2, skuEntId: "123")),
        expect: () => [
          CartState(orderDetailModel: [], message: "done"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Change Delete Reason Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ChangeDeleteReason(reason: "dummy reason")),
        expect: () => [
          CartState(selectedReason: "dummy reason"),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Save Addresses Data Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(SaveAddressesData(
          orderId: "123",
          addressModel: AddressList(
            address1: "418 E Wilbur Rd",
            address2: "",
            addressLabel: "",
            city: "Thousand Oaks",
            state: "California",
            postalCode: "91360-5405",
            addAddress: false,
            isPrimary: true,
          ),
          isDefault: true,
          email: "abc@email.com",
          phone: "123456789",
          firstName: "John",
          lastName: "Wick",
        )),
        expect: () {
          return [
            CartState(proceedingOrder: true),
            CartState(proceedingOrder: false),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Change Address Is Selected With Address Failure",
        build: () => cartBloc,
        setUp: () => cartBloc..add(AddInAddressModel(value: AddressList(
          address1: "",
          address2: "",
          city: "",
          country: "",
          state: "",
          postalCode: "",
          addressLabel: "",
          addAddress: false,
          isSelected: false,
          isPrimary: true,
        )))..add(AddInAddressModel(value: AddressList(
          address1: "418 E Wilbur Rd",
          address2: "",
          city: "Thousand Oaks",
          country: "",
          state: "California",
          postalCode: "91360-5405",
          addressLabel: "",
          addAddress: false,
          isSelected: false,
          isPrimary: true,
        ))),
        act: (bloc) => bloc.add(ChangeAddressIsSelectedWithAddress(
            addressModel: AddressList(
              address1: "418 E Wilbur Rd",
              address2: "",
              city: "Thousand Oaks",
              country: "",
              state: "California",
              postalCode: "91360-5405",
              addressLabel: "",
              addAddress: false,
              isSelected: true,
              isPrimary: true,
            ),
            index: 1,
            orderID: "123",
            email: "abc@email.com",
            phone: "123456789",
            firstName: "John",
            lastName: "Wick",
          )),
        expect: () {
          return [
            CartState(
              addressModel: [
              AddressList(
                address1: "",
                address2: "",
                city: "",
                country: "",
                state: "",
                postalCode: "",
                addressLabel: "",
                addAddress: false,
                isSelected: false,
                isPrimary: true,
              ),
              AddressList(
                address1: "418 E Wilbur Rd",
                address2: "",
                city: "Thousand Oaks",
                country: "",
                state: "California",
                postalCode: "91360-5405",
                addressLabel: "",
                addAddress: false,
                isSelected: true,
                isPrimary: true,
              ),
            ],
              selectedAddressIndex: 0,
              savingAddress: false,
            ),
            CartState(
              addressModel: [
              AddressList(
                address1: "",
                address2: "",
                city: "",
                country: "",
                state: "",
                postalCode: "",
                addressLabel: "",
                addAddress: false,
                isSelected: false,
                isPrimary: true,
              ),
              AddressList(
                address1: "418 E Wilbur Rd",
                address2: "",
                city: "Thousand Oaks",
                country: "",
                state: "California",
                postalCode: "91360-5405",
                addressLabel: "",
                addAddress: false,
                isSelected: true,
                isPrimary: true,
              ),
            ],
              selectedAddressIndex: 1,
              savingAddress: true,
            ),
          ];
        },
      );

      blocTest<CartBloc, CartState>(
        "Update Pick Up Zip Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdatePickUpZip(
          orderID: "123",
          phone: "",
          email: "",
          firstName: "",
          lastName: "",
          searchStoreList: SearchStoreList(postalCode: "123-456"),
          searchStoreListInformation: SearchStoreListInformation(),
        )),
        expect: () => [
          CartState(
            selectedPickupStore: SearchStoreListInformation(),
            selectedPickupStoreList: SearchStoreList(postalCode: "123-456"),
            deliveryModels: [],
            pickUpZip: "123-456",
            savingAddress: true,
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Update Order User Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(UpdateOrderUser(
          index: 1,
          orderId: "123",
          accountId: "123",
        )),
        expect: () => [
          CartState(loadingScreen: true),
          CartState(message: "User cannot be assigned", loadingScreen: false),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Change Recommended Address Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ChangeRecommendedAddress(
          index: 1,
          orderID: "123",
          address: "",
          email: "abc@mail.com",
          phone: "123456789",
          firstName: "John",
          lastName: "Wick",
        )),
        expect: () => [
          CartState(proceedingOrder: true),
          CartState(
            callCompleteOrder: false,
            proceedingOrder: false,
            message: "Failed to complete order. Recommended address is not applicable",
            recommendedAddress: "",
            orderAddress: "",
            updateIndex: 1,
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Change Delivery Model Is Selected With Delivery Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ChangeDeliveryModelIsSelectedWithDelivery(
            orderId: "123", firstName: "", lastName: "", email: "", phone: "", deliveryModel: DeliveryModel(type: "", address: ""))),
        expect: () => [
          CartState(deliveryModels: [], savingAddress: true),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Send Override Reason Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(SendOverrideReason(
          orderID: "123",
          item: Items(),
          orderLineItemID: "1",
          requestedAmount: "",
          selectedOverrideReasons: "",
          userID: "",
          inventorySearchBloc: MockInventorySearchBloc(),
          onCompleted: () {},
        )),
        expect: () => [
          CartState(isOverrideSubmitting: true),
          CartState(
            isOverrideSubmitting: false,
            orderDetailModel: [],
            message: "Override Request Declined",
            selectedOverrideReasons: "",
          )
        ],
      );

      blocTest<CartBloc, CartState>(
        "Send Shipping Override Reason Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(SendShippingOverrideReason(
          orderID: "123",
          requestedAmount: "",
          selectedOverrideReasons: "",
          userID: "",
          onCompleted: () {},
        )),
        expect: () => [
          CartState(isOverrideSubmitting: true),
          CartState(
              isOverrideSubmitting: false,
              orderDetailModel: [],
              message: "Shipping & Handling Override Request Declined",
              selectedOverrideReasons: "",
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Reset Shipping Override Reason Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ResetShippingOverrideReason(
          orderID: "123",
          userID: "",
          onException: () {},
        )),
        expect: () => [
          CartState(
            isOverrideSubmitting: true,
            smallLoadingId: "123",
            smallLoading: true,
          ),
          CartState(
              isOverrideSubmitting: false,
              smallLoadingId: "",
              smallLoading: false,
              orderDetailModel: [],
              message: "Shipping & Handling Delete Request Declined",
              selectedOverrideReasons: "",
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Reset Override Reason Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(ResetOverrideReason(
          orderID: "123",
          userID: "",
          selectedOverrideReasons: "",
          requestedAmount: "",
          orderLineItemID: "",
          item: Items(),
          inventorySearchBloc: MockInventorySearchBloc(),
        )),
        expect: () => [
          CartState(isOverrideSubmitting: true, loadingScreen: true),
          CartState(isOverrideSubmitting: false, orderDetailModel: [], message: "Delete Request Declined", selectedOverrideReasons: "", loadingScreen: true,),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Refresh Shipping Override Reason Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(RefreshShippingOverrideReason(
          orderID: "123",
          onException: () {},
        )),
        expect: () => [
          CartState(isOverrideSubmitting: true, smallLoadingId: "123", smallLoading: true),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Add Coupon Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(AddCoupon(orderId: "123", couponId: "456")),
        expect: () => [
          CartState(isOverrideSubmitting: true),
          CartState(
              isOverrideSubmitting: false,
              orderDetailModel: [],
              message: "Can not apply your coupon.",
              selectedOverrideReasons: "",
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        "Remove Coupon Failure",
        build: () => cartBloc,
        act: (bloc) => bloc.add(RemoveCoupon(orderId: "123")),
        expect: () => [
          CartState(isOverrideSubmitting: true),
          CartState(
              isOverrideSubmitting: false,
              orderDetailModel: [],
              message: "Can not apply your coupon.",
              selectedOverrideReasons: "",
          ),
        ],
      );
    },
  );
}