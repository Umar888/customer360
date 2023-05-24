import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gc_customer_app/bloc/cart_bloc/send_tax_info.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/cart_reporsitory/cart_repository.dart';
import 'package:gc_customer_app/data/reporsitories/favourite_brand-screen_repository/favourite_brand_screen_repository.dart';
import 'package:gc_customer_app/data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'package:gc_customer_app/models/cart_model/assign_user_model.dart';
import 'package:gc_customer_app/models/cart_model/delete_order_model.dart';
import 'package:gc_customer_app/models/cart_model/discount_model.dart';
import 'package:gc_customer_app/models/cart_model/product_eligibility_model.dart';
import 'package:gc_customer_app/models/cart_model/shipping_reason_list_model.dart';
import 'package:gc_customer_app/models/cart_model/submit_quote_model.dart';
import 'package:gc_customer_app/models/cart_model/submit_shipping_override.dart';
import 'package:gc_customer_app/models/inventory_search/cart_model.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart' as cim;
import 'package:gc_customer_app/models/store_search_zip_code_model/search_store_zip.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/primitives/icon_system.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

import '../../intermediate_widgets/credit_card_widget/model/credit_card_model_save.dart';
import '../../models/address_models/address_model.dart';
import '../../models/address_models/delivery_model.dart';
import '../../models/cart_model/cart_popup_menu.dart';
import '../../models/cart_model/cart_warranties_model.dart';
import '../../models/cart_model/recommended_address_model.dart';
import '../../models/cart_model/tax_model.dart';
import '../../models/common_models/child_sku_model.dart';
import '../../models/common_models/records_class_model.dart';
import '../../models/inventory_search/update_cart_model.dart';
import '../../models/override_model/override_reason_model.dart';
import '../../models/override_model/submit_override_request.dart';

part 'cart_event.dart';

part 'cart_state.dart';

typedef CompleteOrderVoidCallback = void Function(
    CartState cartState, List<CreditCardModelSave> cards, bool isPickup);

class CartBloc extends Bloc<CartEvent, CartState> {
  CartRepository cartRepository;
  LandingScreenRepository landingScreenRepository = LandingScreenRepository();
  FavouriteBrandScreenRepository favouriteBrandScreenRepository =
      FavouriteBrandScreenRepository();

