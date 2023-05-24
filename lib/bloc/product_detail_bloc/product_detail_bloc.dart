import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/inventory_search_bloc/inventory_search_bloc.dart';
import 'package:gc_customer_app/data/data_sources/cart_data_source/cart_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/cart_reporsitory/cart_repository.dart';
import 'package:gc_customer_app/data/reporsitories/product_detail_reporsitory/product_detail_repository.dart';
import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';
import 'package:gc_customer_app/models/cart_model/product_eligibility_model.dart'
    as pem;
import 'package:gc_customer_app/models/inventory_search/create_cart_model.dart';
import 'package:gc_customer_app/models/inventory_search/update_cart_model.dart';
import 'package:gc_customer_app/models/product_detail_model/bundle_model.dart';
import 'package:gc_customer_app/models/product_detail_model/color_model.dart';
import 'package:gc_customer_app/models/product_detail_model/coverage_model.dart';
import 'package:gc_customer_app/models/product_detail_model/get_zip_code_list.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

import '../../models/cart_model/tax_model.dart';
import '../../models/common_models/child_sku_model.dart';
import '../../models/common_models/records_class_model.dart';
import '../../models/inventory_search/add_search_model.dart';
import '../../models/inventory_search/cart_model.dart';

part 'product_detail_state.dart';
part 'product_detail_event.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailRepository productDetailRepository;
  CartRepository cartRepository =
      CartRepository(cartDataSource: CartDataSource());

  ProductDetailBloc({required this.productDetailRepository})
      : super(ProductDetailState()) {
    on<PageLoad>((event, emit) async {
      emit(state.copyWith(productDetailStatus: ProductDetailStatus.loadState));
      Records records = await getProductDetail(event.skuENTId);
      List<GetZipCodeList> getZipCodeList = [];
      String oliId = event.orderLineItemId;
      String orderId = event.orderId;
      List<GetZipCodeList> getZipCodeListSearch = [];
      List<WarrantiesModel> proCoverageModel = [];
      List<String> images = [];
      List<ColorModel> colors = [];
      List<CoverageModel> proCoverage = [];
      if (records.childskus!.isEmpty) {
        emit(state.copyWith(
            productsInCart: event.productsInCart,
            records: [],
            productDetailStatus: ProductDetailStatus.successState,
            isInStoreLoading: false));
      }
      else {
        colors.add(ColorModel(color: Colors.pink, name: "Pink"));
        colors.add(ColorModel(color: Colors.green, name: "Green"));
        colors.add(ColorModel(color: Colors.yellow, name: "Yellow"));
        colors.add(ColorModel(color: Colors.purple, name: "Purple"));
        colors.add(ColorModel(color: Colors.blue, name: "Blue"));
        colors.add(ColorModel(color: Colors.pink, name: "Pink"));
        colors.add(ColorModel(color: Colors.orange, name: "Orange"));

        // try {
        for (Childskus p in records.childskus!) {
          images.add(p.skuImageUrl!);
        }

        final responseJson = await productDetailRepository
            .getAddress(records.childskus!.first.skuENTId!);

        WarrantiesModel responseJsonShowProCoverageModel =
            await productDetailRepository.showProCoverageModel(
                records.childskus!.first.skuPIMId != null &&
                        records.childskus!.first.skuPIMId!.isNotEmpty
                    ? records.childskus!.first.skuPIMId!
                    : records.childskus!.first.skuENTId!);
        log("event.warrantyId ${event.warrantyId}");
        log("responseJsonShowProCoverageModel ${responseJsonShowProCoverageModel.warranties!.length}");
        proCoverageModel.add(responseJsonShowProCoverageModel);
        getZipCodeList.add(GetZipCodeList.fromJson(responseJson.data));
        getZipCodeListSearch.add(GetZipCodeList(mainNodeData: [], otherNodeData: []));
        List<ItemsOfCart> itemsOfCart = [];
        List<Records> recordsCart = [];

        if (proCoverageModel.isNotEmpty &&
            proCoverageModel.first.warranties != null &&
            proCoverageModel.first.warranties!.isNotEmpty) {
          if(event.warrantyId.isNotEmpty){
            records.warranties = proCoverageModel.first.warranties!.firstWhere((element) => element.id == event.warrantyId);
          }
        }

        if(event.inventorySearchBloc.state.orderId.isNotEmpty){
          var loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);final getCalculateResp = await cartRepository.getTaxCalculate(event.inventorySearchBloc.state.orderId, loggedInUserId);
          TaxCalculateModel shippingModel = TaxCalculateModel.fromJson(getCalculateResp);
          if(shippingModel.orderDetail != null){
            if(shippingModel.orderDetail!.items != null){
              if(shippingModel.orderDetail!.items!.isNotEmpty){
                if(shippingModel.orderDetail!.items!.where((element) => element.itemNumber == records.childskus!.first.skuENTId).isNotEmpty){
                  if(shippingModel.orderDetail!.items!.firstWhere((element) => element.itemNumber == records.childskus!.first.skuENTId).warrantyId!.isNotEmpty){
                    print("shippingModel.orderDetail!.items!.firstWhere((element) => element.itemId == records.childskus!.first.skuENTId).warrantyId! ${shippingModel.orderDetail!.items!.firstWhere((element) => element.itemNumber == records.childskus!.first.skuENTId).warrantyId!}");
                    records.warranties = proCoverageModel.first.warranties!.firstWhere((element) => element.id == shippingModel.orderDetail!.items!.firstWhere((element) => element.itemNumber == records.childskus!.first.skuENTId).warrantyId!);
                  }
                  oliId = shippingModel.orderDetail!.items!.firstWhere((element) => element.itemNumber == records.childskus!.first.skuENTId).itemId??"";
                }

                for (int k = 0; k < shippingModel.orderDetail!.items!.length; k++) {
                  itemsOfCart.add(ItemsOfCart(
                      itemQuantity: shippingModel.orderDetail!.items![k].quantity.toString(),
                      itemId: shippingModel.orderDetail!.items![k].itemNumber!,
                      itemName: shippingModel.orderDetail!.items![k].itemDesc!,
                      itemPrice: shippingModel.orderDetail!.items![k].unitPrice.toString(),
                      itemProCoverage: (shippingModel.orderDetail!.items![k].warrantyPrice ?? 0.0).toString()));
                  recordsCart.add(Records(
                      productId: shippingModel.orderDetail!.items![k].productId,
                      quantity: shippingModel.orderDetail!.items![k].quantity.toString(),
                      productName: shippingModel.orderDetail!.items![k].itemDesc,
                      oliRecId: shippingModel.orderDetail!.items![k].itemId!,
                      productPrice:
                      shippingModel.orderDetail!.items![k].unitPrice!.toString(),
                      productImageUrl:
                      shippingModel.orderDetail!.items![k].imageUrl.toString(),
                      childskus: [
                        Childskus(
                          skuENTId: shippingModel.orderDetail!.items![k].itemNumber,
                          skuPrice: (shippingModel.orderDetail!.items![k].unitPrice ?? 0).toString(),
                          skuCondition: shippingModel.orderDetail!.items![k].condition,
                          skuPIMId: shippingModel.orderDetail!.items![k].pimSkuId,
                          gcItemNumber: shippingModel.orderDetail!.items![k].posSkuId,
                          pimStatus: shippingModel.orderDetail!.items![k].itemStatus,
                        )
                      ]));
                }

              }
            }
          }
          orderId = event.inventorySearchBloc.state.orderId;
        }
        itemsOfCart = LinkedHashSet<ItemsOfCart>.from(itemsOfCart).toList();

        event.inventorySearchBloc.add(SetCart(
            itemOfCart: itemsOfCart,
            records: recordsCart,
            orderId: event.inventorySearchBloc.state.orderId.isNotEmpty?event.inventorySearchBloc.state.orderId:event.orderId));

        print("oli_id => ${oliId}");
        emit(state.copyWith(
            getZipCodeList: getZipCodeList,
            colors: colors,
            orderId: orderId,
            loadingBundles: true,
            fetchEligibility: true,
            currentColor: [colors[0]],
            productDetailStatus: ProductDetailStatus.successState,
            productsInCart: recordsCart,
            records: [records],
            images: images,
            orderLineItemId: oliId,
            proCoverage: proCoverage,
            currentImage: images[0],
            currentCondition: records.childskus![0].skuCondition!,
            proCoverageModel: proCoverageModel,
            currentProCoverage: records.warranties!.id != null &&
                    records.warranties!.id!.isNotEmpty
                ? [records.warranties!]
                : [],
            getZipCodeListSearch: getZipCodeListSearch,
            isInStoreLoading: false));
        ProductDetailBundlesModel productDetailBundlesModel =
            await productDetailRepository
                .getProductBundle(records.childskus!.first.skuENTId!);
        emit(state.copyWith(
            loadingBundles: false,
            productRecommands: productDetailBundlesModel.productRecommands));
        emit(state
            .copyWith(moreInfo: [], mainNodeData: [], fetchEligibility: true));
        var id = await SharedPreferenceService().getValue(loggedInAgentId);
        final elegResponseJson = await productDetailRepository
            .getItemEligibility(records.childskus!.first.skuENTId!, id);
        emit(state.copyWith(
            moreInfo: elegResponseJson.moreInfo ?? [],
            mainNodeData: elegResponseJson.mainNodeData ?? [],
            fetchEligibility: false));
      }
    });
    on<ClearMessage>((event, emit) {
      emit(state.copyWith(message: ""));
    });

    on<GetProductDetail>((event, emit) async {
      List<ProductRecommands> list = state.productRecommands;
      list.first.recommendedProductSet![event.index!].records!.isUpdating =
          true;
      emit(state.copyWith(productRecommands: list, message: "done"));

      Records product = await getProductDetail(event.id);
      if (product.childskus != null && product.childskus!.isNotEmpty) {
        list.first.recommendedProductSet![event.index!].records!.records =
            product;
        event.inventorySearchBloc.add(GetWarranties(
            records: event.state.productsInCart
                    .where((element) =>
                        element.childskus!.first.skuENTId ==
                        product.childskus!.first.skuENTId!)
                    .isNotEmpty
                ? event.state.productsInCart.firstWhere((element) =>
                    element.childskus!.first.skuENTId ==
                    product.childskus!.first.skuENTId!)
                : product,
            skuEntId: product.childskus!.first.skuPIMId ?? "",
            productId: event.id));

        list.first.recommendedProductSet![event.index!].records!.isUpdating =
            false;
        emit(state.copyWith(productRecommands: list, message: "done"));
      } else {
        list.first.recommendedProductSet![event.index!].records!.isUpdating =
            false;

        emit(state.copyWith(
            productRecommands: list, message: "Product detail not found"));
      }
    });
    on<SetCurrentImage>((event, emit) {
      emit(state.copyWith(currentImage: event.image));
    });

    on<SetExpandBundle>((event, emit) {
      emit(state.copyWith(expandBundle: event.expandBundle));
    });

    on<SetExpandColor>((event, emit) {
      emit(state.copyWith(expandColor: event.expandColor));
    });

    on<SetExpandCoverage>((event, emit) {
      emit(state.copyWith(expandCoverage: event.expandCoverage));
    });
    on<SetExpandEligibility>((event, emit) {
      emit(state.copyWith(expandEligibility: event.value));
    });

    on<SetCurrentCoverage>((event, emit) async {
      List<Records> records = state.records;
      List<WarrantiesModel> warrantiesModel = state.proCoverageModel;
      if (warrantiesModel.isNotEmpty) {
        warrantiesModel.first.warranties!.firstWhere((element) => element.id == event.currentCoverage.id!).isLoading = true;
        emit(state.copyWith(proCoverageModel: warrantiesModel,message: "done"));

        records.first.warranties = warrantiesModel.first.warranties!.firstWhere((element) => element.id == event.currentCoverage.id!);
        emit(state.copyWith(records: records, currentProCoverage: [event.currentCoverage]));
        if (event.orderLineItemID.isNotEmpty) {
          if (event.styleDescription1.isNotEmpty) {
            await cartRepository.updateWarranties(event.currentCoverage, event.orderLineItemID);
          } else {
            await cartRepository.removeWarranties(event.currentCoverage, event.orderLineItemID);
          }

          List<ItemsOfCart> itemsOfCart = [];
          List<Records> recordCart = state.productsInCart;
          if (recordCart.where((element) =>
          element.childskus!.first.skuENTId! == records.first.childskus!.first.skuENTId!).isNotEmpty) {
            recordCart.firstWhere((element) =>
            element.childskus!.first.skuENTId! == records.first.childskus!.first.skuENTId!).warranties =
            warrantiesModel.first.warranties!.firstWhere((element) => element.id == event.currentCoverage.id!);

            emit(state.copyWith(productsInCart: recordCart));

            List<ItemsOfCart> itemsOfCart = [];
            for (int k = 0; k < recordCart.length; k++) {

              itemsOfCart.add(ItemsOfCart(
                  itemQuantity: recordCart[k].quantity.toString(),
                  itemId: recordCart[k].childskus!.first.skuENTId.toString(),
                  itemName: recordCart[k].productName!,
                  itemProCoverage: (recordCart[k].warranties!.price ?? 0.0).toString(),
                  itemPrice: recordCart[k].childskus!.first.skuPrice ?? "0"));
            }
            itemsOfCart = LinkedHashSet<ItemsOfCart>.from(itemsOfCart).toList();
            for (int k = 0; k < itemsOfCart.length; k++) {
              log(jsonEncode(itemsOfCart[k].toJson()));
            }
            for (int k = 0; k < recordCart.length; k++) {
              log(jsonEncode(recordCart[k].toJson()));
            }
            event.inventorySearchBloc.add(SetCart(
                itemOfCart: itemsOfCart,
                records: recordCart,
                orderId: event.inventorySearchBloc.state.orderId));
          }

/*
          var loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);
          final getCalculateResp = await cartRepository.getTaxCalculate(event.orderID, loggedInUserId);
          TaxCalculateModel shippingModel = TaxCalculateModel.fromJson(getCalculateResp);
          if(shippingModel.orderDetail != null){
            if(shippingModel.orderDetail!.items != null){
              if(shippingModel.orderDetail!.items!.isNotEmpty){
                for (int k = 0; k < shippingModel.orderDetail!.items!.length; k++) {
                  itemsOfCart.add(ItemsOfCart(
                      itemQuantity: shippingModel.orderDetail!.items![k].quantity.toString(),
                      itemId: shippingModel.orderDetail!.items![k].itemNumber!,
                      itemName: shippingModel.orderDetail!.items![k].itemDesc!,
                      itemPrice: shippingModel.orderDetail!.items![k].unitPrice.toString(),
                      itemProCoverage: (shippingModel.orderDetail!.items![k].warrantyPrice ?? 0.0).toString()));
                  recordCart.add(Records(
                      productId: shippingModel.orderDetail!.items![k].productId,
                      quantity: shippingModel.orderDetail!.items![k].quantity.toString(),
                      productName: shippingModel.orderDetail!.items![k].itemDesc,
                      oliRecId: shippingModel.orderDetail!.items![k].itemId!,
                      productPrice:
                      shippingModel.orderDetail!.items![k].unitPrice!.toString(),
                      productImageUrl:
                      shippingModel.orderDetail!.items![k].imageUrl.toString(),
                      childskus: [
                        Childskus(
                          skuENTId: shippingModel.orderDetail!.items![k].itemNumber,
                          skuPrice: (shippingModel.orderDetail!.items![k].unitPrice ?? 0).toString(),
                          skuCondition: shippingModel.orderDetail!.items![k].condition,
                          skuPIMId: shippingModel.orderDetail!.items![k].pimSkuId,
                          gcItemNumber: shippingModel.orderDetail!.items![k].posSkuId,
                          pimStatus: shippingModel.orderDetail!.items![k].itemStatus,
                        )
                      ]));
                }
              }
            }
          }
          itemsOfCart = LinkedHashSet<ItemsOfCart>.from(itemsOfCart).toList();

          event.inventorySearchBloc.add(SetCart(
              itemOfCart: itemsOfCart,
              records: recordCart,
              orderId: event.orderID));
*/
        }
        else{
          String oliId = "";
          List<Records> records = state.records;
          List<Records> recordCart = event.inventorySearchBloc.state.productsInCart;
          if(recordCart.where((element) => element.childskus!.first.skuENTId!  == records.first.childskus!.first.skuENTId!).isNotEmpty){
            var loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);
            final getCalculateResp = await cartRepository.getTaxCalculate(event.inventorySearchBloc.state.orderId, loggedInUserId);
            TaxCalculateModel shippingModel = TaxCalculateModel.fromJson(getCalculateResp);
            if(shippingModel.orderDetail != null){
              if(shippingModel.orderDetail!.items != null){
                if(shippingModel.orderDetail!.items!.isNotEmpty){
                  if(shippingModel.orderDetail!.items!.where((element) => element.itemNumber == records.first.childskus!.first.skuENTId).isNotEmpty){
                    oliId = shippingModel.orderDetail!.items!.firstWhere((element) => element.itemNumber == records.first.childskus!.first.skuENTId).itemId??"";
                  }
                }
              }
            }
          }

          if(oliId.isNotEmpty){
            emit(state.copyWith(orderLineItemId: oliId,productsInCart: records));
            if (event.styleDescription1.isNotEmpty) {
              await cartRepository.updateWarranties(event.currentCoverage, oliId);
            } else {
              await cartRepository.removeWarranties(event.currentCoverage, oliId);
            }

            List<ItemsOfCart> itemsOfCart = [];
            List<Records> recordCart = state.productsInCart;
            if (recordCart.where((element) =>
            element.childskus!.first.skuENTId! == records.first.childskus!.first.skuENTId!).isNotEmpty) {
              recordCart.firstWhere((element) =>
              element.childskus!.first.skuENTId! == records.first.childskus!.first.skuENTId!).warranties =
                  warrantiesModel.first.warranties!.firstWhere((element) => element.id == event.currentCoverage.id!);

              emit(state.copyWith(productsInCart: recordCart));

              List<ItemsOfCart> itemsOfCart = [];
              for (int k = 0; k < recordCart.length; k++) {

                itemsOfCart.add(ItemsOfCart(
                    itemQuantity: recordCart[k].quantity.toString(),
                    itemId: recordCart[k].childskus!.first.skuENTId.toString(),
                    itemName: recordCart[k].productName!,
                    itemProCoverage: (recordCart[k].warranties!.price ?? 0.0).toString(),
                    itemPrice: recordCart[k].childskus!.first.skuPrice ?? "0"));
              }
              itemsOfCart = LinkedHashSet<ItemsOfCart>.from(itemsOfCart).toList();
              for (int k = 0; k < itemsOfCart.length; k++) {
                log(jsonEncode(itemsOfCart[k].toJson()));
              }
              for (int k = 0; k < recordCart.length; k++) {
                log(jsonEncode(recordCart[k].toJson()));
              }
              event.inventorySearchBloc.add(SetCart(
                  itemOfCart: itemsOfCart,
                  records: recordCart,
                  orderId: event.inventorySearchBloc.state.orderId));
            }
          }
          else{
            print("orderLineItemID is empty ${recordCart.length}");
          }
        }
        warrantiesModel.first.warranties!.firstWhere((element) => element.id == event.currentCoverage.id!).isLoading = false;
        emit(state.copyWith(proCoverageModel: warrantiesModel,message: "done"));
      }
      else{
        print("warrantiesModel is empty");
      }
    });
    on<SetCurrentColor>((event, emit) {
      emit(state.copyWith(currentColor: [event.currentColor]));
    });


    on<UpdateBottomCartWithItems>((event, emit) async {
      List<Items> orderDetailModel = [];
      List<Records> orderRecords = event.records;
      orderDetailModel = event.items;
      print("working..");
      for (Records p in orderRecords) {
        print("element.itemId ${p.oliRecId}");

        if (orderDetailModel
            .where((element) => element.itemId == p.oliRecId)
            .isNotEmpty) {
          p.quantity = orderDetailModel
              .firstWhere((element) => element.itemId == p.oliRecId)
              .quantity!
              .toInt()
              .toString();
        }
      }

      emit(state.copyWith(
        productsInCart: orderRecords,
      ));
    });

    on<UpdateBottomCart>((event, emit) async {
      emit(state.copyWith(productsInCart: event.items));
    });


    on<GetAddressProduct>((event, emit) async {
      emit(state.copyWith(productDetailStatus: ProductDetailStatus.loadState));
      List<GetZipCodeList> getZipCodeList = [];
      final responseJson =
          await productDetailRepository.getAddress(event.skuENTId);
      getZipCodeList.add(GetZipCodeList.fromJson(responseJson.data));
      getZipCodeList.first.otherStores?.sort(
        (a, b) => (a.storeC ?? '').compareTo(b.storeC ?? ''),
      );
      emit(state.copyWith(
        productDetailStatus: ProductDetailStatus.successState,
        getZipCodeList: getZipCodeList,
        getZipCodeListSearch: getZipCodeList,
      ));
    });

    on<SearchAddressProduct>((event, emit) async {
      if (event.searchName.isEmpty) {
        emit(state.copyWith(getZipCodeListSearch: state.getZipCodeList));
        return;
      }
      List<GetZipCodeList> getZipCodeListSearch = [
        GetZipCodeList(otherStores: [])
      ];
      state.getZipCodeList.first.otherStores?.forEach((os) {
        bool isContainName = os.storeDescriptionC
                ?.toLowerCase()
                .contains(event.searchName.toLowerCase()) ??
            false;
        bool isContainStockLevel = state.getZipCodeList.first.otherNodeData
                ?.firstWhere(
                  (ond) => ond.nodeID == os.storeC,
                  orElse: () => OtherNodeData(stockLevel: ''),
                )
                .stockLevel
                ?.contains(event.searchName) ??
            false;
        if (isContainName || isContainStockLevel) {
          getZipCodeListSearch.first.otherStores!.add(os);
        }
      });
      emit(state.copyWith(
        productDetailStatus: ProductDetailStatus.successState,
        getZipCodeListSearch: getZipCodeListSearch,
      ));
    });
  }

  Future<Records> getProductDetail(String skuId) async {
    var id = await SharedPreferenceService().getValue(agentId);
    final response = await productDetailRepository.getProductDetail(id, skuId);
    return response;
  }

  Future selectInventoryReason(String orderId, String nodeId, int stockLevel,
      String sourcingReason) async {
    final response = await productDetailRepository.selectInventoryReason(
        orderId, nodeId, stockLevel, sourcingReason);
  }
}