  CartBloc({required this.cartRepository}) : super(CartState()) {
    on<UpdateAddAddress>((event, emit) async {
      emit(state.copyWith(addAddress: event.value));
    });
    on<UpdateWarranty>((event, emit) async {
      final responseJson = await cartRepository.updateWarranties(
          event.warranties, event.itemsId);
      log(jsonEncode(responseJson.data));
    });
    on<GetProductEligibility>((event, emit) async {
      emit(state.copyWith(moreInfo: [], mainNodeData: [], fetchMoreInfo: true));
      var id = await SharedPreferenceService().getValue(loggedInAgentId);
      final responseJson =
          await cartRepository.getItemEligibility(event.itemSKUId, id);
      emit(state.copyWith(
          moreInfo: responseJson.moreInfo ?? [],
          mainNodeData: responseJson.mainNodeData ?? [],
          fetchMoreInfo: false));
    });
    on<UpdateLoadingScreen>((event, emit) async {
      emit(state.copyWith(loadingScreen: event.value));
    });
    on<UpdateShowAddCard>((event, emit) async {
      emit(state.copyWith(showAddCard: event.value));
    });
    on<UpdateShowMessageField>((event, emit) async {
      emit(state.copyWith(showMessageField: event.value));
    });
    on<UpdateSubmitQuoteDone>((event, emit) async {
      emit(state.copyWith(submitQuoteDone: event.value));
    });
    on<UpdateCurrentQuote>((event, emit) async {
      emit(state.copyWith(currentQuoteID: event.value));
    });
    on<SubmitQuote>((event, emit) async {
      emit(state.copyWith(submittingQuote: true));
      QuoteSubmitModel quoteSubmitModel = await quoteSubmit(event.email,
          event.phone, event.expiration, event.orderId, event.subtotal);
      log(jsonEncode(quoteSubmitModel.toJson()));
      if (quoteSubmitModel.isSuccess!) {
        emit(state.copyWith(
            submittingQuote: false,
            submitQuoteDone: true,
            currentQuoteID: quoteSubmitModel.message,
            message: "Quote saved successfully"));
      } else {
        emit(state.copyWith(
            submittingQuote: false,
            submitQuoteDone: true,
            currentQuoteID: "",
            message: "Quote failed to submit"));
      }
    });
    on<PageLoad>((event, emit) async {
      print("PageLoad is called => ");
      emit(state.copyWith(
          customerInfoModel: cim.CustomerInfoModel(records: [cim.Records(id: null)]),
          cartStatus: CartStatus.loadState, orderDetailModel: [
        OrderDetail(items: [Items(isCartAdding: false, quantity: 0)])
      ]));

      List<OrderDetail>? orderDetailModel = [];
      var loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);
      final getCalculateResp = await cartRepository.getTaxCalculate(event.orderID, loggedInUserId);
      TaxCalculateModel taxInfo = TaxCalculateModel.fromJson(getCalculateResp);

//      final responseJson = await cartRepository.getOrders(event.orderID);
      if (taxInfo.orderDetail != null) {
        orderDetailModel.add(taxInfo.orderDetail!);
        if((event.customerId.records == null ||
            event.customerId.records!.isEmpty ||
            event.customerId.records!.first.id == null) &&
            (taxInfo.orderDetail!.customerId??"").isNotEmpty){
          cim.CustomerInfoModel customerInfoModel = await getCustomerInfo(taxInfo.orderDetail!.customerId??"");
          if(customerInfoModel.records != null || customerInfoModel.records!.first.id != null){
            emit(state.copyWith(
              message: "done",
              customerInfoModel: customerInfoModel
            ));
          }
          else{
            emit(state.copyWith(
                message: "done",
                customerInfoModel: event.customerId
            ));
          }
        }
        else{
          emit(state.copyWith(
              message: "done",
              customerInfoModel: event.customerId
          ));
        }
        double proCoverage = 0.0;
        double overrideDiscount = 0.0;
        if (orderDetailModel.isNotEmpty) {
          for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
            proCoverage = proCoverage +
                (orderDetailModel[0].items![k].warrantyPrice! *
                    orderDetailModel[0].items![k].quantity!);
            overrideDiscount = overrideDiscount +
                (orderDetailModel[0]
                        .items![k]
                        .overridePriceApproval!
                        .toLowerCase()
                        .contains("approved")
                    ? (orderDetailModel[0].items![k].unitPrice! -
                            orderDetailModel[0].items![k].overridePrice!) *
                        orderDetailModel[0].items![k].quantity!
                    : 0.0);
          }

          emit(state.copyWith(
              cartStatus: CartStatus.successState,
              total: orderDetailModel[0].total!,
              subtotal: orderDetailModel[0].subtotal,
              proCoverage: proCoverage,
              overrideDiscount: overrideDiscount,
              orderDetailModel: orderDetailModel,
              activeStep: 0,
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
                DeliveryModel(
                    type: "Pick-up",
                    address: "",
                    isSelected: false,
                    price: "0",
                    time: ""),
              ],
              maxExtent: 0.380,
              minExtent: 0.2,
              initialExtent: 0.2,
              isExpanded: false));

          List<ItemsOfCart> itemsOfCart = [];
          List<Records> records = [];
          for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
            itemsOfCart.add(ItemsOfCart(
                itemQuantity: orderDetailModel[0].items![k].quantity.toString(),
                itemId: orderDetailModel[0].items![k].itemNumber!,
                itemName: orderDetailModel[0].items![k].itemDesc!,
                itemPrice: orderDetailModel[0].items![k].unitPrice.toString(),
                itemProCoverage:
                    (orderDetailModel[0].items![k].warrantyPrice ?? 0.0)
                        .toString()));
            records.add(Records(
                productId: orderDetailModel[0].items![k].productId,
                quantity: orderDetailModel[0].items![k].quantity.toString(),
                productName: orderDetailModel[0].items![k].itemDesc,
                oliRecId: orderDetailModel[0].items![k].itemId!,
                productPrice:
                    orderDetailModel[0].items![k].unitPrice!.toString(),
                productImageUrl:
                    orderDetailModel[0].items![k].imageUrl.toString(),
                childskus: [
                  Childskus(
                    skuENTId: orderDetailModel[0].items![k].itemNumber,
                    skuPrice: (orderDetailModel[0].items![k].unitPrice ?? 0)
                        .toString(),
                    skuCondition: orderDetailModel[0].items![k].condition,
                    skuPIMId: orderDetailModel[0].items![k].pimSkuId,
                    gcItemNumber: orderDetailModel[0].items![k].posSkuId,
                    pimStatus: orderDetailModel[0].items![k].itemStatus,
                  )
                ]));
          }
          event.inventorySearchBloc.add(SetCart(
              itemOfCart: itemsOfCart,
              records: records,
              orderId: event.orderID));
          List<DeliveryModel> deliveryModel = [];
          deliveryModel.add(state.deliveryModels.isNotEmpty
              ? state.deliveryModels.first
              : DeliveryModel(
                  type: "Pick-up",
                  address: "",
                  isSelected: false,
                  price: "0",
                  time: ""));
          for (ShippingMethod shippingMethodsModel
              in taxInfo.shippingMethod ?? []) {
            if (orderDetailModel[0].shippingMethod ==
                shippingMethodsModel.values) {
              deliveryModel.add(DeliveryModel(
                  type: shippingMethodsModel.values,
                  address: shippingMethodsModel.label,
                  isSelected: true,
                  price: "",
                  time: ""));
            } else {
              deliveryModel.add(DeliveryModel(
                  type: shippingMethodsModel.values,
                  address: shippingMethodsModel.label,
                  isSelected: false,
                  price: "",
                  time: ""));
            }
          }
          List<DiscountModel> discountModels = [];
          if (getCalculateResp["discountParam"] != null &&
              getCalculateResp["discountParam"].isNotEmpty) {
            discountModels = getCalculateResp["discountParam"]
                .map<DiscountModel>((e) => DiscountModel.fromJson(e))
                .toList();
          }
          emit(state.copyWith(
              appliedCouponDiscount: discountModels,
              deliveryModels: deliveryModel));

          // SendTaxInfoModel sendTaxInfoModel = await cartRepository.sendTaxInfo(
          //     orderId: event.orderID,
          //     firstName: cartDetailModel.orderDetail!.firstName ?? "",
          //     lastName: cartDetailModel.orderDetail!.lastname ?? "",
          //     middleName: cartDetailModel.orderDetail!.middleName ?? "",
          //     phoneName: cartDetailModel.orderDetail!.phone ?? "",
          //     shippingAddress: cartDetailModel.orderDetail!.shippingAddress ?? "",
          //     shippingCity: cartDetailModel.orderDetail!.shippingCity ?? "",
          //     shippingCountry: cartDetailModel.orderDetail!.shippingCountry ?? "",
          //     shippingState: cartDetailModel.orderDetail!.shippingState ?? "",
          //     shippingEmail: cartDetailModel.orderDetail!.shippingEmail ?? "",
          //     shippingZipCode: cartDetailModel.orderDetail!.shippingZipcode ?? "");
          // var loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);
          //if (sendTaxInfoModel.isSuccess!) {
          //}
        }
        else {
          emit(state.copyWith(
              cartStatus: CartStatus.successState,
              orderDetailModel: [],
              activeStep: 0,
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
                DeliveryModel(
                    type: "Pick-up",
                    address: "",
                    isSelected: false,
                    price: "0",
                    time: ""),
              ],
              maxExtent: 0.380,
              minExtent: 0.2,
              initialExtent: 0.2,
              isExpanded: false,
              cartPopupMenu: [
                CartPopupMenu(
                    name: "Quote Log",
                    icon: SvgPicture.asset(
                      IconSystem.quoteLog,
                      package: 'gc_customer_app',
                    )),
                CartPopupMenu(
                    name: "Share",
                    icon: SvgPicture.asset(
                      IconSystem.share,
                      package: 'gc_customer_app',
                    )),
                CartPopupMenu(
                    name: "Notes",
                    icon: SvgPicture.asset(
                      IconSystem.notes,
                      package: 'gc_customer_app',
                    )),
                CartPopupMenu(
                    name: "Closed Lost",
                    icon: SvgPicture.asset(
                      IconSystem.closedLost,
                      package: 'gc_customer_app',
                    )),
              ]));
        }
      }
      else {
        emit(state.copyWith(
            cartStatus: CartStatus.successState,
            orderDetailModel: [],
            activeStep: 0,
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
            ],
            deliveryModels: [
              DeliveryModel(
                  type: "Pick-up",
                  address: "",
                  isSelected: false,
                  price: "0",
                  time: ""),
            ],
            maxExtent: 0.380,
            minExtent: 0.2,
            initialExtent: 0.2,
            isExpanded: false,
            cartPopupMenu: [
              CartPopupMenu(
                  name: "Quote Log",
                  icon: SvgPicture.asset(
                    IconSystem.quoteLog,
                    package: 'gc_customer_app',
                  )),
              CartPopupMenu(
                  name: "Share",
                  icon: SvgPicture.asset(
                    IconSystem.share,
                    package: 'gc_customer_app',
                  )),
              CartPopupMenu(
                  name: "Notes",
                  icon: SvgPicture.asset(
                    IconSystem.notes,
                    package: 'gc_customer_app',
                  )),
              CartPopupMenu(
                  name: "Closed Lost",
                  icon: SvgPicture.asset(
                    IconSystem.closedLost,
                    package: 'gc_customer_app',
                  )),
            ]));
      }
    });
    on<ReloadCart>((event, emit) async {
      print("ReloadCart is called => ");
      emit(state.copyWith(
          smallLoading: event.smallLoading,
          smallLoadingId: event.smallLoadingId));

      List<OrderDetail>? orderDetailModel = [];

      var loggedInUserId =
          await SharedPreferenceService().getValue(loggedInAgentId);
      final getCalculateResp =
          await cartRepository.getTaxCalculate(event.orderID, loggedInUserId);
      TaxCalculateModel shippingModel =
          TaxCalculateModel.fromJson(getCalculateResp);
      // final responseCartNew = await cartRepository.getOrders(event.orderID);
      // CartDetailModel cartDetailModelNew =
      //     CartDetailModel.fromJson(responseCartNew.data);
      if (shippingModel.orderDetail != null) {
        orderDetailModel.add(shippingModel.orderDetail!);

        double proCoverage = 0.0;
        double overrideDiscount = 0.0;
        if (orderDetailModel.isNotEmpty) {
          for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
            proCoverage = proCoverage +
                (orderDetailModel[0].items![k].warrantyPrice! *
                    orderDetailModel[0].items![k].quantity!);
            overrideDiscount = overrideDiscount +
                (orderDetailModel[0]
                        .items![k]
                        .overridePriceApproval!
                        .toLowerCase()
                        .contains("approved")
                    ? (orderDetailModel[0].items![k].unitPrice! -
                            orderDetailModel[0].items![k].overridePrice!) *
                        orderDetailModel[0].items![k].quantity!
                    : 0.0);
          }
          List<ItemsOfCart> itemsOfCart = [];
          List<Records> records = [];
          for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
            itemsOfCart.add(ItemsOfCart(
                itemQuantity: orderDetailModel[0].items![k].quantity.toString(),
                itemId: orderDetailModel[0].items![k].itemNumber!,
                itemName: orderDetailModel[0].items![k].itemDesc!,
                itemProCoverage:
                    (orderDetailModel[0].items![k].warrantyPrice ?? 0.0)
                        .toString(),
                itemPrice: orderDetailModel[0].items![k].unitPrice.toString()));
            records.add(Records(
                productId: orderDetailModel[0].items![k].productId,
                quantity: orderDetailModel[0].items![k].quantity.toString(),
                productName: orderDetailModel[0].items![k].itemDesc,
                oliRecId: orderDetailModel[0].items![k].itemId!,
                productPrice:
                    orderDetailModel[0].items![k].unitPrice!.toString(),
                productImageUrl:
                    orderDetailModel[0].items![k].imageUrl.toString(),
                childskus: [
                  Childskus(
                    skuENTId: orderDetailModel[0].items![k].itemNumber,
                    skuCondition: orderDetailModel[0].items![k].condition,
                    skuPrice: (orderDetailModel[0].items![k].unitPrice ?? 0)
                        .toString(),
                    skuPIMId: orderDetailModel[0].items![k].pimSkuId,
                    gcItemNumber: orderDetailModel[0].items![k].posSkuId,
                    pimStatus: orderDetailModel[0].items![k].itemStatus,
                  )
                ]));
          }
          event.inventorySearchBloc.add(SetCart(
              itemOfCart: itemsOfCart,
              records: records,
              orderId: event.orderID));
        }

        List<DeliveryModel> deliveryModel = [];

        deliveryModel.add(state.deliveryModels.isNotEmpty
            ? state.deliveryModels.first
            : DeliveryModel(
                type: "Pick-up",
                address: "",
                isSelected: false,
                price: "0",
                time: ""));
        for (ShippingMethod shippingMethodsModel
            in shippingModel.shippingMethod ?? []) {
          if (shippingModel.orderDetail!.shippingMethod ==
              shippingMethodsModel.values) {
            deliveryModel.add(DeliveryModel(
                type: shippingMethodsModel.values,
                address: shippingMethodsModel.label,
                isSelected: true,
                price: "",
                time: ""));
          } else {
            deliveryModel.add(DeliveryModel(
                type: shippingMethodsModel.values,
                address: shippingMethodsModel.label,
                isSelected: false,
                price: "",
                time: ""));
          }
        }
        emit(state.copyWith(
            smallLoadingId: "",
            total: orderDetailModel[0].total!,
            subtotal: orderDetailModel[0].subtotal,
            proCoverage: proCoverage,
            overrideDiscount: overrideDiscount,
            deliveryModels: deliveryModel,
            orderDetailModel: orderDetailModel,
            smallLoading: false));
      } else {
        emit(state.copyWith(smallLoading: false, smallLoadingId: ""));
      }
    });
    on<SetShippingCredential>((event, emit) async {
      emit(state.copyWith(
        shippingPhone: event.shippingPhone,
        shippingEmail: event.shippingEmail,
        shippingFormKey: event.shippingFormKey,
        shippingFName: event.shippingFName,
        shippingLName: event.shippingLName,
      ));
    });
    on<SaveAddressesData>((event, emit) async {
      print("SaveAddressesData is called => ");
      String userRecordId = await SharedPreferenceService().getValue(agentId);
      if ((userRecordId).isNotEmpty) {
        emit(state.copyWith(
          proceedingOrder: true,
        ));

        String email = await SharedPreferenceService().getValue(agentEmail);
        String phone = await SharedPreferenceService().getValue(agentPhone);
        String firstName =
            await SharedPreferenceService().getValue(savedAgentFirstName);
        String lastName =
            await SharedPreferenceService().getValue(savedAgentLastName);

        try {
          await cartRepository.saveCartAddresses(
              userRecordId, event.addressModel, event.isDefault);
          await cartRepository.sendTaxInfoAddress(
              orderId: event.orderId,
              shippingEmail: event.email,
              phoneName: event.phone,
              firstName: event.firstName,
              lastName: event.lastName,
              middleName: state.orderDetailModel.isNotEmpty
                  ? state.orderDetailModel.first.middleName ?? ""
                  : "",
              shippingAddress: event.addressModel.address1 ?? "",
              shippingAddress2: event.addressModel.address2 ?? "",
              shippingCity: event.addressModel.city ?? "",
              shippingCountry: event.addressModel.country ?? "",
              shippingState: event.addressModel.state ?? "",
              shippingMethodName: state.orderDetailModel.isNotEmpty
                  ? state.orderDetailModel.first.shippingMethod ?? ""
                  : "",
              shippingZipCode: event.addressModel.postalCode ?? "");

          List<OrderDetail>? orderDetailModel = [];

          var loggedInUserId =
              await SharedPreferenceService().getValue(loggedInAgentId);
          final getCalculateResp = await cartRepository.getTaxCalculate(
              event.orderId, loggedInUserId);
          TaxCalculateModel shippingModel =
              TaxCalculateModel.fromJson(getCalculateResp);
          // final responseCartNew = await cartRepository.getOrders(event.orderId);
          // CartDetailModel cartDetailModelNew = CartDetailModel.fromJson(responseCartNew.data);

          if (shippingModel.orderDetail != null) {
            orderDetailModel.add(shippingModel.orderDetail!);
            double proCoverage = 0.0;
            double overrideDiscount = 0.0;
            if (orderDetailModel.isNotEmpty) {
              for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
                proCoverage = proCoverage +
                    (orderDetailModel[0].items![k].warrantyPrice! *
                        orderDetailModel[0].items![k].quantity!);
                overrideDiscount = overrideDiscount +
                    (orderDetailModel[0]
                            .items![k]
                            .overridePriceApproval!
                            .toLowerCase()
                            .contains("approved")
                        ? (orderDetailModel[0].items![k].unitPrice! -
                                orderDetailModel[0].items![k].overridePrice!) *
                            orderDetailModel[0].items![k].quantity!
                        : 0.0);
              }
            }

            List<DeliveryModel> deliveryModel = [];

            deliveryModel.add(state.deliveryModels.isNotEmpty
                ? state.deliveryModels.first
                : DeliveryModel(
                    type: "Pick-up",
                    address: "",
                    isSelected: false,
                    price: "0",
                    time: ""));
            for (ShippingMethod shippingMethodsModel
                in shippingModel.shippingMethod ?? []) {
              if (shippingModel.orderDetail!.shippingMethod ==
                      shippingMethodsModel.values
                  //&& (email.isNotEmpty || state.shippingEmail.isNotEmpty)
                  // && (phone.isNotEmpty || state.shippingPhone.isNotEmpty) &&
                  // (firstName.isNotEmpty || state.shippingFName.isNotEmpty) &&
                  // (lastName.isNotEmpty || state.shippingLName.isNotEmpty)
                  ) {
                deliveryModel.add(DeliveryModel(
                    type: shippingMethodsModel.values,
                    address: shippingMethodsModel.label,
                    isSelected: true,
                    price: "",
                    time: ""));
              } else {
                deliveryModel.add(DeliveryModel(
                    type: shippingMethodsModel.values,
                    address: shippingMethodsModel.label,
                    isSelected: false,
                    price: "",
                    time: ""));
              }
            }
            if (shippingModel.orderDetail!.shippingMethod ==
                    "Pick From Store" &&
                (shippingModel.orderDetail!.shippingZipcode ?? "").isNotEmpty) {
              deliveryModel[0].isSelected = true;
              deliveryModel[0].name =
                  shippingModel.orderDetail!.selectedStoreCity ?? "";
            } else {
              deliveryModel[0].name = "";
              deliveryModel[0].time = "";
              deliveryModel[0].pickupAddress = "";
            }
            var userId = await SharedPreferenceService().getValue(agentId);
            AddressesModel addressesModel =
                await cartRepository.fetchAddresses(userId);

            int selectedIndex = -1;
            // if((email.isNotEmpty || state.shippingEmail.isNotEmpty) &&
            //     (phone.isNotEmpty || state.shippingPhone.isNotEmpty) &&
            //     (firstName.isNotEmpty || state.shippingFName.isNotEmpty) &&
            //     (lastName.isNotEmpty || state.shippingLName.isNotEmpty)){
            if (addressesModel.addressList!
                .where((element) =>
                    element.postalCode!.toLowerCase().trim() ==
                        orderDetailModel[0]
                            .shippingZipcode!
                            .toLowerCase()
                            .trim() &&
                    element.state!.toLowerCase().trim() ==
                        orderDetailModel[0]
                            .shippingState!
                            .replaceAll("CA", "California")
                            .replaceAll("NY", "New York")
                            .toLowerCase()
                            .trim() &&
                    element.address1!.toLowerCase().trim() ==
                        orderDetailModel[0]
                            .shippingAddress!
                            .toLowerCase()
                            .trim() &&
                    element.address2!.toLowerCase().trim() ==
                        orderDetailModel[0]
                            .shippingAddress2!
                            .toLowerCase()
                            .trim() &&
                    element.city!.toLowerCase().trim() ==
                        orderDetailModel[0].shippingCity!.toLowerCase().trim())
                .isEmpty) {
              selectedIndex = 0;
              print("this is selected index0 $selectedIndex");
            } else {
              AddressList addressList = addressesModel.addressList!.firstWhere(
                  (element) =>
                      element.postalCode!.toLowerCase().trim() ==
                          orderDetailModel[0]
                              .shippingZipcode!
                              .toLowerCase()
                              .trim() &&
                      element.state!.toLowerCase().trim() ==
                          orderDetailModel[0]
                              .shippingState!
                              .replaceAll("CA", "California")
                              .replaceAll("NY", "New York")
                              .toLowerCase()
                              .trim() &&
                      element.address1!.toLowerCase().trim() ==
                          orderDetailModel[0]
                              .shippingAddress!
                              .toLowerCase()
                              .trim() &&
                      element.address2!.toLowerCase().trim() ==
                          orderDetailModel[0]
                              .shippingAddress2!
                              .toLowerCase()
                              .trim() &&
                      element.city!.toLowerCase().trim() ==
                          orderDetailModel[0]
                              .shippingCity!
                              .toLowerCase()
                              .trim());
              selectedIndex = addressesModel.addressList!.indexOf(addressList);
              print("this is selected index1 $selectedIndex");
            }
            //}

            if (addressesModel.addressList!.isNotEmpty) {
              addressesModel.addressList![0].isPrimary = true;
              addressesModel.addressList![selectedIndex].isSelected = true;
              addressesModel.addressList![selectedIndex].isFacing = true;
            }
            emit(state.copyWith(
                addAddress: false,
                selectedAddressIndex: selectedIndex + 1,
                proceedingOrder: false,
                total: orderDetailModel[0].total!,
                pickUpStoreId: shippingModel.orderDetail!.shippingMethod ==
                            "Pick From Store" &&
                        (shippingModel.orderDetail!.storeId ?? "").isNotEmpty
                    ? shippingModel.orderDetail!.storeId ?? ""
                    : "",
                /*pickUpZip:shippingModel.orderDetail!.shippingMethod == "Pick From Store" &&  (shippingModel.orderDetail!.shippingZipcode ?? "").isNotEmpty?shippingModel.orderDetail!.orderStore!.postalCode??"":"",
              selectedPickupStoreList: shippingModel.orderDetail!.shippingMethod == "Pick From Store" &&  (shippingModel.orderDetail!.shippingZipcode ?? "").isNotEmpty?
              SearchStoreList(
                postalCode: shippingModel.orderDetail!.orderStore!.postalCode??"",
                name: shippingModel.orderDetail!.orderStore!.name??"",
                id: shippingModel.orderDetail!.orderStore!.id??"",
                distance: shippingModel.orderDetail!.orderStore!.distance??"",
                dimensionID: shippingModel.orderDetail!.orderStore!.dimensionID??"",
                avaibility: shippingModel.orderDetail!.orderStore!.avaibility??"",
              ):null,
              selectedPickupStore:shippingModel.orderDetail!.shippingMethod == "Pick From Store" &&  (shippingModel.orderDetail!.shippingZipcode ?? "").isNotEmpty?
              SearchStoreListInformation(
                id:shippingModel.orderDetail!.orderStoreInfo!.id??"",
                developerName:shippingModel.orderDetail!.orderStoreInfo!.developerName??"",
                masterLabel:shippingModel.orderDetail!.orderStoreInfo!.masterLabel??"",
                language:shippingModel.orderDetail!.orderStoreInfo!.language??"",
                label:shippingModel.orderDetail!.orderStoreInfo!.label??"",
                qualifiedApiName:shippingModel.orderDetail!.orderStoreInfo!.qualifiedApiName??"",
                corporateC:shippingModel.orderDetail!.orderStoreInfo!.corporateC??"",
                companyC:shippingModel.orderDetail!.orderStoreInfo!.companyC??"",
                regionC:shippingModel.orderDetail!.orderStoreInfo!.regionC??0.0,
                regionDescriptionC:shippingModel.orderDetail!.orderStoreInfo!.regionDescriptionC??"",
                districtC:shippingModel.orderDetail!.orderStoreInfo!.districtC??0.0,
                districtDescriptionC:shippingModel.orderDetail!.orderStoreInfo!.districtDescriptionC??"",
                storeC:shippingModel.orderDetail!.orderStoreInfo!.storeC??"",
                storeDescriptionC:shippingModel.orderDetail!.orderStoreInfo!.storeDescriptionC??"",
                storeNameC:shippingModel.orderDetail!.orderStoreInfo!.storeNameC??"",
                storeAddressC:shippingModel.orderDetail!.orderStoreInfo!.storeAddressC??"",
                storeCityC:shippingModel.orderDetail!.orderStoreInfo!.storeCityC??"",
                stateC:shippingModel.orderDetail!.orderStoreInfo!.stateC??"",
                countryC:shippingModel.orderDetail!.orderStoreInfo!.countryC??"",
                postalCodeC:shippingModel.orderDetail!.orderStoreInfo!.postalCodeC??"",
                latitudeC:shippingModel.orderDetail!.orderStoreInfo!.latitudeC??"",
                longitudeC:shippingModel.orderDetail!.orderStoreInfo!.longitudeC??"",
                faxC:shippingModel.orderDetail!.orderStoreInfo!.faxC??"",
                phoneC:shippingModel.orderDetail!.orderStoreInfo!.phoneC??"",
                lessonsC:shippingModel.orderDetail!.orderStoreInfo!.lessonsC??false,
                activeC:shippingModel.orderDetail!.orderStoreInfo!.activeC??false,
              ):null,*/
                subtotal: orderDetailModel[0].subtotal,
                proCoverage: proCoverage,
                overrideDiscount: overrideDiscount,
                deliveryModels: deliveryModel,
                orderDetailModel: orderDetailModel,
                selectedAddress1: orderDetailModel[0].shippingAddress,
                selectedAddress2: orderDetailModel[0].shippingAddress2,
                selectedAddressCity: orderDetailModel[0].shippingCity,
                selectedAddressState: orderDetailModel[0].shippingState,
                selectedAddressPostalCode: orderDetailModel[0].shippingZipcode,
                addressModel: [
                  ...[
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
                  ...addressesModel.addressList!
                ]));
          } else {
            emit(state.copyWith(
              proceedingOrder: false,
            ));
          }
        } catch (e) {
          emit(state.copyWith(
            proceedingOrder: false,
          ));
        }
      }
    });
    on<FetchShippingMethods>((event, emit) async {
      print("FetchShippingMethods is called => ");
      emit(state.copyWith(
        fetchingAddresses: true,
      ));

      String email = await SharedPreferenceService().getValue(agentEmail);
      String phone = await SharedPreferenceService().getValue(agentPhone);
      String firstName =
          await SharedPreferenceService().getValue(savedAgentFirstName);
      String lastName =
          await SharedPreferenceService().getValue(savedAgentLastName);

      var userId = await SharedPreferenceService().getValue(agentId);
      AddressesModel addressesModel =
          await cartRepository.fetchAddresses(userId);

      List<OrderDetail>? orderDetailModel = [];
      var loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);
      final getCalculateResp = await cartRepository.getTaxCalculate(event.orderId, loggedInUserId);
      TaxCalculateModel shippingModel = TaxCalculateModel.fromJson(getCalculateResp);
      if (shippingModel.orderDetail != null) {
        orderDetailModel.add(shippingModel.orderDetail!);

        double proCoverage = 0.0;
        double overrideDiscount = 0.0;
        if (orderDetailModel.isNotEmpty) {
          for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
            proCoverage = proCoverage +
                (orderDetailModel[0].items![k].warrantyPrice! *
                    orderDetailModel[0].items![k].quantity!);
            overrideDiscount = overrideDiscount +
                (orderDetailModel[0]
                    .items![k]
                    .overridePriceApproval!
                    .toLowerCase()
                    .contains("approved")
                    ? (orderDetailModel[0].items![k].unitPrice! -
                    orderDetailModel[0].items![k].overridePrice!) *
                    orderDetailModel[0].items![k].quantity!
                    : 0.0);
          }
          List<ItemsOfCart> itemsOfCart = [];
          List<Records> records = [];
          for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
            itemsOfCart.add(ItemsOfCart(
                itemQuantity: orderDetailModel[0].items![k].quantity.toString(),
                itemId: orderDetailModel[0].items![k].itemNumber!,
                itemName: orderDetailModel[0].items![k].itemDesc!,
                itemProCoverage:
                (orderDetailModel[0].items![k].warrantyPrice ?? 0.0)
                    .toString(),
                itemPrice: orderDetailModel[0].items![k].unitPrice.toString()));
            records.add(Records(
                productId: orderDetailModel[0].items![k].productId,
                quantity: orderDetailModel[0].items![k].quantity.toString(),
                productName: orderDetailModel[0].items![k].itemDesc,
                oliRecId: orderDetailModel[0].items![k].itemId!,
                productPrice:
                orderDetailModel[0].items![k].unitPrice!.toString(),
                productImageUrl:
                orderDetailModel[0].items![k].imageUrl.toString(),
                childskus: [
                  Childskus(
                    skuENTId: orderDetailModel[0].items![k].itemNumber,
                    skuCondition: orderDetailModel[0].items![k].condition,
                    skuPrice: (orderDetailModel[0].items![k].unitPrice ?? 0)
                        .toString(),
                    skuPIMId: orderDetailModel[0].items![k].pimSkuId,
                    gcItemNumber: orderDetailModel[0].items![k].posSkuId,
                    pimStatus: orderDetailModel[0].items![k].itemStatus,
                  )
                ]));
          }
          event.inventorySearchBloc.add(SetCart(
              itemOfCart: itemsOfCart,
              records: records,
              orderId: event.orderId));
        }

        List<DeliveryModel> deliveryModel = [];

        deliveryModel.add(state.deliveryModels.isNotEmpty
            ? state.deliveryModels.first
            : DeliveryModel(
            type: "Pick-up",
            address: "",
            isSelected: false,
            price: "0",
            time: ""));

        for (ShippingMethod shippingMethodsModel in shippingModel.shippingMethod ?? []) {
          print("shippingMethodsModel.values ${shippingMethodsModel.values}");
          if (shippingModel.orderDetail!.shippingMethod ==
              shippingMethodsModel.values
          // && (email.isNotEmpty || state.shippingEmail.isNotEmpty) &&
          // (phone.isNotEmpty || state.shippingPhone.isNotEmpty) &&
          // (firstName.isNotEmpty || state.shippingFName.isNotEmpty) &&
          // (lastName.isNotEmpty || state.shippingLName.isNotEmpty)
          ) {
            deliveryModel.add(DeliveryModel(
                type: shippingMethodsModel.values,
                address: shippingMethodsModel.label,
                isSelected: true,
                price: "",
                time: ""));
          } else {
            deliveryModel.add(DeliveryModel(
                type: shippingMethodsModel.values,
                address: shippingMethodsModel.label,
                isSelected: false,
                price: "",
                time: ""));
          }
        }

        if (shippingModel.orderDetail!.shippingMethod == "Pick From Store" &&
            (shippingModel.orderDetail!.storeId ?? "").isNotEmpty) {
          deliveryModel[0].isSelected = true;
          deliveryModel[0].name =
              shippingModel.orderDetail!.selectedStoreCity ?? "";
        } else {
          deliveryModel[0].name = "";
          deliveryModel[0].time = "";
          deliveryModel[0].pickupAddress = "";
        }

        print(
            " orderDetailModel[0].shippingZipcode!.toLowerCase().trim() ${orderDetailModel[0].shippingZipcode!.toLowerCase().trim()}");
        print(
            " orderDetailModel[0].shippingState!.toLowerCase().trim() ${orderDetailModel[0].shippingState!.toLowerCase().trim()}");
        print(
            " orderDetailModel[0].shippingAddress!.toLowerCase().trim() ${orderDetailModel[0].shippingAddress!.toLowerCase().trim()}");
        print(
            " orderDetailModel[0].shippingAddress2!.toLowerCase().trim() ${orderDetailModel[0].shippingAddress2!.toLowerCase().trim()}");
        print(
            " orderDetailModel[0].shippingCity!.toLowerCase().trim() ${orderDetailModel[0].shippingCity!.toLowerCase().trim()}");

        int selectedIndex = -1;

        // if((email.isNotEmpty || state.shippingEmail.isNotEmpty) &&
        //     (phone.isNotEmpty || state.shippingPhone.isNotEmpty) &&
        //     (firstName.isNotEmpty || state.shippingFName.isNotEmpty) &&
        //     (lastName.isNotEmpty || state.shippingLName.isNotEmpty)) {
        if (addressesModel.addressList!
            .where((element) =>
        element.postalCode!.toLowerCase().trim() ==
            orderDetailModel[0].shippingZipcode!.toLowerCase().trim() &&
            element.state!.toLowerCase().trim() ==
                orderDetailModel[0]
                    .shippingState!
                    .replaceAll("CA", "California")
                    .replaceAll("NY", "New York")
                    .toLowerCase()
                    .trim() &&
            element.address1!.toLowerCase().trim() ==
                orderDetailModel[0].shippingAddress!.toLowerCase().trim() &&
            element.address2!.toLowerCase().trim() ==
                orderDetailModel[0]
                    .shippingAddress2!
                    .toLowerCase()
                    .trim() &&
            element.city!.toLowerCase().trim() ==
                orderDetailModel[0].shippingCity!.toLowerCase().trim())
            .isEmpty) {
          selectedIndex = 0;
          print("this is selected index0 $selectedIndex");
        }
        else {
          AddressList addressList = addressesModel.addressList!
              .firstWhere(
                  (element) =>
              element.postalCode!.toLowerCase().trim() ==
                  orderDetailModel[0]
                      .shippingZipcode!
                      .toLowerCase()
                      .trim() &&
                  element.state!.toLowerCase().trim() ==
                      orderDetailModel[0]
                          .shippingState!
                          .replaceAll("CA", "California")
                          .replaceAll("NY", "New York")
                          .toLowerCase()
                          .trim() &&
                  element.address1!.toLowerCase().trim() ==
                      orderDetailModel[0]
                          .shippingAddress!
                          .toLowerCase()
                          .trim() &&
                  element.address2!.toLowerCase().trim() ==
                      orderDetailModel[0]
                          .shippingAddress2!
                          .toLowerCase()
                          .trim() &&
                  element.city!.toLowerCase().trim() ==
                      orderDetailModel[0]
                          .shippingCity!
                          .toLowerCase()
                          .trim());
          selectedIndex = addressesModel.addressList!.indexOf(addressList);
          print("this is selected index1 $selectedIndex");
        }
        // }

        if (addressesModel.addressList!.isNotEmpty) {
          addressesModel.addressList![selectedIndex].isSelected = true;
          addressesModel.addressList![selectedIndex].isFacing = true;
        }
        if((shippingModel.shippingMethod??[]).isEmpty){
          final getCalculateResp = await cartRepository.getTaxCalculate(event.orderId, loggedInUserId);
          TaxCalculateModel shippingModel = TaxCalculateModel.fromJson(getCalculateResp);
          orderDetailModel.clear();
          orderDetailModel.add(shippingModel.orderDetail!);
          for (ShippingMethod shippingMethodsModel in shippingModel.shippingMethod ?? []) {
            print("shippingMethodsModel.values 2 ${shippingMethodsModel.values}");
            if (shippingModel.orderDetail!.shippingMethod ==
                shippingMethodsModel.values
            ) {
              deliveryModel.add(DeliveryModel(
                  type: shippingMethodsModel.values,
                  address: shippingMethodsModel.label,
                  isSelected: true,
                  price: "",
                  time: ""));
            } else {
              deliveryModel.add(DeliveryModel(
                  type: shippingMethodsModel.values,
                  address: shippingMethodsModel.label,
                  isSelected: false,
                  price: "",
                  time: ""));
            }
          }
        }
        emit(state.copyWith(
            fetchingAddresses: false,
            pickUpStoreId: shippingModel.orderDetail!.shippingMethod ==
                "Pick From Store" &&
                (shippingModel.orderDetail!.storeId ?? "").isNotEmpty
                ? shippingModel.orderDetail!.storeId ?? ""
                : "",
            /*pickUpZip:shippingModel.orderDetail!.shippingMethod == "Pick From Store" &&  (shippingModel.orderDetail!.shippingZipcode ?? "").isNotEmpty?shippingModel.orderDetail!.orderStore!.postalCode??"":"",

            selectedPickupStore:shippingModel.orderDetail!.shippingMethod == "Pick From Store" &&  (shippingModel.orderDetail!.shippingZipcode ?? "").isNotEmpty?
            SearchStoreListInformation(
                id:shippingModel.orderDetail!.orderStoreInfo!.id??"",
                developerName:shippingModel.orderDetail!.orderStoreInfo!.developerName??"",
                masterLabel:shippingModel.orderDetail!.orderStoreInfo!.masterLabel??"",
                language:shippingModel.orderDetail!.orderStoreInfo!.language??"",
                label:shippingModel.orderDetail!.orderStoreInfo!.label??"",
              qualifiedApiName:shippingModel.orderDetail!.orderStoreInfo!.qualifiedApiName??"",
              corporateC:shippingModel.orderDetail!.orderStoreInfo!.corporateC??"",
              companyC:shippingModel.orderDetail!.orderStoreInfo!.companyC??"",
              regionC:shippingModel.orderDetail!.orderStoreInfo!.regionC??0.0,
              regionDescriptionC:shippingModel.orderDetail!.orderStoreInfo!.regionDescriptionC??"",
              districtC:shippingModel.orderDetail!.orderStoreInfo!.districtC??0.0,
              districtDescriptionC:shippingModel.orderDetail!.orderStoreInfo!.districtDescriptionC??"",
              storeC:shippingModel.orderDetail!.orderStoreInfo!.storeC??"",
              storeDescriptionC:shippingModel.orderDetail!.orderStoreInfo!.storeDescriptionC??"",
              storeNameC:shippingModel.orderDetail!.orderStoreInfo!.storeNameC??"",
              storeAddressC:shippingModel.orderDetail!.orderStoreInfo!.storeAddressC??"",
              storeCityC:shippingModel.orderDetail!.orderStoreInfo!.storeCityC??"",
              stateC:shippingModel.orderDetail!.orderStoreInfo!.stateC??"",
              countryC:shippingModel.orderDetail!.orderStoreInfo!.countryC??"",
              postalCodeC:shippingModel.orderDetail!.orderStoreInfo!.postalCodeC??"",
              latitudeC:shippingModel.orderDetail!.orderStoreInfo!.latitudeC??"",
              longitudeC:shippingModel.orderDetail!.orderStoreInfo!.longitudeC??"",
              faxC:shippingModel.orderDetail!.orderStoreInfo!.faxC??"",
              phoneC:shippingModel.orderDetail!.orderStoreInfo!.phoneC??"",
              lessonsC:shippingModel.orderDetail!.orderStoreInfo!.lessonsC??false,
              activeC:shippingModel.orderDetail!.orderStoreInfo!.activeC??false,
            ):null,
            selectedPickupStoreList: shippingModel.orderDetail!.shippingMethod == "Pick From Store" &&  (shippingModel.orderDetail!.shippingZipcode ?? "").isNotEmpty?
            SearchStoreList(
              postalCode: shippingModel.orderDetail!.orderStore!.postalCode??"",
              name: shippingModel.orderDetail!.orderStore!.name??"",
              id: shippingModel.orderDetail!.orderStore!.id??"",
              distance: shippingModel.orderDetail!.orderStore!.distance??"",
              dimensionID: shippingModel.orderDetail!.orderStore!.dimensionID??"",
              avaibility: shippingModel.orderDetail!.orderStore!.avaibility??"",
            ):null,*/
            selectedAddressIndex: selectedIndex + 1,
            total: orderDetailModel[0].total!,
            subtotal: orderDetailModel[0].subtotal,
            proCoverage: proCoverage,
            overrideDiscount: overrideDiscount,
            deliveryModels: deliveryModel,
            orderDetailModel: orderDetailModel,
            selectedAddress1: state.selectedAddress1.isEmpty
                ? orderDetailModel[0].shippingAddress
                : state.selectedAddress1,
            selectedAddress2: state.selectedAddress2.isEmpty
                ? orderDetailModel[0].shippingAddress2
                : state.selectedAddress2,
            selectedAddressCity: state.selectedAddressCity.isEmpty
                ? orderDetailModel[0].shippingCity
                : state.selectedAddressCity,
            selectedAddressState: state.selectedAddressState.isEmpty
                ? orderDetailModel[0].shippingState
                : state.selectedAddressState,
            selectedAddressPostalCode: state.selectedAddressPostalCode.isEmpty
                ? orderDetailModel[0].shippingZipcode
                : state.selectedAddressPostalCode,
            addressModel: [
              ...[
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
              ...addressesModel.addressList!
            ]));
      }
      // final responseCartNew = await cartRepository.getOrders(event.orderId);
      // CartDetailModel cartDetailModelNew =
      //     CartDetailModel.fromJson(responseCartNew.data);
      else {
        emit(state.copyWith(
          fetchingAddresses: false,
        ));
      }
    });
    on<ChangeAddressIsSelectedWithAddress>((event, emit) async {
      print("ChangeAddressIsSelectedWithAddress is called => ${event.index}");
      List<AddressList> addressModel = state.addressModel;
      if (addressModel.isNotEmpty && !addressModel[event.index].isSelected!) {
        for (AddressList a in addressModel) {
          if (addressModel.indexOf(a) == event.index) {
            a.isSelected = true;
          } else {
            a.isSelected = false;
          }
        }
        emit(state.copyWith(
            addressModel: addressModel,
            selectedAddressIndex: event.index,
            savingAddress: true));

        if (event.index > 0) {
          OrderDetail cartDetailModel = state.orderDetailModel.isNotEmpty
              ? state.orderDetailModel.first
              : OrderDetail();
          SendTaxInfoModel sendTaxInfoModel =
              await cartRepository.sendTaxInfoAddress(
                  orderId: event.orderID,
                  firstName: event.firstName ?? "",
                  lastName: event.lastName ?? "",
                  middleName: cartDetailModel.middleName ?? "",
                  phoneName: event.phone ?? "",
                  shippingAddress: event.addressModel.address1 ?? "",
                  shippingAddress2: event.addressModel.address2 ?? "",
                  shippingCity: event.addressModel.city ?? "",
                  shippingCountry: event.addressModel.country ?? "",
                  shippingState: event.addressModel.state ?? "",
                  shippingEmail: event.email ?? "",
                  shippingMethodName: cartDetailModel.shippingMethod ?? "",
                  shippingZipCode: event.addressModel.postalCode ?? "");
          if (sendTaxInfoModel.isSuccess!) {
            var loggedInUserId =
                await SharedPreferenceService().getValue(loggedInAgentId);
            final getCalculateResp = await cartRepository.getTaxCalculate(
                event.orderID, loggedInUserId);
            TaxCalculateModel shippingModel =
                TaxCalculateModel.fromJson(getCalculateResp);
            // final newResponseJson =
            //     await cartRepository.getOrders(event.orderID);
            if (shippingModel.orderDetail != null) {
              // CartDetailModel newCartDetail =
              //     CartDetailModel.fromJson(newResponseJson.data);
              if (shippingModel.orderDetail != null) {
                double newProCoverage = 0.0;
                double newOverrideDiscount = 0.0;
                for (int k = 0;
                    k < shippingModel.orderDetail!.items!.length;
                    k++) {
                  newProCoverage +=
                      (shippingModel.orderDetail!.items![k].warrantyPrice! *
                          shippingModel.orderDetail!.items![k].quantity!);
                  newOverrideDiscount += (shippingModel
                              .orderDetail!.items![k].overridePriceApproval ==
                          "Approved"
                      ? (shippingModel.orderDetail!.items![k].unitPrice! -
                              shippingModel
                                  .orderDetail!.items![k].overridePrice!) *
                          shippingModel.orderDetail!.items![k].quantity!
                      : 0.0);
                }
                List<OrderDetail>? orderNew = state.orderDetailModel;
                if (orderNew.isNotEmpty) {
                  shippingModel.orderDetail!.items = orderNew.first.items!;
                }
                List<DeliveryModel> deliveryModel = [];
                deliveryModel.add(DeliveryModel(
                    type: "Pick-up",
                    address: "",
                    isSelected: false,
                    price: "0",
                    time: ""));
                for (ShippingMethod shippingMethodsModel
                    in shippingModel.shippingMethod ?? []) {
                  if (shippingModel.orderDetail!.shippingMethod ==
                      shippingMethodsModel.values) {
                    deliveryModel.add(DeliveryModel(
                        type: shippingMethodsModel.values,
                        address: shippingMethodsModel.label,
                        isSelected: true,
                        price: "",
                        time: ""));
                  } else {
                    deliveryModel.add(DeliveryModel(
                        type: shippingMethodsModel.values,
                        address: shippingMethodsModel.label,
                        isSelected: false,
                        price: "",
                        time: ""));
                  }
                }

                emit(state.copyWith(
                    total: shippingModel.orderDetail!.total!,
                    subtotal: shippingModel.orderDetail!.subtotal,
                    deliveryModels: deliveryModel,
                    proCoverage: newProCoverage,
                    selectedAddress1: addressModel.isNotEmpty
                        ? addressModel[event.index].address1
                        : state.selectedAddress1,
                    selectedAddress2: addressModel.isNotEmpty
                        ? addressModel[event.index].address2
                        : state.selectedAddress2,
                    selectedAddressCity: addressModel.isNotEmpty
                        ? addressModel[event.index].city
                        : state.selectedCity,
                    selectedAddressState: addressModel.isNotEmpty
                        ? addressModel[event.index].state
                        : state.selectedState,
                    selectedAddressPostalCode: addressModel.isNotEmpty
                        ? addressModel[event.index].postalCode
                        : state.selectedAddressPostalCode,
                    selectedAddressIndex: event.index,
                    savingAddress: false,
                    overrideDiscount: newOverrideDiscount,
                    orderDetailModel: [shippingModel.orderDetail!]));
              }
            }
          }
        } else {
          emit(state.copyWith(
              selectedAddressIndex: event.index, savingAddress: false));
        }
      }
    });
    on<UpdateDeleteDone>((event, emit) async {
      emit(state.copyWith(
        deleteDone: event.value,
      ));
    });
    on<GetRecommendedAddresses>((event, emit) async {
      List<DeliveryModel> deliveryModels = state.deliveryModels;
      if (deliveryModels.where((element) => element.isSelected!).isNotEmpty &&
          deliveryModels
                  .firstWhere((element) => element.isSelected!)
                  .type!
                  .toLowerCase() !=
              "pick-up") {
        emit(state.copyWith(
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
            updateIndex: event.index));

        await cartRepository.sendTaxInfoShippingMethod(
          orderId: event.orderId,
          shippingMethodName: deliveryModels
                  .firstWhere((element) => element.isSelected!)
                  .type ??
              "",
          shippingMethodPrice: deliveryModels
                      .firstWhere((element) => element.isSelected!)
                      .address!
                      .split("\$")
                      .length >
                  1
              ? deliveryModels
                  .firstWhere((element) => element.isSelected!)
                  .address!
                  .split("\$")[1]
                  .trim()
              : "0",
          email: state.shippingEmail,
          phone: state.shippingPhone,
          firstName: state.shippingFName,
          lastName: state.shippingLName,
        );

        RecommendedAddressModel recommendedAddressModel =
            await cartRepository.getRecommendedAddress(
                event.address1,
                event.address2,
                event.city,
                event.state,
                event.postalCode,
                event.country,
                event.isShipping,
                event.isBilling);
        if (recommendedAddressModel.addressInfo != null) {
          if (recommendedAddressModel.addressInfo!.hasDifference != null &&
              recommendedAddressModel.addressInfo!.recommendedAddress != null &&
              recommendedAddressModel
                      .addressInfo!.recommendedAddress!.isSuccess !=
                  null &&
              recommendedAddressModel
                  .addressInfo!.recommendedAddress!.isSuccess!) {
            if (recommendedAddressModel.addressInfo!.hasDifference!) {
              RecommendedAddress recommendedAddress =
                  recommendedAddressModel.addressInfo!.recommendedAddress!;
              ExistingAddress orderAddress =
                  recommendedAddressModel.addressInfo!.existingAddress!;
              emit(state.copyWith(
                  recommendedAddress:
                      "${recommendedAddress.addressline1!.isNotEmpty ? recommendedAddress.addressline1! : ""}"
                      "${recommendedAddress.addressline1!.isNotEmpty || recommendedAddress.addressline2!.isNotEmpty ? ", " : ""}"
                      "${recommendedAddress.addressline2!.isNotEmpty ? recommendedAddress.addressline2 : ""}"
                      "${recommendedAddress.addressline2!.isNotEmpty || recommendedAddress.city!.isNotEmpty ? ", " : ""}"
                      "${recommendedAddress.city!.isNotEmpty ? recommendedAddress.city! : ""}"
                      "${recommendedAddress.city!.isNotEmpty || recommendedAddress.state!.isNotEmpty ? ", " : ""}"
                      "${recommendedAddress.state!.isNotEmpty ? recommendedAddress.state! : ""}"
                      "${recommendedAddress.state!.isNotEmpty || recommendedAddress.country!.isNotEmpty ? ", " : ""}"
                      "${recommendedAddress.country!.isNotEmpty ? recommendedAddress.country! : ""}"
                      "${recommendedAddress.country!.isNotEmpty || recommendedAddress.postalcode!.isNotEmpty ? ", " : ""}"
                      "${recommendedAddress.postalcode!.isNotEmpty ? recommendedAddress.postalcode! : ""}",
                  orderAddress:
                      "${orderAddress.addressline1!.isNotEmpty ? orderAddress.addressline1! : ""}"
                      "${orderAddress.addressline1!.isNotEmpty || orderAddress.addressline2!.isNotEmpty ? ", " : ""}"
                      "${orderAddress.addressline2!.isNotEmpty ? orderAddress.addressline2 : ""}"
                      "${orderAddress.addressline2!.isNotEmpty || orderAddress.city!.isNotEmpty ? ", " : ""}"
                      "${orderAddress.city!.isNotEmpty ? orderAddress.city! : ""}"
                      "${orderAddress.city!.isNotEmpty || orderAddress.state!.isNotEmpty ? ", " : ""}"
                      "${orderAddress.state!.isNotEmpty ? orderAddress.state! : ""}"
                      "${orderAddress.state!.isNotEmpty || orderAddress.country!.isNotEmpty ? ", " : ""}"
                      "${orderAddress.country!.isNotEmpty ? orderAddress.country! : ""}"
                      "${orderAddress.country!.isNotEmpty || orderAddress.postalcode!.isNotEmpty ? ", " : ""}"
                      "${orderAddress.postalcode!.isNotEmpty ? orderAddress.postalcode! : ""}",
                  proceedingOrder: false,
                  showRecommendedDialog: true,
                  recommendedLabel: event.label ?? "",
                  recommendedAddressLine1: recommendedAddress.addressline1!,
                  recommendedContactPointAddressId: event.contactPointAddressId,
                  recommendedAddressLine2: recommendedAddress.addressline2!,
                  recommendedAddressLineCity: recommendedAddress.city!,
                  recommendedAddressLineCountry: recommendedAddress.country!,
                  recommendedAddressLineState: recommendedAddress.state!,
                  recommendedAddressLineZipCode: recommendedAddress.postalcode!,
                  orderLabel: event.label ?? "",
                  orderContactPointAddressId: event.contactPointAddressId ?? "",
                  orderAddressLine1: event.address1,
                  orderAddressLine2: event.address2,
                  orderAddressLineCity: event.city,
                  orderAddressLineCountry: event.country,
                  orderAddressLineState: event.state,
                  orderAddressLineZipCode: event.postalCode,
                  updateIndex: event.index));
            } else {
              emit(state.copyWith(
                  message: "Recommended address not found",
                  recommendedAddress: "",
                  recommendedLabel: event.label ?? "",
                  recommendedContactPointAddressId:
                      event.contactPointAddressId ?? "",
                  recommendedAddressLine1: event.address1,
                  recommendedAddressLine2: event.address2,
                  recommendedAddressLineCity: event.city,
                  recommendedAddressLineCountry: event.country,
                  recommendedAddressLineState: event.state,
                  recommendedAddressLineZipCode: event.postalCode,
                  proceedingOrder: false,
                  showRecommendedDialog: false,
                  orderAddress: "",
                  updateIndex: event.index));
            }
          } else {
            emit(state.copyWith(
                message: "Recommended address not found",
                recommendedAddress: "",
                recommendedContactPointAddressId:
                    event.contactPointAddressId ?? "",
                recommendedLabel: event.label ?? "",
                recommendedAddressLine1: event.address1,
                recommendedAddressLine2: event.address2,
                recommendedAddressLineCity: event.city,
                recommendedAddressLineCountry: event.country,
                recommendedAddressLineState: event.state,
                proceedingOrder: false,
                recommendedAddressLineZipCode: event.postalCode,
                showRecommendedDialog: true,
                orderAddress: "",
                updateIndex: event.index));
          }
        } else {
          emit(state.copyWith(
              message: "Recommended address not found",
              recommendedAddress: "",
              recommendedContactPointAddressId:
                  event.contactPointAddressId ?? "",
              recommendedLabel: event.label ?? "",
              recommendedAddressLine1: event.address1,
              recommendedAddressLine2: event.address2,
              recommendedAddressLineCity: event.city,
              recommendedAddressLineCountry: event.country,
              recommendedAddressLineState: event.state,
              proceedingOrder: false,
              recommendedAddressLineZipCode: event.postalCode,
              showRecommendedDialog: false,
              orderAddress: "",
              updateIndex: event.index));
        }
      } else if (deliveryModels
              .where((element) => element.isSelected!)
              .isNotEmpty &&
          deliveryModels
                  .firstWhere((element) => element.isSelected!)
                  .type!
                  .toLowerCase() ==
              "pick-up") {
        emit(state.copyWith(proceedingOrder: true));
        await cartRepository.sendTaxInfoDelivery(
          orderId: event.orderId,
          storeNumber: state.orderDetailModel.first.storeId ?? "",
          storeCity: state.orderDetailModel.first.selectedStoreCity ?? "",
          email: state.shippingEmail,
          phone: state.shippingPhone,
          firstName: state.shippingFName,
          lastName: state.shippingLName,
        );
        if (event.index != -10) {
          add(UpdateActiveStep(value: event.index));
        }
      } else if (deliveryModels
          .where((element) => element.isSelected!)
          .isEmpty) {
        emit(state.copyWith(
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
            updateIndex: event.index));

        RecommendedAddressModel recommendedAddressModel =
            await cartRepository.getRecommendedAddress(
                event.address1,
                event.address2,
                event.city,
                event.state,
                event.postalCode,
                event.country,
                event.isShipping,
                event.isBilling);
        if (recommendedAddressModel.addressInfo != null) {
          if (recommendedAddressModel.addressInfo!.hasDifference != null &&
              recommendedAddressModel.addressInfo!.recommendedAddress != null &&
              recommendedAddressModel
                      .addressInfo!.recommendedAddress!.isSuccess !=
                  null &&
              recommendedAddressModel
                  .addressInfo!.recommendedAddress!.isSuccess!) {
            if (recommendedAddressModel.addressInfo!.hasDifference!) {
              RecommendedAddress recommendedAddress =
                  recommendedAddressModel.addressInfo!.recommendedAddress!;
              ExistingAddress orderAddress =
                  recommendedAddressModel.addressInfo!.existingAddress!;
              emit(state.copyWith(
                  recommendedAddress:
                      "${recommendedAddress.addressline1!.isNotEmpty ? recommendedAddress.addressline1! : ""}"
                      "${recommendedAddress.addressline1!.isNotEmpty || recommendedAddress.addressline2!.isNotEmpty ? ", " : ""}"
                      "${recommendedAddress.addressline2!.isNotEmpty ? recommendedAddress.addressline2 : ""}"
                      "${recommendedAddress.addressline2!.isNotEmpty || recommendedAddress.city!.isNotEmpty ? ", " : ""}"
                      "${recommendedAddress.city!.isNotEmpty ? recommendedAddress.city! : ""}"
                      "${recommendedAddress.city!.isNotEmpty || recommendedAddress.state!.isNotEmpty ? ", " : ""}"
                      "${recommendedAddress.state!.isNotEmpty ? recommendedAddress.state! : ""}"
                      "${recommendedAddress.state!.isNotEmpty || recommendedAddress.country!.isNotEmpty ? ", " : ""}"
                      "${recommendedAddress.country!.isNotEmpty ? recommendedAddress.country! : ""}"
                      "${recommendedAddress.country!.isNotEmpty || recommendedAddress.postalcode!.isNotEmpty ? ", " : ""}"
                      "${recommendedAddress.postalcode!.isNotEmpty ? recommendedAddress.postalcode! : ""}",
                  orderAddress:
                      "${orderAddress.addressline1!.isNotEmpty ? orderAddress.addressline1! : ""}"
                      "${orderAddress.addressline1!.isNotEmpty || orderAddress.addressline2!.isNotEmpty ? ", " : ""}"
                      "${orderAddress.addressline2!.isNotEmpty ? orderAddress.addressline2 : ""}"
                      "${orderAddress.addressline2!.isNotEmpty || orderAddress.city!.isNotEmpty ? ", " : ""}"
                      "${orderAddress.city!.isNotEmpty ? orderAddress.city! : ""}"
                      "${orderAddress.city!.isNotEmpty || orderAddress.state!.isNotEmpty ? ", " : ""}"
                      "${orderAddress.state!.isNotEmpty ? orderAddress.state! : ""}"
                      "${orderAddress.state!.isNotEmpty || orderAddress.country!.isNotEmpty ? ", " : ""}"
                      "${orderAddress.country!.isNotEmpty ? orderAddress.country! : ""}"
                      "${orderAddress.country!.isNotEmpty || orderAddress.postalcode!.isNotEmpty ? ", " : ""}"
                      "${orderAddress.postalcode!.isNotEmpty ? orderAddress.postalcode! : ""}",
                  proceedingOrder: false,
                  showRecommendedDialog: true,
                  recommendedLabel: event.label ?? "",
                  recommendedAddressLine1: recommendedAddress.addressline1!,
                  recommendedContactPointAddressId: event.contactPointAddressId,
                  recommendedAddressLine2: recommendedAddress.addressline2!,
                  recommendedAddressLineCity: recommendedAddress.city!,
                  recommendedAddressLineCountry: recommendedAddress.country!,
                  recommendedAddressLineState: recommendedAddress.state!,
                  recommendedAddressLineZipCode: recommendedAddress.postalcode!,
                  orderLabel: event.label ?? "",
                  orderContactPointAddressId: event.contactPointAddressId ?? "",
                  orderAddressLine1: event.address1,
                  orderAddressLine2: event.address2,
                  orderAddressLineCity: event.city,
                  orderAddressLineCountry: event.country,
                  orderAddressLineState: event.state,
                  orderAddressLineZipCode: event.postalCode,
                  updateIndex: event.index));
            } else {
              emit(state.copyWith(
                  message: "Recommended address not found",
                  recommendedAddress: "",
                  recommendedLabel: event.label ?? "",
                  recommendedContactPointAddressId:
                      event.contactPointAddressId ?? "",
                  recommendedAddressLine1: event.address1,
                  recommendedAddressLine2: event.address2,
                  recommendedAddressLineCity: event.city,
                  recommendedAddressLineCountry: event.country,
                  recommendedAddressLineState: event.state,
                  recommendedAddressLineZipCode: event.postalCode,
                  proceedingOrder: false,
                  showRecommendedDialog: false,
                  orderAddress: "",
                  updateIndex: event.index));
            }
          } else {
            emit(state.copyWith(
                message: "Recommended address not found",
                recommendedAddress: "",
                recommendedContactPointAddressId:
                    event.contactPointAddressId ?? "",
                recommendedLabel: event.label ?? "",
                recommendedAddressLine1: event.address1,
                recommendedAddressLine2: event.address2,
                recommendedAddressLineCity: event.city,
                recommendedAddressLineCountry: event.country,
                recommendedAddressLineState: event.state,
                proceedingOrder: false,
                recommendedAddressLineZipCode: event.postalCode,
                showRecommendedDialog: true,
                orderAddress: "",
                updateIndex: event.index));
          }
        } else {
          emit(state.copyWith(
              message: "Recommended address not found",
              recommendedAddress: "",
              recommendedContactPointAddressId:
                  event.contactPointAddressId ?? "",
              recommendedLabel: event.label ?? "",
              recommendedAddressLine1: event.address1,
              recommendedAddressLine2: event.address2,
              recommendedAddressLineCity: event.city,
              recommendedAddressLineCountry: event.country,
              recommendedAddressLineState: event.state,
              proceedingOrder: false,
              recommendedAddressLineZipCode: event.postalCode,
              showRecommendedDialog: false,
              orderAddress: "",
              updateIndex: event.index));
        }
      } else if (deliveryModels
              .where((element) => element.isSelected!)
              .isNotEmpty &&
          deliveryModels
                  .firstWhere((element) => element.isSelected!)
                  .type!
                  .toLowerCase() ==
              "pick-up") {
        emit(state.copyWith(proceedingOrder: true));
        await cartRepository.sendTaxInfoDelivery(
          orderId: event.orderId,
          storeNumber: state.orderDetailModel.first.storeId ?? "",
          storeCity: state.orderDetailModel.first.selectedStoreCity ?? "",
          email: state.shippingEmail,
          phone: state.shippingPhone,
          firstName: state.shippingFName,
          lastName: state.shippingLName,
        );
        if (event.index != -10) {
          add(UpdateActiveStep(value: event.index));
        }
      } else if (deliveryModels
          .where((element) => element.isSelected!)
          .isEmpty) {
        emit(state.copyWith(
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
            updateIndex: event.index));

        RecommendedAddressModel recommendedAddressModel =
            await cartRepository.getRecommendedAddress(
                event.address1,
                event.address2,
                event.city,
                event.state,
                event.postalCode,
                event.country,
                event.isShipping,
                event.isBilling);
        if (recommendedAddressModel.addressInfo != null) {
          if (recommendedAddressModel.addressInfo!.hasDifference != null &&
              recommendedAddressModel.addressInfo!.recommendedAddress != null &&
              recommendedAddressModel
                      .addressInfo!.recommendedAddress!.isSuccess !=
                  null &&
              recommendedAddressModel
                  .addressInfo!.recommendedAddress!.isSuccess!) {
            if (recommendedAddressModel.addressInfo!.hasDifference!) {
              RecommendedAddress recommendedAddress =
                  recommendedAddressModel.addressInfo!.recommendedAddress!;
              ExistingAddress orderAddress =
                  recommendedAddressModel.addressInfo!.existingAddress!;
              emit(state.copyWith(
                  recommendedAddress:
                      "${recommendedAddress.addressline1!.isNotEmpty ? recommendedAddress.addressline1! : ""}"
                      "${recommendedAddress.addressline1!.isNotEmpty || recommendedAddress.addressline2!.isNotEmpty ? ", " : ""}"
                      "${recommendedAddress.addressline2!.isNotEmpty ? recommendedAddress.addressline2 : ""}"
                      "${recommendedAddress.addressline2!.isNotEmpty || recommendedAddress.city!.isNotEmpty ? ", " : ""}"
                      "${recommendedAddress.city!.isNotEmpty ? recommendedAddress.city! : ""}"
                      "${recommendedAddress.city!.isNotEmpty || recommendedAddress.state!.isNotEmpty ? ", " : ""}"
                      "${recommendedAddress.state!.isNotEmpty ? recommendedAddress.state! : ""}"
                      "${recommendedAddress.state!.isNotEmpty || recommendedAddress.country!.isNotEmpty ? ", " : ""}"
                      "${recommendedAddress.country!.isNotEmpty ? recommendedAddress.country! : ""}"
                      "${recommendedAddress.country!.isNotEmpty || recommendedAddress.postalcode!.isNotEmpty ? ", " : ""}"
                      "${recommendedAddress.postalcode!.isNotEmpty ? recommendedAddress.postalcode! : ""}",
                  orderAddress:
                      "${orderAddress.addressline1!.isNotEmpty ? orderAddress.addressline1! : ""}"
                      "${orderAddress.addressline1!.isNotEmpty || orderAddress.addressline2!.isNotEmpty ? ", " : ""}"
                      "${orderAddress.addressline2!.isNotEmpty ? orderAddress.addressline2 : ""}"
                      "${orderAddress.addressline2!.isNotEmpty || orderAddress.city!.isNotEmpty ? ", " : ""}"
                      "${orderAddress.city!.isNotEmpty ? orderAddress.city! : ""}"
                      "${orderAddress.city!.isNotEmpty || orderAddress.state!.isNotEmpty ? ", " : ""}"
                      "${orderAddress.state!.isNotEmpty ? orderAddress.state! : ""}"
                      "${orderAddress.state!.isNotEmpty || orderAddress.country!.isNotEmpty ? ", " : ""}"
                      "${orderAddress.country!.isNotEmpty ? orderAddress.country! : ""}"
                      "${orderAddress.country!.isNotEmpty || orderAddress.postalcode!.isNotEmpty ? ", " : ""}"
                      "${orderAddress.postalcode!.isNotEmpty ? orderAddress.postalcode! : ""}",
                  proceedingOrder: false,
                  showRecommendedDialog: true,
                  recommendedLabel: event.label ?? "",
                  recommendedAddressLine1: recommendedAddress.addressline1!,
                  recommendedContactPointAddressId: event.contactPointAddressId,
                  recommendedAddressLine2: recommendedAddress.addressline2!,
                  recommendedAddressLineCity: recommendedAddress.city!,
                  recommendedAddressLineCountry: recommendedAddress.country!,
                  recommendedAddressLineState: recommendedAddress.state!,
                  recommendedAddressLineZipCode: recommendedAddress.postalcode!,
                  orderLabel: event.label ?? "",
                  orderContactPointAddressId: event.contactPointAddressId ?? "",
                  orderAddressLine1: event.address1,
                  orderAddressLine2: event.address2,
                  orderAddressLineCity: event.city,
                  orderAddressLineCountry: event.country,
                  orderAddressLineState: event.state,
                  orderAddressLineZipCode: event.postalCode,
                  updateIndex: event.index));
            } else {
              emit(state.copyWith(
                  message: "Recommended address not found",
                  recommendedAddress: "",
                  recommendedLabel: event.label ?? "",
                  recommendedContactPointAddressId:
                      event.contactPointAddressId ?? "",
                  recommendedAddressLine1: event.address1,
                  recommendedAddressLine2: event.address2,
                  recommendedAddressLineCity: event.city,
                  recommendedAddressLineCountry: event.country,
                  recommendedAddressLineState: event.state,
                  recommendedAddressLineZipCode: event.postalCode,
                  proceedingOrder: false,
                  showRecommendedDialog: false,
                  orderAddress: "",
                  updateIndex: event.index));
            }
          } else {
            emit(state.copyWith(
                message: "Recommended address not found",
                recommendedAddress: "",
                recommendedContactPointAddressId:
                    event.contactPointAddressId ?? "",
                recommendedLabel: event.label ?? "",
                recommendedAddressLine1: event.address1,
                recommendedAddressLine2: event.address2,
                recommendedAddressLineCity: event.city,
                recommendedAddressLineCountry: event.country,
                recommendedAddressLineState: event.state,
                proceedingOrder: false,
                recommendedAddressLineZipCode: event.postalCode,
                showRecommendedDialog: true,
                orderAddress: "",
                updateIndex: event.index));
          }
        } else {
          emit(state.copyWith(
              message: "Recommended address not found",
              recommendedAddress: "",
              recommendedContactPointAddressId:
                  event.contactPointAddressId ?? "",
              recommendedLabel: event.label ?? "",
              recommendedAddressLine1: event.address1,
              recommendedAddressLine2: event.address2,
              recommendedAddressLineCity: event.city,
              recommendedAddressLineCountry: event.country,
              recommendedAddressLineState: event.state,
              proceedingOrder: false,
              recommendedAddressLineZipCode: event.postalCode,
              showRecommendedDialog: false,
              orderAddress: "",
              updateIndex: event.index));
        }
      }
    });
    on<ClearRecommendedAddresses>((event, emit) async {
      emit(state.copyWith(
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
          updateIndex: 0));
    });
    on<HideRecommendedDialog>((event, emit) async {
      emit(state.copyWith(
        showRecommendedDialog: false,
      ));
    });
    on<SetSelectedAddress>((event, emit) async {
      emit(state.copyWith(
          selectedAddress1: event.address1,
          selectedAddress2: event.address2,
          selectedAddressCity: event.city,
          selectedAddressState: event.state,
          selectedAddressPostalCode: event.postalCode));
    });
    on<DeleteOrder>((event, emit) async {
      emit(state.copyWith(
        deleteDone: false,
        loadingScreen: true,
      ));
      log("event.reason ${event.reason}");
      DeleteOrderModel deleteOrderModel =
          await cartRepository.deleteOrder(event.orderId, event.reason);
      if (deleteOrderModel.order!.id != null &&
          deleteOrderModel.order!.id != "-1") {
        event.inventorySearchBloc
            .add(SetCart(itemOfCart: [], records: [], orderId: ""));
        emit(state.copyWith(
            deleteDone: true,
            loadingScreen: false,
            message: "Order Deleted Successfully"));
        event.onSuccess.call();
      } else {
        emit(state.copyWith(
            deleteDone: false,
            loadingScreen: false,
            message: "Failed to delete order"));
      }
    });
    on<AddToCart>((event, emit) async {
      var loggedInId =
          await SharedPreferenceService().getValue(loggedInAgentId);
      Items e = event.records;
      //if (event.customerID.isNotEmpty) {
      emit(state.copyWith(message: "", isUpdating: true, updateID: e.itemId));
      try {
        if (event.quantity == -1) {
          final responseJson = await cartRepository.updateCartAdd(
              event.records,
              event.customerID,
              event.orderID,
              int.parse(e.quantity!.toInt().toString()) + 1);
          UpdateCart updateCart = UpdateCart.fromJson(responseJson.data ?? {});
          e.quantity = (int.parse(e.quantity!.toInt().toString()) + 1);
          if (updateCart.message!.isNotEmpty) {
            List<OrderDetail>? orderDetailModel = [];

            var loggedInUserId =
                await SharedPreferenceService().getValue(loggedInAgentId);
            final getCalculateResp = await cartRepository.getTaxCalculate(
                event.orderID, loggedInUserId);
            TaxCalculateModel shippingModel =
                TaxCalculateModel.fromJson(getCalculateResp);
            // final responseCartNew =
            //     await cartRepository.getOrders(event.orderID);
            // CartDetailModel cartDetailModelNew =
            //     CartDetailModel.fromJson(responseCartNew.data);
            orderDetailModel.add(shippingModel.orderDetail!);

            double proCoverage = 0.0;
            double overrideDiscount = 0.0;
            if (orderDetailModel.isNotEmpty) {
              for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
                proCoverage = proCoverage +
                    (orderDetailModel[0].items![k].warrantyPrice! *
                        orderDetailModel[0].items![k].quantity!);
                overrideDiscount = overrideDiscount +
                    (orderDetailModel[0]
                            .items![k]
                            .overridePriceApproval!
                            .toLowerCase()
                            .contains("approved")
                        ? (orderDetailModel[0].items![k].unitPrice! -
                                orderDetailModel[0].items![k].overridePrice!) *
                            orderDetailModel[0].items![k].quantity!
                        : 0.0);
              }

              List<ItemsOfCart> itemsOfCart = [];
              List<Records> records = [];
              for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
                itemsOfCart.add(ItemsOfCart(
                    itemQuantity:
                        orderDetailModel[0].items![k].quantity.toString(),
                    itemId: orderDetailModel[0].items![k].itemNumber!,
                    itemName: orderDetailModel[0].items![k].itemDesc!,
                    itemProCoverage:
                        (orderDetailModel[0].items![k].warrantyPrice ?? 0.0)
                            .toString(),
                    itemPrice:
                        orderDetailModel[0].items![k].unitPrice.toString()));
                records.add(Records(
                    productId: orderDetailModel[0].items![k].productId,
                    quantity: orderDetailModel[0].items![k].quantity.toString(),
                    productName: orderDetailModel[0].items![k].itemDesc,
                    oliRecId: orderDetailModel[0].items![k].itemId!,
                    productPrice:
                        orderDetailModel[0].items![k].unitPrice!.toString(),
                    productImageUrl:
                        orderDetailModel[0].items![k].imageUrl.toString(),
                    childskus: [
                      Childskus(
                        skuENTId: orderDetailModel[0].items![k].itemNumber,
                        skuCondition: orderDetailModel[0].items![k].condition,
                        skuPrice: (orderDetailModel[0].items![k].unitPrice ?? 0)
                            .toString(),
                        skuPIMId: orderDetailModel[0].items![k].pimSkuId,
                        gcItemNumber: orderDetailModel[0].items![k].posSkuId,
                        pimStatus: orderDetailModel[0].items![k].itemStatus,
                      )
                    ]));
              }
              event.inventorySearchBloc.add(SetCart(
                  itemOfCart: itemsOfCart,
                  records: records,
                  orderId: event.orderID));
            }

            List<DeliveryModel> deliveryModel = [];

            deliveryModel.add(state.deliveryModels.isNotEmpty
                ? state.deliveryModels.first
                : DeliveryModel(
                    type: "Pick-up",
                    address: "",
                    isSelected: false,
                    price: "0",
                    time: ""));
            for (ShippingMethod shippingMethodsModel
                in shippingModel.shippingMethod ?? []) {
              if (shippingModel.orderDetail!.shippingMethod ==
                  shippingMethodsModel.values) {
                deliveryModel.add(DeliveryModel(
                    type: shippingMethodsModel.values,
                    address: shippingMethodsModel.label,
                    isSelected: true,
                    price: "",
                    time: ""));
              } else {
                deliveryModel.add(DeliveryModel(
                    type: shippingMethodsModel.values,
                    address: shippingMethodsModel.label,
                    isSelected: false,
                    price: "",
                    time: ""));
              }
            }

            emit(state.copyWith(
              message: updateCart.message ?? "",
              total: orderDetailModel[0].total!,
              subtotal: orderDetailModel[0].subtotal,
              proCoverage: proCoverage,
              overrideDiscount: overrideDiscount,
              deliveryModels: deliveryModel,
              orderDetailModel: orderDetailModel,
              isUpdating: false,
              updateID: "",
            ));
          } else {
            emit(state.copyWith(
              isUpdating: false,
              updateID: "",
              message: "Cannot update cart. Check your network connection!",
            ));
          }
        } else {
          final responseJson = await cartRepository.updateCartAdd(
              event.records,
              event.customerID,
              event.orderID,
              int.parse(event.quantity.toString()));
          UpdateCart updateCart = UpdateCart.fromJson(responseJson.data);
          e.quantity = event.quantity.toDouble();
          if (updateCart.message!.isNotEmpty) {
            List<OrderDetail>? orderDetailModel = [];

            var loggedInUserId =
                await SharedPreferenceService().getValue(loggedInAgentId);
            final getCalculateResp = await cartRepository.getTaxCalculate(
                event.orderID, loggedInUserId);
            TaxCalculateModel shippingModel =
                TaxCalculateModel.fromJson(getCalculateResp);
            // final responseCartNew =
            //     await cartRepository.getOrders(event.orderID);
            // CartDetailModel cartDetailModelNew =
            //     CartDetailModel.fromJson(responseCartNew.data);
            orderDetailModel.add(shippingModel.orderDetail!);

            double proCoverage = 0.0;
            double overrideDiscount = 0.0;
            if (orderDetailModel.isNotEmpty) {
              for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
                proCoverage = proCoverage +
                    (orderDetailModel[0].items![k].warrantyPrice! *
                        orderDetailModel[0].items![k].quantity!);
                overrideDiscount = overrideDiscount +
                    (orderDetailModel[0]
                            .items![k]
                            .overridePriceApproval!
                            .toLowerCase()
                            .contains("approved")
                        ? (orderDetailModel[0].items![k].unitPrice! -
                                orderDetailModel[0].items![k].overridePrice!) *
                            orderDetailModel[0].items![k].quantity!
                        : 0.0);
              }
              List<ItemsOfCart> itemsOfCart = [];
              List<Records> records = [];
              for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
                itemsOfCart.add(ItemsOfCart(
                    itemQuantity:
                        orderDetailModel[0].items![k].quantity.toString(),
                    itemId: orderDetailModel[0].items![k].itemNumber!,
                    itemName: orderDetailModel[0].items![k].itemDesc!,
                    itemProCoverage:
                        (orderDetailModel[0].items![k].warrantyPrice ?? 0.0)
                            .toString(),
                    itemPrice:
                        orderDetailModel[0].items![k].unitPrice.toString()));
                records.add(Records(
                    productId: orderDetailModel[0].items![k].productId,
                    quantity: orderDetailModel[0].items![k].quantity.toString(),
                    productName: orderDetailModel[0].items![k].itemDesc,
                    oliRecId: orderDetailModel[0].items![k].itemId!,
                    productPrice:
                        orderDetailModel[0].items![k].unitPrice!.toString(),
                    productImageUrl:
                        orderDetailModel[0].items![k].imageUrl.toString(),
                    childskus: [
                      Childskus(
                        skuENTId: orderDetailModel[0].items![k].itemNumber,
                        skuCondition: orderDetailModel[0].items![k].condition,
                        skuPrice: (orderDetailModel[0].items![k].unitPrice ?? 0)
                            .toString(),
                        skuPIMId: orderDetailModel[0].items![k].pimSkuId,
                        gcItemNumber: orderDetailModel[0].items![k].posSkuId,
                        pimStatus: orderDetailModel[0].items![k].itemStatus,
                      )
                    ]));
              }
              event.inventorySearchBloc.add(SetCart(
                  itemOfCart: itemsOfCart,
                  records: records,
                  orderId: event.orderID));
            }

            List<DeliveryModel> deliveryModel = [];

            deliveryModel.add(state.deliveryModels.isNotEmpty
                ? state.deliveryModels.first
                : DeliveryModel(
                    type: "Pick-up",
                    address: "",
                    isSelected: false,
                    price: "0",
                    time: ""));
            for (ShippingMethod shippingMethodsModel
                in shippingModel.shippingMethod ?? []) {
              if (shippingModel.orderDetail!.shippingMethod ==
                  shippingMethodsModel.values) {
                deliveryModel.add(DeliveryModel(
                    type: shippingMethodsModel.values,
                    address: shippingMethodsModel.label,
                    isSelected: true,
                    price: "",
                    time: ""));
              } else {
                deliveryModel.add(DeliveryModel(
                    type: shippingMethodsModel.values,
                    address: shippingMethodsModel.label,
                    isSelected: false,
                    price: "",
                    time: ""));
              }
            }

            emit(state.copyWith(
              message: updateCart.message ?? "",
              total: orderDetailModel[0].total!,
              subtotal: orderDetailModel[0].subtotal,
              proCoverage: proCoverage,
              overrideDiscount: overrideDiscount,
              deliveryModels: deliveryModel,
              orderDetailModel: orderDetailModel,
              isUpdating: false,
              updateID: "",
            ));
          } else {
            emit(state.copyWith(
              isUpdating: false,
              updateID: "",
              message: "Cannot update cart. Check your network connection!",
            ));
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
        emit(state.copyWith(
          isUpdating: false,
          updateID: "",
          message: "Cannot update cart. Check your network connection!",
        ));
      }
      //  }
    });
    on<RemoveFromCart>((event, emit) async {
      Items e = event.records;
      var loggedInId =
          await SharedPreferenceService().getValue(loggedInAgentId);

//      if (event.customerID.isNotEmpty) {
      emit(state.copyWith(
        isUpdating: true,
        updateID: e.itemId,
        message: "",
      ));
      if (event.quantity == -1) {
        if (int.parse(e.quantity!.toInt().toString()) > 0) {
          if (int.parse(e.quantity!.toInt().toString()) > 1) {
            final responseJson = await cartRepository.updateCartAdd(
                event.records,
                event.customerID,
                event.orderID,
                int.parse(e.quantity!.toInt().toString()) - 1);
            UpdateCart updateCart = UpdateCart.fromJson(responseJson.data);
            e.quantity = (int.parse(e.quantity!.toInt().toString()) - 1);
            if (updateCart.message != null && updateCart.message!.isNotEmpty) {
              List<OrderDetail>? orderDetailModel = [];

              var loggedInUserId =
                  await SharedPreferenceService().getValue(loggedInAgentId);
              final getCalculateResp = await cartRepository.getTaxCalculate(
                  event.orderID, loggedInUserId);
              TaxCalculateModel shippingModel =
                  TaxCalculateModel.fromJson(getCalculateResp);
              // final responseCartNew =
              //     await cartRepository.getOrders(event.orderID);
              // CartDetailModel cartDetailModelNew =
              //     CartDetailModel.fromJson(responseCartNew.data);
              if (shippingModel.orderDetail != null) {
                orderDetailModel.add(shippingModel.orderDetail!);
              }
              double proCoverage = 0.0;
              double overrideDiscount = 0.0;
              if (orderDetailModel.isNotEmpty) {
                for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
                  proCoverage = proCoverage +
                      (orderDetailModel[0].items![k].warrantyPrice! *
                          orderDetailModel[0].items![k].quantity!);
                  overrideDiscount = overrideDiscount +
                      (orderDetailModel[0]
                              .items![k]
                              .overridePriceApproval!
                              .toLowerCase()
                              .contains("approved")
                          ? (orderDetailModel[0].items![k].unitPrice! -
                                  orderDetailModel[0]
                                      .items![k]
                                      .overridePrice!) *
                              orderDetailModel[0].items![k].quantity!
                          : 0.0);
                }

                List<ItemsOfCart> itemsOfCart = [];
                List<Records> records = [];
                for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
                  itemsOfCart.add(ItemsOfCart(
                      itemQuantity:
                          orderDetailModel[0].items![k].quantity.toString(),
                      itemId: orderDetailModel[0].items![k].itemNumber!,
                      itemName: orderDetailModel[0].items![k].itemDesc!,
                      itemProCoverage:
                          (orderDetailModel[0].items![k].warrantyPrice ?? 0.0)
                              .toString(),
                      itemPrice:
                          orderDetailModel[0].items![k].unitPrice.toString()));
                  records.add(Records(
                      productId: orderDetailModel[0].items![k].productId,
                      quantity:
                          orderDetailModel[0].items![k].quantity.toString(),
                      productName: orderDetailModel[0].items![k].itemDesc,
                      oliRecId: orderDetailModel[0].items![k].itemId!,
                      productPrice:
                          orderDetailModel[0].items![k].unitPrice!.toString(),
                      productImageUrl:
                          orderDetailModel[0].items![k].imageUrl.toString(),
                      childskus: [
                        Childskus(
                          skuENTId: orderDetailModel[0].items![k].itemNumber,
                          skuCondition: orderDetailModel[0].items![k].condition,
                          skuPrice:
                              (orderDetailModel[0].items![k].unitPrice ?? 0)
                                  .toString(),
                          skuPIMId: orderDetailModel[0].items![k].pimSkuId,
                          gcItemNumber: orderDetailModel[0].items![k].posSkuId,
                          pimStatus: orderDetailModel[0].items![k].itemStatus,
                        )
                      ]));
                }
                event.inventorySearchBloc.add(SetCart(
                    itemOfCart: itemsOfCart,
                    records: records,
                    orderId: event.orderID));
              }

              List<DeliveryModel> deliveryModel = [];

              deliveryModel.add(state.deliveryModels.isNotEmpty
                  ? state.deliveryModels.first
                  : DeliveryModel(
                      type: "Pick-up",
                      address: "",
                      isSelected: false,
                      price: "0",
                      time: ""));
              for (ShippingMethod shippingMethodsModel
                  in shippingModel.shippingMethod ?? []) {
                if (shippingModel.orderDetail!.shippingMethod ==
                    shippingMethodsModel.values) {
                  deliveryModel.add(DeliveryModel(
                      type: shippingMethodsModel.values,
                      address: shippingMethodsModel.label,
                      isSelected: true,
                      price: "",
                      time: ""));
                } else {
                  deliveryModel.add(DeliveryModel(
                      type: shippingMethodsModel.values,
                      address: shippingMethodsModel.label,
                      isSelected: false,
                      price: "",
                      time: ""));
                }
              }

              emit(state.copyWith(
                message: updateCart.message ?? "",
                total: orderDetailModel[0].total!,
                subtotal: orderDetailModel[0].subtotal,
                proCoverage: proCoverage,
                overrideDiscount: overrideDiscount,
                deliveryModels: deliveryModel,
                orderDetailModel: orderDetailModel,
                isUpdating: false,
                updateID: "",
              ));
            } else {
              emit(state.copyWith(
                message: "Cannot update cart. Check your network connection!",
              ));
            }
          } else {
            final responseJson = await cartRepository.updateCartDelete(
                event.records, event.customerID, event.orderID);
            UpdateCart updateCart = UpdateCart.fromJson(responseJson.data);
            e.quantity = (int.parse(e.quantity!.toInt().toString()) - 1);
            List<OrderDetail>? orderDetailModel = [];

            var loggedInUserId =
                await SharedPreferenceService().getValue(loggedInAgentId);
            final getCalculateResp = await cartRepository.getTaxCalculate(
                event.orderID, loggedInUserId);
            TaxCalculateModel shippingModel =
                TaxCalculateModel.fromJson(getCalculateResp);
            // final responseCartNew =
            //     await cartRepository.getOrders(event.orderID);
            // CartDetailModel cartDetailModelNew =
            //     CartDetailModel.fromJson(responseCartNew.data);
            orderDetailModel.add(shippingModel.orderDetail!);

            double proCoverage = 0.0;
            double overrideDiscount = 0.0;
            if (orderDetailModel.isNotEmpty) {
              for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
                proCoverage = proCoverage +
                    (orderDetailModel[0].items![k].warrantyPrice! *
                        orderDetailModel[0].items![k].quantity!);
                overrideDiscount = overrideDiscount +
                    (orderDetailModel[0]
                            .items![k]
                            .overridePriceApproval!
                            .toLowerCase()
                            .contains("approved")
                        ? (orderDetailModel[0].items![k].unitPrice! -
                                orderDetailModel[0].items![k].overridePrice!) *
                            orderDetailModel[0].items![k].quantity!
                        : 0.0);
              }

              List<ItemsOfCart> itemsOfCart = [];
              List<Records> records = [];
              for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
                itemsOfCart.add(ItemsOfCart(
                    itemQuantity:
                        orderDetailModel[0].items![k].quantity.toString(),
                    itemId: orderDetailModel[0].items![k].itemNumber!,
                    itemName: orderDetailModel[0].items![k].itemDesc!,
                    itemProCoverage:
                        (orderDetailModel[0].items![k].warrantyPrice ?? 0.0)
                            .toString(),
                    itemPrice:
                        orderDetailModel[0].items![k].unitPrice.toString()));
                records.add(Records(
                    productId: orderDetailModel[0].items![k].productId,
                    quantity: orderDetailModel[0].items![k].quantity.toString(),
                    productName: orderDetailModel[0].items![k].itemDesc,
                    oliRecId: orderDetailModel[0].items![k].itemId!,
                    productPrice:
                        orderDetailModel[0].items![k].unitPrice!.toString(),
                    productImageUrl:
                        orderDetailModel[0].items![k].imageUrl.toString(),
                    childskus: [
                      Childskus(
                        skuENTId: orderDetailModel[0].items![k].itemNumber,
                        skuCondition: orderDetailModel[0].items![k].condition,
                        skuPrice: (orderDetailModel[0].items![k].unitPrice ?? 0)
                            .toString(),
                        skuPIMId: orderDetailModel[0].items![k].pimSkuId,
                        gcItemNumber: orderDetailModel[0].items![k].posSkuId,
                        pimStatus: orderDetailModel[0].items![k].itemStatus,
                      )
                    ]));
              }
              event.inventorySearchBloc.add(SetCart(
                  itemOfCart: itemsOfCart,
                  records: records,
                  orderId: event.orderID));
            }

            List<DeliveryModel> deliveryModel = [];

            deliveryModel.add(state.deliveryModels.isNotEmpty
                ? state.deliveryModels.first
                : DeliveryModel(
                    type: "Pick-up",
                    address: "",
                    isSelected: false,
                    price: "0",
                    time: ""));
            for (ShippingMethod shippingMethodsModel
                in shippingModel.shippingMethod ?? []) {
              if (shippingModel.orderDetail!.shippingMethod ==
                  shippingMethodsModel.values) {
                deliveryModel.add(DeliveryModel(
                    type: shippingMethodsModel.values,
                    address: shippingMethodsModel.label,
                    isSelected: true,
                    price: "",
                    time: ""));
              } else {
                deliveryModel.add(DeliveryModel(
                    type: shippingMethodsModel.values,
                    address: shippingMethodsModel.label,
                    isSelected: false,
                    price: "",
                    time: ""));
              }
            }

            emit(state.copyWith(
                message: updateCart.message ?? "",
                total: orderDetailModel[0].total!,
                subtotal: orderDetailModel[0].subtotal,
                proCoverage: proCoverage,
                overrideDiscount: overrideDiscount,
                deliveryModels: deliveryModel,
                orderDetailModel: orderDetailModel,
                isUpdating: false,
                updateID: ""));
          }
        }
      } else {
        if (int.parse(e.quantity!.toInt().toString()) > 0) {
          if (int.parse(e.quantity!.toInt().toString()) > 1) {
            final responseJson = await cartRepository.updateCartAdd(
                event.records,
                event.customerID,
                event.orderID,
                event.quantity.toInt());
            UpdateCart updateCart = UpdateCart.fromJson(responseJson.data);
            e.quantity = event.quantity.toDouble();
            if (updateCart.message!.isNotEmpty) {
              List<OrderDetail>? orderDetailModel = [];

              var loggedInUserId =
                  await SharedPreferenceService().getValue(loggedInAgentId);
              final getCalculateResp = await cartRepository.getTaxCalculate(
                  event.orderID, loggedInUserId);
              TaxCalculateModel shippingModel =
                  TaxCalculateModel.fromJson(getCalculateResp);
              // final responseCartNew =
              //     await cartRepository.getOrders(event.orderID);
              // CartDetailModel cartDetailModelNew =
              //     CartDetailModel.fromJson(responseCartNew.data);
              orderDetailModel.add(shippingModel.orderDetail!);

              double proCoverage = 0.0;
              double overrideDiscount = 0.0;
              if (orderDetailModel.isNotEmpty) {
                for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
                  proCoverage = proCoverage +
                      (orderDetailModel[0].items![k].warrantyPrice! *
                          orderDetailModel[0].items![k].quantity!);
                  overrideDiscount = overrideDiscount +
                      (orderDetailModel[0]
                              .items![k]
                              .overridePriceApproval!
                              .toLowerCase()
                              .contains("approved")
                          ? (orderDetailModel[0].items![k].unitPrice! -
                                  orderDetailModel[0]
                                      .items![k]
                                      .overridePrice!) *
                              orderDetailModel[0].items![k].quantity!
                          : 0.0);
                }

                List<ItemsOfCart> itemsOfCart = [];
                List<Records> records = [];
                for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
                  itemsOfCart.add(ItemsOfCart(
                      itemQuantity:
                          orderDetailModel[0].items![k].quantity.toString(),
                      itemId: orderDetailModel[0].items![k].itemNumber!,
                      itemName: orderDetailModel[0].items![k].itemDesc!,
                      itemProCoverage:
                          (orderDetailModel[0].items![k].warrantyPrice ?? 0.0)
                              .toString(),
                      itemPrice:
                          orderDetailModel[0].items![k].unitPrice.toString()));
                  records.add(Records(
                      productId: orderDetailModel[0].items![k].productId,
                      quantity:
                          orderDetailModel[0].items![k].quantity.toString(),
                      productName: orderDetailModel[0].items![k].itemDesc,
                      oliRecId: orderDetailModel[0].items![k].itemId!,
                      productPrice:
                          orderDetailModel[0].items![k].unitPrice!.toString(),
                      productImageUrl:
                          orderDetailModel[0].items![k].imageUrl.toString(),
                      childskus: [
                        Childskus(
                          skuENTId: orderDetailModel[0].items![k].itemNumber,
                          skuCondition: orderDetailModel[0].items![k].condition,
                          skuPrice:
                              (orderDetailModel[0].items![k].unitPrice ?? 0)
                                  .toString(),
                          skuPIMId: orderDetailModel[0].items![k].pimSkuId,
                          gcItemNumber: orderDetailModel[0].items![k].posSkuId,
                          pimStatus: orderDetailModel[0].items![k].itemStatus,
                        )
                      ]));
                }
                event.inventorySearchBloc.add(SetCart(
                    itemOfCart: itemsOfCart,
                    records: records,
                    orderId: event.orderID));
              }

              List<DeliveryModel> deliveryModel = [];

              deliveryModel.add(state.deliveryModels.isNotEmpty
                  ? state.deliveryModels.first
                  : DeliveryModel(
                      type: "Pick-up",
                      address: "",
                      isSelected: false,
                      price: "0",
                      time: ""));
              for (ShippingMethod shippingMethodsModel
                  in shippingModel.shippingMethod ?? []) {
                if (shippingModel.orderDetail!.shippingMethod ==
                    shippingMethodsModel.values) {
                  deliveryModel.add(DeliveryModel(
                      type: shippingMethodsModel.values,
                      address: shippingMethodsModel.label,
                      isSelected: true,
                      price: "",
                      time: ""));
                } else {
                  deliveryModel.add(DeliveryModel(
                      type: shippingMethodsModel.values,
                      address: shippingMethodsModel.label,
                      isSelected: false,
                      price: "",
                      time: ""));
                }
              }

              emit(state.copyWith(
                message: updateCart.message ?? "",
                total: orderDetailModel[0].total!,
                subtotal: orderDetailModel[0].subtotal,
                proCoverage: proCoverage,
                overrideDiscount: overrideDiscount,
                deliveryModels: deliveryModel,
                orderDetailModel: orderDetailModel,
                isUpdating: false,
                updateID: "",
              ));
            } else {
              emit(state.copyWith(
                message: "Cannot update cart. Check your network connection!",
              ));
            }
          } else {
            final responseJson = await cartRepository.updateCartDelete(
                event.records, event.customerID, event.orderID);
            UpdateCart updateCart = UpdateCart.fromJson(responseJson.data);
            e.quantity = event.quantity.toDouble();
            List<OrderDetail>? orderDetailModel = [];

            var loggedInUserId =
                await SharedPreferenceService().getValue(loggedInAgentId);
            final getCalculateResp = await cartRepository.getTaxCalculate(
                event.orderID, loggedInUserId);
            TaxCalculateModel shippingModel =
                TaxCalculateModel.fromJson(getCalculateResp);
            // final responseCartNew =
            //     await cartRepository.getOrders(event.orderID);
            // CartDetailModel cartDetailModelNew =
            //     CartDetailModel.fromJson(responseCartNew.data);
            orderDetailModel.add(shippingModel.orderDetail!);

            double proCoverage = 0.0;
            double overrideDiscount = 0.0;
            if (orderDetailModel.isNotEmpty) {
              for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
                proCoverage = proCoverage +
                    (orderDetailModel[0].items![k].warrantyPrice! *
                        orderDetailModel[0].items![k].quantity!);
                overrideDiscount = overrideDiscount +
                    (orderDetailModel[0]
                            .items![k]
                            .overridePriceApproval!
                            .toLowerCase()
                            .contains("approved")
                        ? (orderDetailModel[0].items![k].unitPrice! -
                                orderDetailModel[0].items![k].overridePrice!) *
                            orderDetailModel[0].items![k].quantity!
                        : 0.0);
              }

              List<ItemsOfCart> itemsOfCart = [];
              List<Records> records = [];
              for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
                itemsOfCart.add(ItemsOfCart(
                    itemQuantity:
                        orderDetailModel[0].items![k].quantity.toString(),
                    itemId: orderDetailModel[0].items![k].itemNumber!,
                    itemName: orderDetailModel[0].items![k].itemDesc!,
                    itemProCoverage:
                        (orderDetailModel[0].items![k].warrantyPrice ?? 0.0)
                            .toString(),
                    itemPrice:
                        orderDetailModel[0].items![k].unitPrice.toString()));
                records.add(Records(
                    productId: orderDetailModel[0].items![k].productId,
                    quantity: orderDetailModel[0].items![k].quantity.toString(),
                    productName: orderDetailModel[0].items![k].itemDesc,
                    oliRecId: orderDetailModel[0].items![k].itemId!,
                    productPrice:
                        orderDetailModel[0].items![k].unitPrice!.toString(),
                    productImageUrl:
                        orderDetailModel[0].items![k].imageUrl.toString(),
                    childskus: [
                      Childskus(
                        skuENTId: orderDetailModel[0].items![k].itemNumber,
                        skuCondition: orderDetailModel[0].items![k].condition,
                        skuPrice: (orderDetailModel[0].items![k].unitPrice ?? 0)
                            .toString(),
                        skuPIMId: orderDetailModel[0].items![k].pimSkuId,
                        gcItemNumber: orderDetailModel[0].items![k].posSkuId,
                        pimStatus: orderDetailModel[0].items![k].itemStatus,
                      )
                    ]));
              }
              event.inventorySearchBloc.add(SetCart(
                  itemOfCart: itemsOfCart,
                  records: records,
                  orderId: event.orderID));
            }

            List<DeliveryModel> deliveryModel = [];

            deliveryModel.add(state.deliveryModels.isNotEmpty
                ? state.deliveryModels.first
                : DeliveryModel(
                    type: "Pick-up",
                    address: "",
                    isSelected: false,
                    price: "0",
                    time: ""));
            for (ShippingMethod shippingMethodsModel
                in shippingModel.shippingMethod ?? []) {
              if (shippingModel.orderDetail!.shippingMethod ==
                  shippingMethodsModel.values) {
                deliveryModel.add(DeliveryModel(
                    type: shippingMethodsModel.values,
                    address: shippingMethodsModel.label,
                    isSelected: true,
                    price: "",
                    time: ""));
              } else {
                deliveryModel.add(DeliveryModel(
                    type: shippingMethodsModel.values,
                    address: shippingMethodsModel.label,
                    isSelected: false,
                    price: "",
                    time: ""));
              }
            }

            emit(state.copyWith(
                message: updateCart.message ?? "",
                total: orderDetailModel[0].total!,
                subtotal: orderDetailModel[0].subtotal,
                proCoverage: proCoverage,
                overrideDiscount: overrideDiscount,
                deliveryModels: deliveryModel,
                orderDetailModel: [shippingModel.orderDetail!],
                isUpdating: false,
                updateID: ""));
          }
        }
      }
      //    }
    });
    on<GetOverrideReasons>((event, emit) async {
      List<String> overrideReasons = [];
      try {
        final response = await cartRepository.getOverrideReasons();
        OverrideReasonsModel overrideReasonsModel =
            OverrideReasonsModel.fromJson(response.data);
        for (String reason in overrideReasonsModel.overrideReasonList!) {
          overrideReasons.add(reason);
        }
        emit(state.copyWith(
            overrideReasons: overrideReasons, isOverrideLoading: false));
      } catch (e) {
        print(e.toString());
        emit(state.copyWith(overrideReasons: [], isOverrideLoading: false));
      }
    });
    on<GetShippingOverrideReasons>((event, emit) async {
      emit(state.copyWith(isOverrideLoading: true));
      List<String> overrideReasons = [];
      try {
        final response = await cartRepository.getShippingOverrideReasons();
        ShippingReasonList overrideReasonsModel =
            ShippingReasonList.fromJson(response.data);
        for (String reason
            in overrideReasonsModel.shippingOverrideReasonList ?? []) {
          overrideReasons.add(reason);
        }
        emit(state.copyWith(
            overrideReasons: overrideReasons, isOverrideLoading: false));
      } catch (e) {
        print(e.toString());
        emit(state.copyWith(overrideReasons: [], isOverrideLoading: false));
      }
    });
    on<ClearWholeCart>((event, emit) async {
      //if (event.customerID.isNotEmpty) {
      emit(state.copyWith(
        loadingScreen: true,
      ));
      List<Items> e = event.e;
      // for (int k = 0; k < e.length; k++) {
      //   await cartRepository.updateCartDelete(
      //       e[k], event.customerID, event.orderID);
      // }
      List<OrderDetail> cartDetailModel = state.orderDetailModel;
      if (cartDetailModel.isNotEmpty) {
        cartDetailModel.first.items = [];
      } // cartDetailModel.first.orderDetail!.total = 0;

      event.inventorySearchBloc
          .add(SetCart(itemOfCart: [], records: [], orderId: ""));

      emit(state.copyWith(
        loadingScreen: false,
        orderDetailModel: cartDetailModel,
      ));
      event.onCompleted.call();
      //}
    });
    on<GetDeleteReasons>((event, emit) async {
      emit(state.copyWith(fetchingReason: true));

      List<String> deleteReasons = [];
      try {
        final response = await cartRepository.getReasonsList();
        for (String reason in response.nlnReasonList!) {
          deleteReasons.add(reason);
        }
        emit(state.copyWith(reasonList: deleteReasons, fetchingReason: false));
      } catch (e) {
        print(e.toString());
        emit(state.copyWith(reasonList: [], fetchingReason: false));
      }
    });
    on<ClearOverrideReasonList>((event, emit) async {
      emit(state.copyWith(reasonList: []));
    });
    on<GetWarranties>((event, emit) async {
      try {
        List<OrderDetail> orderDetailModel = [];
        orderDetailModel = state.orderDetailModel;
        if (orderDetailModel.isNotEmpty &&
            orderDetailModel[0].items != null &&
            orderDetailModel[0].items!.length > event.index) {
          orderDetailModel[0].items![event.index].isWarrantiesLoading = true;
        }
        emit(state.copyWith(
            orderDetailModel: orderDetailModel, message: "done"));
        WarrantiesModel response =
            await cartRepository.getWarranties(event.skuEntId);
        if (response.warranties!.isEmpty) {
          print("response .lenfkn ${response.warranties!.length}");
          if (orderDetailModel.isNotEmpty &&
              orderDetailModel[0].items != null &&
              orderDetailModel[0].items!.length > event.index) {
            orderDetailModel[0].items![event.index].warranties = [];
            orderDetailModel[0].items![event.index].isWarrantiesLoading = false;
          }
          emit(state.copyWith(
              orderDetailModel: orderDetailModel, message: "done"));
        } else {
          if (orderDetailModel.isNotEmpty &&
              orderDetailModel[0].items != null &&
              orderDetailModel[0].items!.length > event.index) {
            orderDetailModel[0].items![event.index].warranties =
                response.warranties;
            orderDetailModel[0].items![event.index].isWarrantiesLoading = false;
          }
          emit(state.copyWith(
              orderDetailModel: orderDetailModel, message: "done"));
        }
      } catch (e) {
        print("e.toString() ${e.toString()}");
        List<OrderDetail> orderDetailModel = [];
        orderDetailModel = state.orderDetailModel;
        if (orderDetailModel.isNotEmpty &&
            orderDetailModel[0].items != null &&
            orderDetailModel[0].items!.length > event.index) {
          orderDetailModel[0].items![event.index].warranties = [];
          orderDetailModel[0].items![event.index].isWarrantiesLoading = false;
        }
        emit(state.copyWith(
            orderDetailModel: orderDetailModel, message: "done"));
      }
    });
    on<ChangeOverrideReason>((event, emit) async {
      emit(state.copyWith(
        selectedOverrideReasons: event.reason,
      ));
    });
    on<ChangeDeleteReason>((event, emit) async {
      emit(state.copyWith(
        selectedReason: event.reason,
      ));
    });
    on<ChangeWarranties>((event, emit) async {
      print("ChangeWarranties is called => ");
      List<OrderDetail> orderDetailModelOld = [];

      orderDetailModelOld = state.orderDetailModel;
      if (orderDetailModelOld.isNotEmpty) {
        orderDetailModelOld[0].items![event.index].isUpdatingCoverage = true;
        orderDetailModelOld[0].items![event.index].warrantyStyleDesc =
            event.warranties.styleDescription1;
        orderDetailModelOld[0].items![event.index].warrantySkuId =
            event.warranties.enterpriseSkuId;
        orderDetailModelOld[0].items![event.index].warrantyPrice =
            event.warranties.price;
        orderDetailModelOld[0].items![event.index].warrantyId =
            event.warranties.id;
        orderDetailModelOld[0].items![event.index].warrantyDisplayName =
            event.warranties.displayName;
      }
      emit(state.copyWith(
          orderDetailModel: orderDetailModelOld, message: "done"));
      await cartRepository.updateWarranties(event.warranties, event.orderItem);
      List<OrderDetail>? orderDetailModel = [];

      var loggedInUserId =
          await SharedPreferenceService().getValue(loggedInAgentId);
      final getCalculateResp =
          await cartRepository.getTaxCalculate(event.orderID, loggedInUserId);
      TaxCalculateModel shippingModel =
          TaxCalculateModel.fromJson(getCalculateResp);
      // final responseCartNew = await cartRepository.getOrders(event.orderID);
      // CartDetailModel cartDetailModelNew =
      //     CartDetailModel.fromJson(responseCartNew.data);
      if (shippingModel.orderDetail != null) {
        orderDetailModel.add(shippingModel.orderDetail!);
      }
      double proCoverage = 0.0;
      double overrideDiscount = 0.0;
      if (orderDetailModel.isNotEmpty) {
        for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
          proCoverage = proCoverage +
              (orderDetailModel[0].items![k].warrantyPrice! *
                  orderDetailModel[0].items![k].quantity!);
          overrideDiscount = overrideDiscount +
              (orderDetailModel[0]
                      .items![k]
                      .overridePriceApproval!
                      .toLowerCase()
                      .contains("approved")
                  ? (orderDetailModel[0].items![k].unitPrice! -
                          orderDetailModel[0].items![k].overridePrice!) *
                      orderDetailModel[0].items![k].quantity!
                  : 0.0);
        }

        List<ItemsOfCart> itemsOfCart = [];
        List<Records> records = [];
        for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
          itemsOfCart.add(ItemsOfCart(
              itemQuantity: orderDetailModel[0].items![k].quantity.toString(),
              itemId: orderDetailModel[0].items![k].itemNumber!,
              itemName: orderDetailModel[0].items![k].itemDesc!,
              itemProCoverage:
                  (orderDetailModel[0].items![k].warrantyPrice ?? 0.0)
                      .toString(),
              itemPrice: orderDetailModel[0].items![k].unitPrice.toString()));
          records.add(Records(
              productId: orderDetailModel[0].items![k].productId,
              quantity: orderDetailModel[0].items![k].quantity.toString(),
              productName: orderDetailModel[0].items![k].itemDesc,
              oliRecId: orderDetailModel[0].items![k].itemId!,
              productPrice: orderDetailModel[0].items![k].unitPrice!.toString(),
              productImageUrl:
                  orderDetailModel[0].items![k].imageUrl.toString(),
              childskus: [
                Childskus(
                  skuENTId: orderDetailModel[0].items![k].itemNumber,
                  skuCondition: orderDetailModel[0].items![k].condition,
                  skuPrice:
                      (orderDetailModel[0].items![k].unitPrice ?? 0).toString(),
                  skuPIMId: orderDetailModel[0].items![k].pimSkuId,
                  gcItemNumber: orderDetailModel[0].items![k].posSkuId,
                  pimStatus: orderDetailModel[0].items![k].itemStatus,
                )
              ]));
        }
        event.inventorySearchBloc.add(SetCart(
            itemOfCart: itemsOfCart, records: records, orderId: event.orderID));
      }

      List<DeliveryModel> deliveryModel = [];

      deliveryModel.add(state.deliveryModels.isNotEmpty
          ? state.deliveryModels.first
          : DeliveryModel(
              type: "Pick-up",
              address: "",
              isSelected: false,
              price: "0",
              time: ""));
      for (ShippingMethod shippingMethodsModel
          in shippingModel.shippingMethod ?? []) {
        if (shippingModel.orderDetail!.shippingMethod ==
            shippingMethodsModel.values) {
          deliveryModel.add(DeliveryModel(
              type: shippingMethodsModel.values,
              address: shippingMethodsModel.label,
              isSelected: true,
              price: "",
              time: ""));
        } else {
          deliveryModel.add(DeliveryModel(
              type: shippingMethodsModel.values,
              address: shippingMethodsModel.label,
              isSelected: false,
              price: "",
              time: ""));
        }
      }
      if (orderDetailModel.isNotEmpty &&
          orderDetailModel[0].items != null &&
          orderDetailModel[0].items!.length > event.index) {
        orderDetailModel[0].items![event.index].isUpdatingCoverage = false;
      }
      emit(state.copyWith(
          total: orderDetailModel.isNotEmpty ? orderDetailModel[0].total : 0.0,
          subtotal:
              orderDetailModel.isNotEmpty ? orderDetailModel[0].subtotal : 0.0,
          proCoverage: proCoverage,
          overrideDiscount: overrideDiscount,
          deliveryModels: deliveryModel,
          orderDetailModel: orderDetailModel,
          message: "done"));
    });
    on<RemoveWarranties>((event, emit) async {
      print("RemoveWarranties is called => ");
      List<OrderDetail> orderDetailModelOld = [];

      orderDetailModelOld = state.orderDetailModel;
      if (orderDetailModelOld.isNotEmpty) {
        orderDetailModelOld[0].items![event.index].isUpdatingCoverage = true;
        orderDetailModelOld[0].items![event.index].warrantyStyleDesc = "";
        orderDetailModelOld[0].items![event.index].warrantySkuId = "";
        orderDetailModelOld[0].items![event.index].warrantyPrice = 0.0;
        orderDetailModelOld[0].items![event.index].warrantyId = "";
        orderDetailModelOld[0].items![event.index].warrantyDisplayName =
            event.warranties.displayName;
      }
      emit(state.copyWith(
          orderDetailModel: orderDetailModelOld, message: "done"));
      await cartRepository.removeWarranties(event.warranties, event.orderItem);
      List<OrderDetail>? orderDetailModel = [];

      var loggedInUserId =
          await SharedPreferenceService().getValue(loggedInAgentId);
      final getCalculateResp =
          await cartRepository.getTaxCalculate(event.orderID, loggedInUserId);
      TaxCalculateModel shippingModel =
          TaxCalculateModel.fromJson(getCalculateResp);
      // final responseCartNew = await cartRepository.getOrders(event.orderID);
      // CartDetailModel cartDetailModelNew =
      //     CartDetailModel.fromJson(responseCartNew.data);
      if (shippingModel.orderDetail != null) {
        orderDetailModel.add(shippingModel.orderDetail!);
      }
      double proCoverage = 0.0;
      double overrideDiscount = 0.0;
      if (orderDetailModel.isNotEmpty) {
        for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
          proCoverage = proCoverage +
              (orderDetailModel[0].items![k].warrantyPrice! *
                  orderDetailModel[0].items![k].quantity!);
          overrideDiscount = overrideDiscount +
              (orderDetailModel[0]
                      .items![k]
                      .overridePriceApproval!
                      .toLowerCase()
                      .contains("approved")
                  ? (orderDetailModel[0].items![k].unitPrice! -
                          orderDetailModel[0].items![k].overridePrice!) *
                      orderDetailModel[0].items![k].quantity!
                  : 0.0);
        }

        List<ItemsOfCart> itemsOfCart = [];
        List<Records> records = [];
        for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
          itemsOfCart.add(ItemsOfCart(
              itemQuantity: orderDetailModel[0].items![k].quantity.toString(),
              itemId: orderDetailModel[0].items![k].itemNumber!,
              itemName: orderDetailModel[0].items![k].itemDesc!,
              itemProCoverage:
                  (orderDetailModel[0].items![k].warrantyPrice ?? 0.0)
                      .toString(),
              itemPrice: orderDetailModel[0].items![k].unitPrice.toString()));
          records.add(Records(
              productId: orderDetailModel[0].items![k].productId,
              quantity: orderDetailModel[0].items![k].quantity.toString(),
              productName: orderDetailModel[0].items![k].itemDesc,
              oliRecId: orderDetailModel[0].items![k].itemId!,
              productPrice: orderDetailModel[0].items![k].unitPrice!.toString(),
              productImageUrl:
                  orderDetailModel[0].items![k].imageUrl.toString(),
              childskus: [
                Childskus(
                  skuENTId: orderDetailModel[0].items![k].itemNumber,
                  skuCondition: orderDetailModel[0].items![k].condition,
                  skuPrice:
                      (orderDetailModel[0].items![k].unitPrice ?? 0).toString(),
                  skuPIMId: orderDetailModel[0].items![k].pimSkuId,
                  gcItemNumber: orderDetailModel[0].items![k].posSkuId,
                  pimStatus: orderDetailModel[0].items![k].itemStatus,
                )
              ]));
        }
        event.inventorySearchBloc.add(SetCart(
            itemOfCart: itemsOfCart, records: records, orderId: event.orderID));
      }

      List<DeliveryModel> deliveryModel = [];

      deliveryModel.add(state.deliveryModels.isNotEmpty
          ? state.deliveryModels.first
          : DeliveryModel(
              type: "Pick-up",
              address: "",
              isSelected: false,
              price: "0",
              time: ""));
      for (ShippingMethod shippingMethodsModel
          in shippingModel.shippingMethod ?? []) {
        if (shippingModel.orderDetail!.shippingMethod ==
            shippingMethodsModel.values) {
          deliveryModel.add(DeliveryModel(
              type: shippingMethodsModel.values,
              address: shippingMethodsModel.label,
              isSelected: true,
              price: "",
              time: ""));
        } else {
          deliveryModel.add(DeliveryModel(
              type: shippingMethodsModel.values,
              address: shippingMethodsModel.label,
              isSelected: false,
              price: "",
              time: ""));
        }
      }
      if (orderDetailModel.isNotEmpty &&
          orderDetailModel[0].items != null &&
          orderDetailModel[0].items!.length > event.index) {
        orderDetailModel[0].items![event.index].isUpdatingCoverage = false;
      }
      emit(state.copyWith(
          total: orderDetailModel.isNotEmpty ? orderDetailModel[0].total : null,
          subtotal:
              orderDetailModel.isNotEmpty ? orderDetailModel[0].subtotal : null,
          proCoverage: proCoverage,
          overrideDiscount: overrideDiscount,
          deliveryModels: deliveryModel,
          orderDetailModel: orderDetailModel,
          message: "done"));
    });
    on<EmptyMessage>((event, emit) async {
      emit(state.copyWith(
        message: "",
      ));
    });
    on<UpdateStateMessage>((event, emit) async {
      emit(state.copyWith(
          message: "done",
          saveCustomerStatus:
              state.saveCustomerStatus == CartSaveCustomerStatus.saving
                  ? CartSaveCustomerStatus.notSaving
                  : CartSaveCustomerStatus.saving));
    });
    on<ChangeIsOverridden>((event, emit) async {
      print(event.value);
      List<OrderDetail> orderDetailModel = [];
      orderDetailModel = state.orderDetailModel;
      if (orderDetailModel.isNotEmpty) {
        orderDetailModel[0]
            .items!
            .firstWhere((element) => element.itemId == event.item.itemId)
            .isOverridden = event.value;
      }
      emit(state.copyWith(
        orderDetailModel: orderDetailModel,
      ));
    });
    on<ChangeIsExpanded>((event, emit) async {
      List<OrderDetail> orderDetailModel = [];
      orderDetailModel = state.orderDetailModel;
      if (orderDetailModel.isNotEmpty) {
        orderDetailModel[0]
            .items!
            .firstWhere((element) => element.itemId == event.item.itemId)
            .isExpanded = event.value;
      }
      emit(state.copyWith(
        orderDetailModel: orderDetailModel,
      ));
    });
    on<ChangeIsExpandedBottomSheet>((event, emit) async {
      emit(state.copyWith(
        isExpanded: event.value,
      ));
    });
    on<UpdateShowAmount>((event, emit) async {
      emit(state.copyWith(
        showAmount: event.value,
      ));
    });
    on<UpdateSaveAsDefaultAddress>((event, emit) async {
      emit(state.copyWith(
        isDefaultAddress: event.value,
      ));
    });
    on<UpdateSameAsBilling>((event, emit) async {
      emit(state.copyWith(
        sameAsBilling: event.value,
      ));
    });
    on<UpdateAddCardAmount>((event, emit) async {
      emit(state.copyWith(
        addCardAmount: event.value,
      ));
    });
    on<UpdateCardHolderName>((event, emit) async {
      emit(state.copyWith(
        cardHolderName: event.value,
      ));
    });
    on<UpdateCardNumber>((event, emit) async {
      emit(state.copyWith(
        cardNumber: event.value,
      ));
    });
    on<UpdateCardAmount>((event, emit) async {
      emit(state.copyWith(
        cardAmount: event.value,
      ));
    });
    on<UpdateExpiryYear>((event, emit) async {
      emit(state.copyWith(
        expiryYear: event.value,
      ));
    });
    on<UpdateCvvCode>((event, emit) async {
      emit(state.copyWith(
        cvvCode: event.value,
      ));
    });
    on<UpdateExpiryMonth>((event, emit) async {
      emit(state.copyWith(
        expiryMonth: event.value,
      ));
    });
    on<UpdateIsCvvFocused>((event, emit) async {
      emit(state.copyWith(
        isCvvFocused: event.value,
      ));
    });
    on<UpdateHeading>((event, emit) async {
      emit(state.copyWith(
        heading: event.value,
      ));
    });
    on<UpdateState>((event, emit) async {
      emit(state.copyWith(
        state: event.value,
      ));
    });
    on<UpdateAddress>((event, emit) async {
      emit(state.copyWith(
        address: event.value,
      ));
    });
    on<UpdateZipCode>((event, emit) async {
      emit(state.copyWith(
        zipCode: event.value,
      ));
    });
    on<UpdateCity>((event, emit) async {
      emit(state.copyWith(
        city: event.value,
      ));
    });
    on<UpdateNumberOfCartItems>((event, emit) async {
      emit(state.copyWith(
        numberOfCartItems: event.value,
      ));
    });
    on<UpdateSelectedState>((event, emit) async {
      emit(state.copyWith(
        selectedState: event.value,
      ));
    });
    on<UpdateSelectedCity>((event, emit) async {
      emit(state.copyWith(
        selectedCity: event.value,
      ));
    });
    on<UpdateProceedingOrder>((event, emit) async {
      emit(state.copyWith(
        proceedingOrder: event.value,
      ));
    });
    on<UpdateCompleteOrder>((event, emit) async {
      emit(state.copyWith(
        callCompleteOrder: event.value,
      ));
    });
    on<UpdateObscureCardNumber>((event, emit) async {
      emit(state.copyWith(
        obscureCardNumber: event.value,
      ));
    });
    on<UpdateActiveStep>((event, emit) async {
      emit(state.copyWith(
          activeStep: event.value, isExpanded: false, proceedingOrder: false));
    });
    on<UpdatePickUpZip>((event, emit) async {
      print("UpdatePickUpZip is called => ");
      List<DeliveryModel> deliveryModels = [];
      deliveryModels = state.deliveryModels;
      var store = event.searchStoreListInformation;
      if (deliveryModels.isNotEmpty) {
        deliveryModels.first.pickupAddress =
            '${store.storeAddressC},\n${store.storeCityC}, ${store.stateC}, ${store.postalCodeC}';
        deliveryModels.first.time = event.searchStoreList.distance;
        deliveryModels.first.isSelected = true;
        deliveryModels.first.name = event.searchStoreList.name;
        deliveryModels.first.isPickup = true;
      }
      emit(state.copyWith(
          selectedPickupStore: event.searchStoreListInformation,
          selectedPickupStoreList: event.searchStoreList,
          deliveryModels: deliveryModels,
          pickUpStoreId: event.searchStoreList.id ?? "",
          pickUpZip: event.searchStoreList.postalCode ?? "",
          savingAddress: true));

      SendTaxInfoModel sendTaxInfoModel =
          await cartRepository.sendTaxInfoDelivery(
        orderId: event.orderID,
        storeNumber: event.searchStoreList.id ?? "",
        storeCity: event.searchStoreListInformation.storeCityC ?? "",
        email: event.email,
        phone: event.phone,
        firstName: event.firstName,
        lastName: event.lastName,
      );
      if (sendTaxInfoModel.isSuccess!) {
        var loggedInUserId =
            await SharedPreferenceService().getValue(loggedInAgentId);
        List<OrderDetail>? orderDetailModel = [];
        final getCalculateResp =
            await cartRepository.getTaxCalculate(event.orderID, loggedInUserId);
        TaxCalculateModel shippingModel =
            TaxCalculateModel.fromJson(getCalculateResp);
        // final responseCartNew = await cartRepository.getOrders(event.orderID);
        // CartDetailModel cartDetailModelNew =
        // CartDetailModel.fromJson(responseCartNew.data);
        orderDetailModel.add(shippingModel.orderDetail!);

        double proCoverage = 0.0;
        double overrideDiscount = 0.0;
        if (orderDetailModel.isNotEmpty) {
          for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
            proCoverage = proCoverage +
                (orderDetailModel[0].items![k].warrantyPrice! *
                    orderDetailModel[0].items![k].quantity!);
            overrideDiscount = overrideDiscount +
                (orderDetailModel[0]
                        .items![k]
                        .overridePriceApproval!
                        .toLowerCase()
                        .contains("approved")
                    ? (orderDetailModel[0].items![k].unitPrice! -
                            orderDetailModel[0].items![k].overridePrice!) *
                        orderDetailModel[0].items![k].quantity!
                    : 0.0);
          }
        }

        List<DeliveryModel> deliveryModel = [];

        deliveryModel.add(state.deliveryModels.isNotEmpty
            ? state.deliveryModels.first
            : DeliveryModel(
                type: "Pick-up",
                address: "",
                isSelected: false,
                price: "0",
                time: ""));
        for (ShippingMethod shippingMethodsModel
            in shippingModel.shippingMethod ?? []) {
          if (shippingModel.orderDetail!.shippingMethod ==
              shippingMethodsModel.values) {
            deliveryModel.add(DeliveryModel(
                type: shippingMethodsModel.values,
                address: shippingMethodsModel.label,
                isSelected: true,
                price: "",
                time: ""));
          } else {
            deliveryModel.add(DeliveryModel(
                type: shippingMethodsModel.values,
                address: shippingMethodsModel.label,
                isSelected: false,
                price: "",
                time: ""));
          }
        }

        emit(state.copyWith(
            total: orderDetailModel[0].total!,
            subtotal: orderDetailModel[0].subtotal,
            proCoverage: proCoverage,
            overrideDiscount: overrideDiscount,
            deliveryModels: deliveryModel,
            orderDetailModel: orderDetailModel,
            savingAddress: false));
      }
    });
    on<UpdateOrderUser>((event, emit) async {
      emit(state.copyWith(loadingScreen: true));
      String orderId = event.orderId;
      String account = event.accountId;

      AssignUserModel assignUserModel =
      await cartRepository.assignUser(orderId: orderId, accountId: account);
      if (assignUserModel.isSuccess!) {
        emit(state.copyWith(loadingScreen: false));
        var loggedInUserId =
        await SharedPreferenceService().getValue(loggedInAgentId);

        List<OrderDetail>? orderDetailModel = [];
        final getCalculateResp =
        await cartRepository.getTaxCalculate(event.orderId, loggedInUserId);

//        final responseJson = await cartRepository.getOrders(orderId);
        if (getCalculateResp != null) {
          TaxCalculateModel shippingModel =
          TaxCalculateModel.fromJson(getCalculateResp);
          orderDetailModel.add(shippingModel.orderDetail!);
          if (orderDetailModel.isNotEmpty) {
            var loggedInUserId =
            await SharedPreferenceService().getValue(loggedInAgentId);
            final getCalculateResp = await cartRepository.getTaxCalculate(
                event.orderId, loggedInUserId);
            TaxCalculateModel taxInfo =
            TaxCalculateModel.fromJson(getCalculateResp);
            if (shippingModel.orderDetail != null) {
              double newProCoverage = 0.0;
              double newOverrideDiscount = 0.0;
              for (int k = 0;
              k < shippingModel.orderDetail!.items!.length;
              k++) {
                newProCoverage +=
                (shippingModel.orderDetail!.items![k].warrantyPrice! *
                    shippingModel.orderDetail!.items![k].quantity!);
                newOverrideDiscount += (shippingModel
                    .orderDetail!.items![k].overridePriceApproval ==
                    "Approved"
                    ? (shippingModel.orderDetail!.items![k].unitPrice! -
                    shippingModel
                        .orderDetail!.items![k].overridePrice!) *
                    shippingModel.orderDetail!.items![k].quantity!
                    : 0.0);
              }
              List<ItemsOfCart> itemsOfCart = [];
              List<Records> records = [];
              for (int k = 0;
              k < shippingModel.orderDetail!.items!.length;
              k++) {
                itemsOfCart.add(ItemsOfCart(
                    itemQuantity: shippingModel.orderDetail!.items![k].quantity
                        .toString(),
                    itemProCoverage:
                    (orderDetailModel[0].items![k].warrantyPrice ?? 0.0)
                        .toString(),
                    itemId: shippingModel.orderDetail!.items![k].itemNumber!,
                    itemName: shippingModel.orderDetail!.items![k].itemDesc!,
                    itemPrice: shippingModel.orderDetail!.items![k].unitPrice
                        .toString()));
                records.add(Records(
                    productId: shippingModel.orderDetail!.items![k].productId,
                    quantity: shippingModel.orderDetail!.items![k].quantity
                        .toString(),
                    productName: shippingModel.orderDetail!.items![k].itemDesc,
                    oliRecId: shippingModel.orderDetail!.items![k].itemId!,
                    productPrice: shippingModel
                        .orderDetail!.items![k].unitPrice!
                        .toString(),
                    productImageUrl: shippingModel
                        .orderDetail!.items![k].imageUrl
                        .toString(),
                    childskus: [
                      Childskus(
                        skuENTId:
                        shippingModel.orderDetail!.items![k].itemNumber,
                        skuCondition:
                        shippingModel.orderDetail!.items![k].condition,
                        skuPIMId: shippingModel.orderDetail!.items![k].pimSkuId,
                        skuPrice: (orderDetailModel[0].items![k].unitPrice ?? 0)
                            .toString(),
                        gcItemNumber:
                        shippingModel.orderDetail!.items![k].posSkuId,
                        pimStatus:
                        shippingModel.orderDetail!.items![k].itemStatus,
                      )
                    ]));
              }
              // event.inventorySearchBloc.add(SetCart(
              //     itemOfCart: itemsOfCart,
              //     records: records,
              //     orderId: orderId));
              List<OrderDetail>? orderNew = state.orderDetailModel;
              if (orderNew.isNotEmpty) {
                shippingModel.orderDetail!.items = orderNew.first.items!;
              }
              List<DeliveryModel> deliveryModel = [];
              deliveryModel.add(state.deliveryModels.isNotEmpty
                  ? state.deliveryModels.first
                  : DeliveryModel(
                  type: "Pick-up",
                  address: "",
                  isSelected: false,
                  price: "0",
                  time: ""));
              for (ShippingMethod shippingMethodsModel
              in taxInfo.shippingMethod ?? []) {
                if (shippingModel.orderDetail!.shippingMethod ==
                    shippingMethodsModel.values) {
                  deliveryModel.add(DeliveryModel(
                      type: shippingMethodsModel.values,
                      address: shippingMethodsModel.label,
                      isSelected: true,
                      price: "",
                      time: ""));
                } else {
                  deliveryModel.add(DeliveryModel(
                      type: shippingMethodsModel.values,
                      address: shippingMethodsModel.label,
                      isSelected: false,
                      price: "",
                      time: ""));
                }
              }
              emit(state.copyWith(
                  total: shippingModel.orderDetail!.total!,
                  subtotal: shippingModel.orderDetail!.subtotal,
                  loadingScreen: false,
                  deliveryModels: deliveryModel,
                  proCoverage: newProCoverage,
                  overrideDiscount: newOverrideDiscount,
                  orderDetailModel: [shippingModel.orderDetail!]));
            }
          }
        }
      } else {
        emit(state.copyWith(
            message: "User cannot be assigned", loadingScreen: false));
      }
    });
    on<RemoveCreditCardModelSave>((event, emit) async {
      List<CreditCardModelSave> creditCardModelSave = state.creditCardModelSave;
      if (creditCardModelSave.isNotEmpty) {
        creditCardModelSave.remove(event.value);
      }
      emit(state.copyWith(
        creditCardModelSave: creditCardModelSave,
      ));
    });
    on<AddInAddressModel>((event, emit) async {
      List<AddressList> addressModel = state.addressModel;
      // addressModel.insert(0, event.value);

      emit(state.copyWith(
        addressModel: [...addressModel, event.value],
      ));
    });
    on<AddInCreditCardModel>((event, emit) async {
      List<CreditCardModelSave> creditModel = state.creditCardModelSave;
      // creditModel.insert(0, event.value);
      emit(state.copyWith(
        creditCardModelSave: [...creditModel, event.value],
      ));
    });
    on<ChangeAddressIsSelected>((event, emit) async {
      List<AddressList> addressModel = state.addressModel;
      for (AddressList a in addressModel) {
        a.isSelected = false;
      }
      emit(state.copyWith(
        addressModel: addressModel,
      ));
    });
    on<ChangeRecommendedAddress>((event, emit) async {
      print("ChangeRecommendedAddress is called => ");
      emit(state.copyWith(
        proceedingOrder: true,
      ));

      OrderDetail cartDetailModel = state.orderDetailModel.isNotEmpty
          ? state.orderDetailModel.first
          : OrderDetail();
      SendTaxInfoModel sendTaxInfoModel = await cartRepository.sendTaxInfoAddress(
          orderId: event.orderID,
          firstName: event.firstName ?? "",
          lastName: event.lastName ?? "",
          middleName: cartDetailModel.middleName ?? "",
          phoneName: event.phone ?? "",
          shippingEmail: event.email ?? "",
          shippingAddress:
              "${state.recommendedAddressLine1.isNotEmpty ? state.recommendedAddressLine1 : ""}",
          shippingAddress2:
              "${state.recommendedAddressLine2.isNotEmpty ? state.recommendedAddressLine2 : ""}",
          shippingCity: state.recommendedAddressLineCity,
          shippingCountry: state.recommendedAddressLineCountry,
          shippingState: state.recommendedAddressLineState,
          shippingMethodName: cartDetailModel.shippingMethod ?? "",
          shippingZipCode: state.recommendedAddressLineZipCode);
      if (sendTaxInfoModel.isSuccess!) {
        var loggedInUserId =
            await SharedPreferenceService().getValue(loggedInAgentId);
        final getCalculateResp =
            await cartRepository.getTaxCalculate(event.orderID, loggedInUserId);
        // final newResponseJson = await cartRepository.getOrders(event.orderID);
        if (getCalculateResp != null) {
          TaxCalculateModel shippingModel =
              TaxCalculateModel.fromJson(getCalculateResp);
          if (shippingModel.orderDetail != null) {
            double newProCoverage = 0.0;
            double newOverrideDiscount = 0.0;
            for (int k = 0; k < shippingModel.orderDetail!.items!.length; k++) {
              newProCoverage +=
                  (shippingModel.orderDetail!.items![k].warrantyPrice! *
                      shippingModel.orderDetail!.items![k].quantity!);
              newOverrideDiscount += (shippingModel
                          .orderDetail!.items![k].overridePriceApproval ==
                      "Approved"
                  ? (shippingModel.orderDetail!.items![k].unitPrice! -
                          shippingModel.orderDetail!.items![k].overridePrice!) *
                      shippingModel.orderDetail!.items![k].quantity!
                  : 0.0);
            }
            List<OrderDetail>? orderNew = state.orderDetailModel;
            if (orderNew.isNotEmpty) {
              shippingModel.orderDetail!.items = orderNew.first.items!;
            }
            List<DeliveryModel> deliveryModel = [];
            deliveryModel.add(DeliveryModel(
                type: "Pick-up",
                address: "",
                isSelected: false,
                price: "0",
                time: ""));
            for (ShippingMethod shippingMethodsModel
                in shippingModel.shippingMethod ?? []) {
              if (shippingModel.orderDetail!.shippingMethod ==
                  shippingMethodsModel.values) {
                deliveryModel.add(DeliveryModel(
                    type: shippingMethodsModel.values,
                    address: shippingMethodsModel.label,
                    isSelected: true,
                    price: "",
                    time: ""));
              } else {
                deliveryModel.add(DeliveryModel(
                    type: shippingMethodsModel.values,
                    address: shippingMethodsModel.label,
                    isSelected: false,
                    price: "",
                    time: ""));
              }
            }
            List<AddressList> addressModel = state.addressModel;
            for (AddressList a in addressModel) {
              if (addressModel.indexOf(a) == event.index) {
                a.isSelected = true;
              } else {
                a.isSelected = false;
              }
            }

            emit(state.copyWith(
                total: shippingModel.orderDetail!.total!,
                subtotal: shippingModel.orderDetail!.subtotal,
                deliveryModels: deliveryModel,
                callCompleteOrder: true,
                proceedingOrder: false,
                updateIndex: event.index,
                proCoverage: newProCoverage,
                overrideDiscount: newOverrideDiscount,
                orderDetailModel: [shippingModel.orderDetail!]));
          }
        } else {
          emit(state.copyWith(
              callCompleteOrder: false,
              proceedingOrder: false,
              message:
                  "Failed to complete order. Tax info not found after applying applying recommended address",
              recommendedAddress: "",
              orderAddress: "",
              updateIndex: event.index));
        }
      } else {
        emit(state.copyWith(
            callCompleteOrder: false,
            proceedingOrder: false,
            message:
                "Failed to complete order. Recommended address is not applicable",
            recommendedAddress: "",
            orderAddress: "",
            updateIndex: event.index));
      }
    });
    on<ChangeDeliveryModelIsSelectedWithDelivery>((event, emit) async {
      print("ChangeDeliveryModelIsSelectedWithDelivery is called => ");
      List<DeliveryModel> deliveryModel = state.deliveryModels;

      for (DeliveryModel d in deliveryModel) {
        if (d == event.deliveryModel) {
          d.isSelected = true;
          d.isPickup = false;
        } else {
          d.isSelected = false;
        }
      }

      emit(state.copyWith(deliveryModels: deliveryModel, savingAddress: true));
      if (event.deliveryModel.type!.toLowerCase() != "pick-up") {
        SendTaxInfoModel sendTaxInfoModel =
            await cartRepository.sendTaxInfoShippingMethod(
          orderId: event.orderId,
          shippingMethodName: event.deliveryModel.type ?? "",
          shippingMethodPrice:
              event.deliveryModel.address!.split("\$").length > 1
                  ? event.deliveryModel.address!.split("\$")[1].trim()
                  : "0",
          email: event.email,
          phone: event.phone,
          firstName: event.firstName,
          lastName: event.lastName,
        );
        if (sendTaxInfoModel.isSuccess!) {
          var loggedInUserId =
              await SharedPreferenceService().getValue(loggedInAgentId);
          final getCalculateResp = await cartRepository.getTaxCalculate(
              event.orderId, loggedInUserId);
          // final newResponseJson = await cartRepository.getOrders(event.orderId);
          if (getCalculateResp != null) {
            TaxCalculateModel shippingModel =
                TaxCalculateModel.fromJson(getCalculateResp);
            if (shippingModel.orderDetail != null) {
              double newProCoverage = 0.0;
              double newOverrideDiscount = 0.0;
              for (int k = 0;
                  k < shippingModel.orderDetail!.items!.length;
                  k++) {
                newProCoverage +=
                    (shippingModel.orderDetail!.items![k].warrantyPrice! *
                        shippingModel.orderDetail!.items![k].quantity!);
                newOverrideDiscount += (shippingModel
                            .orderDetail!.items![k].overridePriceApproval ==
                        "Approved"
                    ? (shippingModel.orderDetail!.items![k].unitPrice! -
                            shippingModel
                                .orderDetail!.items![k].overridePrice!) *
                        shippingModel.orderDetail!.items![k].quantity!
                    : 0.0);
              }
              List<OrderDetail>? orderNew = state.orderDetailModel;
              if (orderNew.isNotEmpty) {
                shippingModel.orderDetail!.items = orderNew.first.items!;
              }
              emit(state.copyWith(
                  total: shippingModel.orderDetail!.total!,
                  subtotal: shippingModel.orderDetail!.subtotal,
                  savingAddress: false,
                  proCoverage: newProCoverage,
                  overrideDiscount: newOverrideDiscount,
                  orderDetailModel: [shippingModel.orderDetail!]));
            }
          }
        }
      } else {
        emit(state.copyWith(savingAddress: false));
      }
    });
    on<AnimatedHide>((event, emit) async {
      double initialExtent = event.value ? state.minExtent : state.maxExtent;
      emit(state.copyWith(
          isExpanded: event.value, initialExtent: initialExtent));
    });
    on<SendOverrideReason>((event, emit) async {
      emit(state.copyWith(
        isOverrideSubmitting: true,
      ));
      List<OrderDetail> orderDetailModel = [];
      orderDetailModel = state.orderDetailModel;

      try {
        final responseJson = await cartRepository.sendOverrideReasons(
            event.orderLineItemID,
            event.requestedAmount,
            "",
            event.selectedOverrideReasons,
            event.userID);
        SubmitOverrideRequest submitOverrideRequest =
            SubmitOverrideRequest.fromJson(responseJson.data);

        if (submitOverrideRequest.isSuccess != null &&
            submitOverrideRequest.isSuccess!) {
          List<OrderDetail>? orderDetailModel = [];

          var loggedInUserId =
              await SharedPreferenceService().getValue(loggedInAgentId);
          final getCalculateResp = await cartRepository.getTaxCalculate(
              event.orderID, loggedInUserId);
          TaxCalculateModel shippingModel =
              TaxCalculateModel.fromJson(getCalculateResp);
          // final responseCartNew = await cartRepository.getOrders(event.orderID);
          // CartDetailModel cartDetailModelNew =
          //     CartDetailModel.fromJson(responseCartNew.data);
          orderDetailModel.add(shippingModel.orderDetail!);

          double proCoverage = 0.0;
          double overrideDiscount = 0.0;
          if (orderDetailModel.isNotEmpty) {
            for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
              proCoverage = proCoverage +
                  (orderDetailModel[0].items![k].warrantyPrice! *
                      orderDetailModel[0].items![k].quantity!);
              overrideDiscount = overrideDiscount +
                  (orderDetailModel[0]
                          .items![k]
                          .overridePriceApproval!
                          .toLowerCase()
                          .contains("approved")
                      ? (orderDetailModel[0].items![k].unitPrice! -
                              orderDetailModel[0].items![k].overridePrice!) *
                          orderDetailModel[0].items![k].quantity!
                      : 0.0);
            }
            List<ItemsOfCart> itemsOfCart = [];
            List<Records> records = [];
            for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
              itemsOfCart.add(ItemsOfCart(
                  itemQuantity:
                      orderDetailModel[0].items![k].quantity.toString(),
                  itemId: orderDetailModel[0].items![k].itemNumber!,
                  itemName: orderDetailModel[0].items![k].itemDesc!,
                  itemProCoverage:
                      (orderDetailModel[0].items![k].warrantyPrice ?? 0.0)
                          .toString(),
                  itemPrice:
                      orderDetailModel[0].items![k].unitPrice.toString()));
              records.add(Records(
                  productId: orderDetailModel[0].items![k].productId,
                  quantity: orderDetailModel[0].items![k].quantity.toString(),
                  productName: orderDetailModel[0].items![k].itemDesc,
                  oliRecId: orderDetailModel[0].items![k].itemId!,
                  productPrice:
                      orderDetailModel[0].items![k].unitPrice!.toString(),
                  productImageUrl:
                      orderDetailModel[0].items![k].imageUrl.toString(),
                  childskus: [
                    Childskus(
                      skuENTId: orderDetailModel[0].items![k].itemNumber,
                      skuCondition: orderDetailModel[0].items![k].condition,
                      skuPIMId: orderDetailModel[0].items![k].pimSkuId,
                      gcItemNumber: orderDetailModel[0].items![k].posSkuId,
                      skuPrice: (orderDetailModel[0].items![k].unitPrice ?? 0)
                          .toString(),
                      pimStatus: orderDetailModel[0].items![k].itemStatus,
                    )
                  ]));
            }
            event.inventorySearchBloc.add(SetCart(
                itemOfCart: itemsOfCart,
                records: records,
                orderId: event.orderID));
          }

          List<DeliveryModel> deliveryModel = [];

          deliveryModel.add(state.deliveryModels.isNotEmpty
              ? state.deliveryModels.first
              : DeliveryModel(
                  type: "Pick-up",
                  address: "",
                  isSelected: false,
                  price: "0",
                  time: ""));
          for (ShippingMethod shippingMethodsModel
              in shippingModel.shippingMethod ?? []) {
            if (shippingModel.orderDetail!.shippingMethod ==
                shippingMethodsModel.values) {
              deliveryModel.add(DeliveryModel(
                  type: shippingMethodsModel.values,
                  address: shippingMethodsModel.label,
                  isSelected: true,
                  price: "",
                  time: ""));
            } else {
              deliveryModel.add(DeliveryModel(
                  type: shippingMethodsModel.values,
                  address: shippingMethodsModel.label,
                  isSelected: false,
                  price: "",
                  time: ""));
            }
          }

          if (orderDetailModel.isNotEmpty &&
              orderDetailModel[0].items != null &&
              orderDetailModel[0]
                  .items!
                  .where((element) => element.itemId == event.item.itemId)
                  .isNotEmpty) {
            orderDetailModel[0]
                .items!
                .firstWhere((element) => element.itemId == event.item.itemId)
                .isExpanded = false;
          }
          emit(state.copyWith(
              isOverrideSubmitting: false,
              total: orderDetailModel[0].total!,
              subtotal: orderDetailModel[0].subtotal,
              proCoverage: proCoverage,
              overrideDiscount: overrideDiscount,
              deliveryModels: deliveryModel,
              orderDetailModel: orderDetailModel,
              message: "Override Request Submitted",
              selectedOverrideReasons: ""));
        } else {
          if (orderDetailModel.isNotEmpty &&
              orderDetailModel[0].items != null &&
              orderDetailModel[0]
                  .items!
                  .where((element) => element.itemId == event.item.itemId)
                  .isNotEmpty) {
            orderDetailModel[0]
                .items!
                .firstWhere((element) => element.itemId == event.item.itemId)
                .isExpanded = false;
            orderDetailModel[0]
                .items!
                .firstWhere((element) => element.itemId == event.item.itemId)
                .overridePriceApproval = "";
          }
          emit(state.copyWith(
              isOverrideSubmitting: false,
              orderDetailModel: orderDetailModel,
              message: "Override Request Declined",
              selectedOverrideReasons: ""));
        }
      } catch (e) {
        print(e.toString());
        if (orderDetailModel.isNotEmpty &&
            orderDetailModel[0].items != null &&
            orderDetailModel[0]
                .items!
                .where((element) => element.itemId == event.item.itemId)
                .isNotEmpty) {
          orderDetailModel[0]
              .items!
              .firstWhere((element) => element.itemId == event.item.itemId)
              .isExpanded = false;
          orderDetailModel[0]
              .items!
              .firstWhere((element) => element.itemId == event.item.itemId)
              .overridePriceApproval = "";
        }
        emit(state.copyWith(
            isOverrideSubmitting: false,
            orderDetailModel: orderDetailModel,
            message: "Check your network connection",
            selectedOverrideReasons: ""));
      }
      event.onCompleted.call();
    });
    on<SendShippingOverrideReason>((event, emit) async {
      emit(state.copyWith(
        isOverrideSubmitting: true,
      ));
      List<OrderDetail> orderDetailModel = [];
      orderDetailModel = state.orderDetailModel;

      try {
        final responseJson = await cartRepository.sendShippingOverrideReasons(
            event.orderID,
            event.requestedAmount,
            "",
            event.selectedOverrideReasons,
            event.userID);
        log(jsonEncode(responseJson.data));
        SubmitShippingReason submitShippingReason =
            SubmitShippingReason.fromJson(responseJson.data);

        if (submitShippingReason.isSuccess != null &&
            submitShippingReason.isSuccess!) {
          var loggedInUserId =
              await SharedPreferenceService().getValue(loggedInAgentId);

          final getCalculateResp = await cartRepository.getTaxCalculate(
              event.orderID, loggedInUserId);
          TaxCalculateModel shippingModel =
              TaxCalculateModel.fromJson(getCalculateResp);
          // final newResponseJson = await cartRepository.getOrders(event.orderID);
          if (getCalculateResp != null) {
            // CartDetailModel newCartDetail =
            //     CartDetailModel.fromJson(newResponseJson.data);
            TaxCalculateModel shippingModel =
                TaxCalculateModel.fromJson(getCalculateResp);
            if (shippingModel.orderDetail != null) {
              double newProCoverage = 0.0;
              double newOverrideDiscount = 0.0;
              for (int k = 0;
                  k < shippingModel.orderDetail!.items!.length;
                  k++) {
                newProCoverage +=
                    (shippingModel.orderDetail!.items![k].warrantyPrice! *
                        shippingModel.orderDetail!.items![k].quantity!);
                newOverrideDiscount += (shippingModel
                            .orderDetail!.items![k].overridePriceApproval ==
                        "Approved"
                    ? (shippingModel.orderDetail!.items![k].unitPrice! -
                            shippingModel
                                .orderDetail!.items![k].overridePrice!) *
                        shippingModel.orderDetail!.items![k].quantity!
                    : 0.0);
              }
              List<OrderDetail>? orderNew = state.orderDetailModel;
              if (orderNew.isNotEmpty) {
                shippingModel.orderDetail!.items = orderNew.first.items!;
              }
              List<DeliveryModel> deliveryModel = [];
              deliveryModel.add(state.deliveryModels.isNotEmpty
                  ? state.deliveryModels.first
                  : DeliveryModel(
                      type: "Pick-up",
                      address: "",
                      isSelected: false,
                      price: "0",
                      time: ""));
              for (ShippingMethod shippingMethodsModel
                  in shippingModel.shippingMethod ?? []) {
                if (shippingModel.orderDetail!.shippingMethod ==
                    shippingMethodsModel.values) {
                  deliveryModel.add(DeliveryModel(
                      type: shippingMethodsModel.values,
                      address: shippingMethodsModel.label,
                      isSelected: true,
                      price: "",
                      time: ""));
                } else {
                  deliveryModel.add(DeliveryModel(
                      type: shippingMethodsModel.values,
                      address: shippingMethodsModel.label,
                      isSelected: false,
                      price: "",
                      time: ""));
                }
              }

              emit(state.copyWith(
                  total: shippingModel.orderDetail!.total!,
                  subtotal: shippingModel.orderDetail!.subtotal!,
                  isOverrideSubmitting: false,
                  deliveryModels: deliveryModel,
                  proCoverage: newProCoverage,
                  overrideDiscount: newOverrideDiscount,
                  message: "Shipping & Handling Override Request Submitted",
                  selectedOverrideReasons: "",
                  orderDetailModel: [shippingModel.orderDetail!]));
            }
          }
        } else {
          emit(state.copyWith(
              isOverrideSubmitting: false,
              orderDetailModel: orderDetailModel,
              message: "Shipping & Handling Override Request Declined",
              selectedOverrideReasons: ""));
        }
      } catch (e) {
        print(e.toString());
        emit(state.copyWith(
            isOverrideSubmitting: false,
            orderDetailModel: orderDetailModel,
            message: "Check your network connection",
            selectedOverrideReasons: ""));
      }
      event.onCompleted.call();
    });
    on<ResetShippingOverrideReason>((event, emit) async {
      emit(state.copyWith(
        isOverrideSubmitting: true,
        smallLoadingId: event.orderID,
        smallLoading: true,
      ));
      List<OrderDetail> orderDetailModel = [];
      orderDetailModel = state.orderDetailModel;

      try {
        final responseJson = await cartRepository.sendShippingOverrideReasons(
            event.orderID, "0.00", "reset", "", event.userID);
        log(jsonEncode(responseJson.data));
        SubmitShippingReason submitShippingReason =
            SubmitShippingReason.fromJson(responseJson.data);

        if (submitShippingReason.isSuccess != null &&
            submitShippingReason.isSuccess!) {
          var loggedInUserId =
              await SharedPreferenceService().getValue(loggedInAgentId);
          final getCalculateResp = await cartRepository.getTaxCalculate(
              event.orderID, loggedInUserId);
          TaxCalculateModel shippingModel =
              TaxCalculateModel.fromJson(getCalculateResp);
          // final newResponseJson = await cartRepository.getOrders(event.orderID);
          if (getCalculateResp != null) {
            TaxCalculateModel shippingModel =
                TaxCalculateModel.fromJson(getCalculateResp);
            if (shippingModel.orderDetail != null) {
              double newProCoverage = 0.0;
              double newOverrideDiscount = 0.0;
              for (int k = 0;
                  k < shippingModel.orderDetail!.items!.length;
                  k++) {
                newProCoverage +=
                    (shippingModel.orderDetail!.items![k].warrantyPrice! *
                        shippingModel.orderDetail!.items![k].quantity!);
                newOverrideDiscount += (shippingModel
                            .orderDetail!.items![k].overridePriceApproval ==
                        "Approved"
                    ? (shippingModel.orderDetail!.items![k].unitPrice! -
                            shippingModel
                                .orderDetail!.items![k].overridePrice!) *
                        shippingModel.orderDetail!.items![k].quantity!
                    : 0.0);
              }
              List<OrderDetail>? orderNew = state.orderDetailModel;
              if (orderNew.isNotEmpty) {
                shippingModel.orderDetail!.items = orderNew.first.items!;
              }
              List<DeliveryModel> deliveryModel = [];
              deliveryModel.add(state.deliveryModels.isNotEmpty
                  ? state.deliveryModels.first
                  : DeliveryModel(
                      type: "Pick-up",
                      address: "",
                      isSelected: false,
                      price: "0",
                      time: ""));
              for (ShippingMethod shippingMethodsModel
                  in shippingModel.shippingMethod ?? []) {
                if (shippingModel.orderDetail!.shippingMethod ==
                    shippingMethodsModel.values) {
                  deliveryModel.add(DeliveryModel(
                      type: shippingMethodsModel.values,
                      address: shippingMethodsModel.label,
                      isSelected: true,
                      price: "",
                      time: ""));
                } else {
                  deliveryModel.add(DeliveryModel(
                      type: shippingMethodsModel.values,
                      address: shippingMethodsModel.label,
                      isSelected: false,
                      price: "",
                      time: ""));
                }
              }

              emit(state.copyWith(
                  total: shippingModel.orderDetail!.total!,
                  subtotal: shippingModel.orderDetail!.subtotal!,
                  isOverrideSubmitting: false,
                  smallLoadingId: "",
                  smallLoading: false,
                  deliveryModels: deliveryModel,
                  proCoverage: newProCoverage,
                  overrideDiscount: newOverrideDiscount,
                  message: "Shipping & Handling Override Request Deleted",
                  selectedOverrideReasons: "",
                  orderDetailModel: [shippingModel.orderDetail!]));
            }
          }
//          Navigator.pop(event.context);
        } else {
          emit(state.copyWith(
              isOverrideSubmitting: false,
              smallLoadingId: "",
              smallLoading: false,
              orderDetailModel: orderDetailModel,
              message: "Shipping & Handling Delete Request Declined",
              selectedOverrideReasons: ""));
//          Navigator.pop(event.context);
        }
      } catch (e) {
        print(e.toString());
        emit(state.copyWith(
            isOverrideSubmitting: false,
            smallLoadingId: "",
            smallLoading: false,
            orderDetailModel: orderDetailModel,
            message: "Check your network connection",
            selectedOverrideReasons: ""));
        event.onException.call();
      }
    });
    on<ResetOverrideReason>((event, emit) async {
      emit(state.copyWith(
        isOverrideSubmitting: true,
        loadingScreen: true,
      ));
      List<OrderDetail> orderDetailModel = [];
      orderDetailModel = state.orderDetailModel;

      try {
        final responseJson = await cartRepository.sendOverrideReasons(
            event.orderLineItemID,
            event.requestedAmount,
            "reset",
            event.selectedOverrideReasons,
            event.userID);
        log(jsonEncode(responseJson.data));
        SubmitOverrideRequest submitOverrideRequest =
            SubmitOverrideRequest.fromJson(responseJson.data);

        if (submitOverrideRequest.isSuccess != null &&
            submitOverrideRequest.isSuccess!) {
          List<OrderDetail>? orderDetailModel = [];

          var loggedInUserId =
              await SharedPreferenceService().getValue(loggedInAgentId);
          final getCalculateResp = await cartRepository.getTaxCalculate(
              event.orderID, loggedInUserId);
          TaxCalculateModel shippingModel =
              TaxCalculateModel.fromJson(getCalculateResp);
          // final responseCartNew = await cartRepository.getOrders(event.orderID);
          // CartDetailModel cartDetailModelNew =
          //     CartDetailModel.fromJson(responseCartNew.data);
          orderDetailModel.add(shippingModel.orderDetail!);

          double proCoverage = 0.0;
          double overrideDiscount = 0.0;
          if (orderDetailModel.isNotEmpty) {
            for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
              proCoverage = proCoverage +
                  (orderDetailModel[0].items![k].warrantyPrice! *
                      orderDetailModel[0].items![k].quantity!);
              overrideDiscount = overrideDiscount +
                  (orderDetailModel[0]
                          .items![k]
                          .overridePriceApproval!
                          .toLowerCase()
                          .contains("approved")
                      ? (orderDetailModel[0].items![k].unitPrice! -
                              orderDetailModel[0].items![k].overridePrice!) *
                          orderDetailModel[0].items![k].quantity!
                      : 0.0);
            }
            List<ItemsOfCart> itemsOfCart = [];
            List<Records> records = [];
            for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
              itemsOfCart.add(ItemsOfCart(
                  itemQuantity:
                      orderDetailModel[0].items![k].quantity.toString(),
                  itemId: orderDetailModel[0].items![k].itemNumber!,
                  itemName: orderDetailModel[0].items![k].itemDesc!,
                  itemProCoverage:
                      (orderDetailModel[0].items![k].warrantyPrice ?? 0.0)
                          .toString(),
                  itemPrice:
                      orderDetailModel[0].items![k].unitPrice.toString()));
              records.add(Records(
                  productId: orderDetailModel[0].items![k].productId,
                  quantity: orderDetailModel[0].items![k].quantity.toString(),
                  productName: orderDetailModel[0].items![k].itemDesc,
                  oliRecId: orderDetailModel[0].items![k].itemId!,
                  productPrice:
                      orderDetailModel[0].items![k].unitPrice!.toString(),
                  productImageUrl:
                      orderDetailModel[0].items![k].imageUrl.toString(),
                  childskus: [
                    Childskus(
                      skuENTId: orderDetailModel[0].items![k].itemNumber,
                      skuCondition: orderDetailModel[0].items![k].condition,
                      skuPIMId: orderDetailModel[0].items![k].pimSkuId,
                      gcItemNumber: orderDetailModel[0].items![k].posSkuId,
                      pimStatus: orderDetailModel[0].items![k].itemStatus,
                      skuPrice: (orderDetailModel[0].items![k].unitPrice ?? 0)
                          .toString(),
                    )
                  ]));
            }
            event.inventorySearchBloc.add(SetCart(
                itemOfCart: itemsOfCart,
                records: records,
                orderId: event.orderID));
          }

          List<DeliveryModel> deliveryModel = [];

          deliveryModel.add(state.deliveryModels.isNotEmpty
              ? state.deliveryModels.first
              : DeliveryModel(
                  type: "Pick-up",
                  address: "",
                  isSelected: false,
                  price: "0",
                  time: ""));
          for (ShippingMethod shippingMethodsModel
              in shippingModel.shippingMethod ?? []) {
            if (shippingModel.orderDetail!.shippingMethod ==
                shippingMethodsModel.values) {
              deliveryModel.add(DeliveryModel(
                  type: shippingMethodsModel.values,
                  address: shippingMethodsModel.label,
                  isSelected: true,
                  price: "",
                  time: ""));
            } else {
              deliveryModel.add(DeliveryModel(
                  type: shippingMethodsModel.values,
                  address: shippingMethodsModel.label,
                  isSelected: false,
                  price: "",
                  time: ""));
            }
          }

          if (orderDetailModel.isNotEmpty &&
              orderDetailModel[0].items != null &&
              orderDetailModel[0]
                  .items!
                  .where((element) => element.itemId == event.item.itemId)
                  .isNotEmpty) {
            orderDetailModel[0]
                .items!
                .firstWhere((element) => element.itemId == event.item.itemId)
                .isExpanded = false;
          }
          emit(state.copyWith(
              isOverrideSubmitting: false,
              loadingScreen: false,
              total: orderDetailModel.isNotEmpty
                  ? orderDetailModel[0].total
                  : null,
              subtotal: orderDetailModel.isNotEmpty
                  ? orderDetailModel[0].subtotal
                  : null,
              proCoverage: proCoverage,
              overrideDiscount: overrideDiscount,
              deliveryModels: deliveryModel,
              orderDetailModel: orderDetailModel,
              message: "Override Request Deleted",
              selectedOverrideReasons: ""));
        } else {
          if (orderDetailModel.isNotEmpty &&
              orderDetailModel[0].items != null &&
              orderDetailModel[0]
                  .items!
                  .where((element) => element.itemId == event.item.itemId)
                  .isNotEmpty) {
            orderDetailModel[0]
                .items!
                .firstWhere((element) => element.itemId == event.item.itemId)
                .isExpanded = false;
            orderDetailModel[0]
                .items!
                .firstWhere((element) => element.itemId == event.item.itemId)
                .overridePriceApproval = "";
          }
          emit(state.copyWith(
              isOverrideSubmitting: false,
              orderDetailModel: orderDetailModel,
              message: "Delete Request Declined",
              selectedOverrideReasons: ""));
        }
      } catch (e) {
        print(e.toString());
        if (orderDetailModel.isNotEmpty &&
            orderDetailModel[0].items != null &&
            orderDetailModel[0]
                .items!
                .where((element) => element.itemId == event.item.itemId)
                .isNotEmpty) {
          orderDetailModel[0]
              .items!
              .firstWhere((element) => element.itemId == event.item.itemId)
              .isExpanded = false;
          orderDetailModel[0]
              .items!
              .firstWhere((element) => element.itemId == event.item.itemId)
              .overridePriceApproval = "";
        }
        emit(state.copyWith(
            isOverrideSubmitting: false,
            loadingScreen: false,
            orderDetailModel: orderDetailModel,
            message: "Check your network connection",
            selectedOverrideReasons: ""));
      }
    });
    on<RefreshShippingOverrideReason>((event, emit) async {
      emit(state.copyWith(
          isOverrideSubmitting: true,
          smallLoadingId: event.orderID,
          smallLoading: true));
      List<OrderDetail> orderDetailModel = [];
      orderDetailModel = state.orderDetailModel;

      try {
        // final responseJson = await cartRepository.sendShippingOverrideReasons(
        //     event.orderID, "0.00", "reset", "", event.userID);
        // log(jsonEncode(responseJson.data));
        // SubmitShippingReason submitShippingReason =
        //     SubmitShippingReason.fromJson(responseJson.data);

        // if (submitShippingReason.isSuccess != null &&
        //     submitShippingReason.isSuccess!) {
        var loggedInUserId =
            await SharedPreferenceService().getValue(loggedInAgentId);
        final getCalculateResp =
            await cartRepository.getTaxCalculate(event.orderID, loggedInUserId);
        // final newResponseJson = await cartRepository.getOrders(event.orderID);
        if (getCalculateResp != null) {
          TaxCalculateModel shippingModel =
              TaxCalculateModel.fromJson(getCalculateResp);
          if (shippingModel.orderDetail != null) {
            double newProCoverage = 0.0;
            double newOverrideDiscount = 0.0;
            for (int k = 0; k < shippingModel.orderDetail!.items!.length; k++) {
              newProCoverage +=
                  (shippingModel.orderDetail!.items![k].warrantyPrice! *
                      shippingModel.orderDetail!.items![k].quantity!);
              newOverrideDiscount += (shippingModel
                          .orderDetail!.items![k].overridePriceApproval ==
                      "Approved"
                  ? (shippingModel.orderDetail!.items![k].unitPrice! -
                          shippingModel.orderDetail!.items![k].overridePrice!) *
                      shippingModel.orderDetail!.items![k].quantity!
                  : 0.0);
            }
            List<OrderDetail>? orderNew = state.orderDetailModel;
            if (orderNew.isNotEmpty) {
              shippingModel.orderDetail!.items = orderNew.first.items!;
            }
            List<DeliveryModel> deliveryModel = [];
            deliveryModel.add(state.deliveryModels.isNotEmpty
                ? state.deliveryModels.first
                : DeliveryModel(
                    type: "Pick-up",
                    address: "",
                    isSelected: false,
                    price: "0",
                    time: ""));
            for (ShippingMethod shippingMethodsModel
                in shippingModel.shippingMethod ?? []) {
              if (shippingModel.orderDetail!.shippingMethod ==
                  shippingMethodsModel.values) {
                deliveryModel.add(DeliveryModel(
                    type: shippingMethodsModel.values,
                    address: shippingMethodsModel.label,
                    isSelected: true,
                    price: "",
                    time: ""));
              } else {
                deliveryModel.add(DeliveryModel(
                    type: shippingMethodsModel.values,
                    address: shippingMethodsModel.label,
                    isSelected: false,
                    price: "",
                    time: ""));
              }
            }

            emit(state.copyWith(
                total: shippingModel.orderDetail!.total!,
                subtotal: shippingModel.orderDetail!.subtotal,
                isOverrideSubmitting: false,
                smallLoadingId: "",
                smallLoading: false,
                deliveryModels: deliveryModel,
                proCoverage: newProCoverage,
                overrideDiscount: newOverrideDiscount,
                message: "",
                selectedOverrideReasons: "",
                orderDetailModel: [shippingModel.orderDetail!]));
          }
        }
//          Navigator.pop(event.context);
//         } else {
//           emit(state.copyWith(
//               isOverrideSubmitting: false,
//               orderDetailModel: orderDetailModel,
//               message: "Shipping & Handling Delete Request Declined",
//               selectedOverrideReasons: ""));
// //          Navigator.pop(event.context);
//         }
      } catch (e) {
        print(e.toString());
        emit(state.copyWith(
            isOverrideSubmitting: false,
            smallLoadingId: "",
            smallLoading: false,
            orderDetailModel: orderDetailModel,
            message: "Check your network connection",
            selectedOverrideReasons: ""));
        event.onException.call();
      }
    });
    on<AddCoupon>((event, emit) async {
      List<OrderDetail> orderDetailModel = [];
      orderDetailModel = [...state.orderDetailModel];

      try {
        emit(state.copyWith(isOverrideSubmitting: true));
        final responseJson =
            await cartRepository.applyCoupon(event.orderId, event.couponId);

        bool isSuccess = responseJson['isSuccess'] == true;

        if (isSuccess) {
          var loggedInId =
              await SharedPreferenceService().getValue(loggedInAgentId);
          final getCalculateResp =
              await cartRepository.getTaxCalculate(event.orderId, loggedInId);
          TaxCalculateModel shippingModel =
              TaxCalculateModel.fromJson(getCalculateResp);

          //Do getTaxCalculate to trigger backend update the discount
          List<DiscountModel> discountModels = [];
          if ((getCalculateResp["promoCode"] ?? []).isNotEmpty &&
              getCalculateResp["discountParam"] != null &&
              getCalculateResp["discountParam"].isNotEmpty) {
            discountModels = getCalculateResp["discountParam"]
                .map<DiscountModel>((e) => DiscountModel.fromJson(e))
                .toList();
          } else {
            emit(state.copyWith(
                isOverrideSubmitting: false,
                orderDetailModel: [shippingModel.orderDetail!],
                message: "Invalid\nCoupon code.",
                isCouponSubmitDone: true,
                selectedOverrideReasons: ""));
            emit(state.copyWith(isCouponSubmitDone: false));
            return;
          }
          orderDetailModel.clear();
          orderDetailModel.add(shippingModel.orderDetail!);
          // final cartResponse = await cartRepository.getOrders(event.orderId);
          // CartDetailModel cartDetailModel =
          //     CartDetailModel.fromJson(cartResponse.data);

          double subtotal = 0.0;
          double proCoverage = 0.0;
          double overrideDiscount = 0.0;
          if (orderDetailModel.isNotEmpty) {
            for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
              subtotal = subtotal +
                  ((orderDetailModel[0].items![k].unitPrice!) *
                      orderDetailModel[0].items![k].quantity!);
              proCoverage = proCoverage +
                  (orderDetailModel[0].items![k].warrantyPrice! *
                      orderDetailModel[0].items![k].quantity!);
              overrideDiscount = overrideDiscount +
                  (orderDetailModel[0].items![k].overridePriceApproval ==
                          "Approved"
                      ? (orderDetailModel[0].items![k].unitPrice! -
                              orderDetailModel[0].items![k].overridePrice!) *
                          orderDetailModel[0].items![k].quantity!
                      : 0.0);
            }
          }
          emit(state.copyWith(
              isOverrideSubmitting: false,
              isCouponSubmitDone: true,
              orderDetailModel: orderDetailModel,
              total: orderDetailModel.first.total!,
              subtotal: subtotal,
              deleteDone: false,
              proCoverage: proCoverage,
              overrideDiscount: overrideDiscount,
              message: "Coupon Applied\nSuccessfully",
              selectedOverrideReasons: "",
              appliedCouponDiscount: discountModels));
          emit(state.copyWith(isCouponSubmitDone: false));
        }
        emit(state.copyWith(isOverrideSubmitting: false));
      } catch (e) {
        print(e.toString());

        emit(state.copyWith(
            isOverrideSubmitting: false,
            // isCouponSubmitDone: true,
            orderDetailModel: orderDetailModel,
            message: "Can not apply your coupon.",
            selectedOverrideReasons: ""));
      }
    });
    on<RemoveCoupon>((event, emit) async {
      List<OrderDetail> orderDetailModel = [];
      orderDetailModel = [...state.orderDetailModel];

      try {
        emit(state.copyWith(isOverrideSubmitting: true));
        final responseJson = await cartRepository.removeCoupon(event.orderId);
        bool isSuccess = responseJson['isSuccess'] == true;

        if (isSuccess) {
          var loggedInId =
              await SharedPreferenceService().getValue(loggedInAgentId);
          final getCalculateResp =
              await cartRepository.getTaxCalculate(event.orderId, loggedInId);
          TaxCalculateModel shippingModel =
              TaxCalculateModel.fromJson(getCalculateResp);
          List<DiscountModel> discountModels = [];
          if (getCalculateResp["discountParam"] != null &&
              getCalculateResp["discountParam"].isNotEmpty) {
            discountModels = getCalculateResp["discountParam"]
                .map<DiscountModel>((e) => DiscountModel.fromJson(e))
                .toList();
          }
          // final cartResponse = await cartRepository.getOrders(event.orderId);
          // CartDetailModel cartDetailModel =
          //     CartDetailModel.fromJson(cartResponse.data);
          orderDetailModel.clear();
          if (shippingModel.orderDetail != null) {
            orderDetailModel.add(shippingModel.orderDetail!);
          }
          double subtotal = 0.0;
          double proCoverage = 0.0;
          double overrideDiscount = 0.0;
          if (orderDetailModel.isNotEmpty) {
            for (int k = 0; k < orderDetailModel[0].items!.length; k++) {
              subtotal = subtotal +
                  ((orderDetailModel[0].items![k].unitPrice!) *
                      orderDetailModel[0].items![k].quantity!);
              proCoverage = proCoverage +
                  (orderDetailModel[0].items![k].warrantyPrice! *
                      orderDetailModel[0].items![k].quantity!);
              overrideDiscount = overrideDiscount +
                  (orderDetailModel[0].items![k].overridePriceApproval ==
                          "Approved"
                      ? (orderDetailModel[0].items![k].unitPrice! -
                              orderDetailModel[0].items![k].overridePrice!) *
                          orderDetailModel[0].items![k].quantity!
                      : 0.0);
            }
          }

          emit(state.copyWith(
              isOverrideSubmitting: false,
              orderDetailModel: orderDetailModel,
              total: orderDetailModel.first.total!,
              subtotal: subtotal,
              proCoverage: proCoverage,
              overrideDiscount: overrideDiscount,
              message: "Coupon removed successfully",
              selectedOverrideReasons: ""));
        }
        emit(state.copyWith(isOverrideSubmitting: false));
      } catch (e) {
        print(e.toString());

        emit(state.copyWith(
            isOverrideSubmitting: false,
            orderDetailModel: orderDetailModel,
            message: "Can not apply your coupon.",
            selectedOverrideReasons: ""));
      }
    });
    on<NotifyContactIsMissing>((event, emit) {
      emit(state.copyWith(isContactMissing: true));
      emit(state.copyWith(isContactMissing: false));
    });
  }
  Future<cim.CustomerInfoModel> getCustomerInfo(String id) async {
    print("this is agent id $id");

    cim.CustomerInfoModel response = await landingScreenRepository.getCustomerInfoById(id);

      if (response.records!.isNotEmpty) {
        if (response.records![0].id != null) {
          SharedPreferenceService().setKey(key: agentId, value: response.records![0].id!);
        }
        if (response.records![0].accountEmailC != null) {
          SharedPreferenceService().setKey(key: agentEmail, value: response.records![0].accountEmailC!);
        } else if (response.records![0].emailC != null) {
          SharedPreferenceService().setKey(key: agentEmail, value: response.records![0].emailC!);
        } else if (response.records![0].personEmail != null) {
          SharedPreferenceService().setKey(key: agentEmail, value: response.records![0].personEmail!);
        }
        if (response.records![0].name != null) {
          SharedPreferenceService().setKey(key: savedAgentName, value: response.records![0].name!);
        }
        if (response.records![0].accountEmailC != null) {
          SharedPreferenceService().setKey(key: agentEmail, value: response.records![0].accountEmailC!);
        } else if (response.records![0].emailC != null) {
          SharedPreferenceService().setKey(key: agentEmail, value: response.records![0].emailC!);
        } else if (response.records![0].personEmail != null) {
          SharedPreferenceService().setKey(key: agentEmail, value: response.records![0].personEmail!);
        }
        return response;
      }
      else {
      return cim.CustomerInfoModel(records: [cim.Records(id: null)], done: false);
    }
  }

  Future<Records> getProductDetail(String skuId) async {
    var id = await SharedPreferenceService().getValue(agentId);
    final response =
        await favouriteBrandScreenRepository.getProductDetail(id, skuId);
    return response;
  }

  Future<QuoteSubmitModel> quoteSubmit(String email, String phone,
      String expirationDate, String orderId, String subTotal) async {
    var id = await SharedPreferenceService().getValue(agentId);
    var loggedInId = await SharedPreferenceService().getValue(loggedInAgentId);
    final response = await cartRepository.submitQuote(
        email, phone, expirationDate, orderId, id, subTotal, loggedInId);
    return response;
  }
}
