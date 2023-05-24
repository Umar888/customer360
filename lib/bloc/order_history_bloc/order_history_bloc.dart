import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gc_customer_app/data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'package:gc_customer_app/data/reporsitories/order_history_screen_repository/order_history_repository.dart';
import 'package:gc_customer_app/data/reporsitories/order_lookup_repository/order_lookup_repository.dart';
import 'package:gc_customer_app/models/cart_model/cart_detail_model.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_item_availability.dart';
import 'package:gc_customer_app/models/order_history/customer_order_info_model.dart';
import 'package:gc_customer_app/models/order_history/open_order_model.dart';
import 'package:gc_customer_app/models/order_history/order_accessories_model.dart'
    as oam;
import 'package:gc_customer_app/models/order_history/order_history_model.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

import '../../primitives/constants.dart';

part 'order_history_event.dart';
part 'order_history_state.dart';

class OrderHistoryBloc extends Bloc<OrderHistoryEvent, OrderHistoryState> {
  OrderHistoryRepository orderHistoryRepository;
  LandingScreenRepository landingScreenRepository;
  OrderLookUpRepository orderLookUpRepository = OrderLookUpRepository();

  OrderHistoryBloc(
      {required this.orderHistoryRepository,
      required this.landingScreenRepository})
      : super(OrderHistoryState()) {
    on<EmptyMessage>((event, emit) async {
      emit(state.copyWith(
        message: "",
      ));
    });

    on<GetOpenOrders>((event, emit) async {
      OpenOrderModel openOrderModel = await getOpenOrderModel();
      openOrderModel.openOrders
          ?.removeWhere((op) => (op.gCOrderLineItemsR?.records ?? []).isEmpty);

      emit(state.copyWith(
        fetchingOpenOrders: false,
        message: "",
        openOrderModel: openOrderModel,
        orderHistoryStatus: OrderHistoryStatus.success,
      ));

      for (int i = 0; i < openOrderModel.openOrders!.length; i++) {
        for (int j = 0;
            j <
                openOrderModel
                    .openOrders![i].gCOrderLineItemsR!.records!.length;
            j++) {
          ItemAvailabilityLandingScreenModel
              itemAvailabilityLandingScreenModel = await getItemAvailability(
                  openOrderModel
                      .openOrders![i].gCOrderLineItemsR!.records![j].itemSKUC!);
          openOrderModel.openOrders![i].gCOrderLineItemsR!.records![j].noInfo =
              itemAvailabilityLandingScreenModel.noInfo;
          openOrderModel.openOrders![i].gCOrderLineItemsR!.records![j]
              .outOfStock = itemAvailabilityLandingScreenModel.outOfStock;
          openOrderModel.openOrders![i].gCOrderLineItemsR!.records![j].inStore =
              itemAvailabilityLandingScreenModel.inStore;
        }
      }

      emit(state.copyWith(
          openOrderModel: openOrderModel,
          fetchingOpenOrders: false,
          message: "done"));
    });

    on<FetchOrderHistory>((event, emit) async {
      emit(state.copyWith(
          fetchOrderHistory: true, currentPage: event.currentPage));
      List<OrderDetail> orderHistories =
          await getOrderHistory(event.currentPage);
      if (event.currentPage == 1) {
        if (orderHistories.isNotEmpty) {
          emit(state.copyWith(
            fetchOrderHistory: false,
            orderHistory: orderHistories,
            haveMore: true,
            isFetchDone: true,
            message: "done",
          ));
        } else {
          emit(state.copyWith(
            fetchOrderHistory: false,
            orderHistory: [],
            isFetchDone: true,
            haveMore: false,
            message: "done",
          ));
        }
      } else if (event.currentPage > 1) {
        if (orderHistories.isNotEmpty) {
          print("done i am here");
          emit(state.copyWith(
            fetchOrderHistory: false,
            orderHistory: [...state.orderHistory!, ...orderHistories],
            haveMore: true,
            isFetchDone: true,
            message: "done",
          ));
        } else {
          emit(state.copyWith(
            fetchOrderHistory: false,
            orderHistory: state.orderHistory,
            isFetchDone: true,
            haveMore: false,
            message: "done",
          ));
        }
      }
    });

    on<GetItemStock>((event, emit) async {
      print("event.itemSkuId => ${event.itemSkuId}");
      OpenOrderModel openOrderModel = state.openOrderModel!;
      ItemAvailabilityLandingScreenModel itemAvailabilityLandingScreenModel =
          await getItemAvailability(event.itemSkuId);

      openOrderModel
          .openOrders![event.orderIndex]
          .gCOrderLineItemsR!
          .records![event.recordIndex]
          .outOfStock = itemAvailabilityLandingScreenModel.outOfStock;
      openOrderModel
          .openOrders![event.orderIndex]
          .gCOrderLineItemsR!
          .records![event.recordIndex]
          .noInfo = itemAvailabilityLandingScreenModel.noInfo;
      openOrderModel
          .openOrders![event.orderIndex]
          .gCOrderLineItemsR!
          .records![event.recordIndex]
          .inStore = itemAvailabilityLandingScreenModel.inStore;
      emit(state.copyWith(openOrderModel: openOrderModel, message: "done"));
    });

    on<LoadDataOrderHistory>((event, emit) async {
      emit(state.copyWith(orderHistoryStatus: OrderHistoryStatus.initial));
      CustomerOrderInfoModel customerOrderInfoModel =
          await getCustomerOrderIfo();
      // oam.PurchaseCategory orderAccessoriesModel = await getOrderAccessories();
      emit(state.copyWith(
          fetchingOpenOrders: state.fetchingOpenOrders ?? true,
          fetchOrderHistory: state.fetchOrderHistory ?? true,
          // accessoriesValues: orderAccessoriesModel.data,
          orderHistoryStatus: OrderHistoryStatus.success,
          customerOrderInfoModel: customerOrderInfoModel,
          lastPurchased: DateTime.now().toString(),
          cancelledOrder: "3/57 5.9%"));
    });

    on<SearchOrderHistory>((event, emit) async {
      if (event.searchText.isEmpty) {
        emit(state.copyWith(searchedOrderHistory: OrderHistory()));
        return;
      }
      var searchedOrder =
          await orderLookUpRepository.getOrderLookUp(event.searchText);
      if (searchedOrder.isNotEmpty) {
        var order = searchedOrder.first;
        print(order.toJson());
        emit(state.copyWith(
            searchedOrderHistory: OrderHistory(
                orderDate: order.orderDate.toString(),
                orderNumber: order.orderNo,
                orderPurchaseChannel: order.fulfillmentType,
                orderStatus: order.orderStatus,
                paymentMethodTotal: order.grandTotal,
                salesBrand: order.brand,
                lineItems: order.items
                    ?.map<LineItems>((e) => LineItems(
                          trackingNo: e?.trackingNo,
                          imageUrl: e?.imageUrl,
                          lineItemStatus: e?.itemStatus,
                          purchasedPrice: e?.unitPrice,
                          quantity: e?.orderedQuantity?.toString() ?? '0',
                          sellingPrice: e?.unitPrice,
                          title: e?.itemDesc,
                        ))
                    .toList())));
      } else
        emit(state.copyWith(searchedOrderHistory: OrderHistory()));
      // CustomerOrderInfoModel customerOrderInfoModel =
      //     await getCustomerOrderIfo();
      // PurchaseCategory orderAccessoriesModel = await getOrderAccessories();
      // emit(state.copyWith(
      //     fetchingOpenOrders: state.fetchingOpenOrders ?? true,
      //     fetchOrderHistory: state.fetchOrderHistory ?? true,
      //     accessoriesValues: orderAccessoriesModel.data,
      //     orderHistoryStatus: OrderHistoryStatus.success,
      //     customerOrderInfoModel: customerOrderInfoModel,
      //     lastPurchased: DateTime.now().toString(),
      //     cancelledOrder: "3/57 5.9%"));
    });
  }
  Future<CustomerOrderInfoModel> getCustomerOrderIfo() async {
    String id = await SharedPreferenceService().getValue(agentId);
    final response = await orderHistoryRepository.getCustomerOrderInfo(id);
    return response;
  }

  // Future<oam.PurchaseCategory> getOrderAccessories() async {
  //   String id = await SharedPreferenceService().getValue(agentId);
  //   final response = await orderHistoryRepository.getOrderAccessories(id);
  //   return response;
  // }

  Future<OpenOrderModel> getOpenOrderModel() async {
    String id = await SharedPreferenceService().getValue(agentId);
    final response = await orderHistoryRepository.getOpenOrders(id);
    return response;
  }

  Future<List<OrderDetail>> getOrderHistory(int page) async {
    String id = await SharedPreferenceService().getValue(agentId);
    final response = await orderHistoryRepository.getOrderHistory(id, page);
    return response;
  }

  Future<ItemAvailabilityLandingScreenModel> getItemAvailability(
      String itemSkuId) async {
    var loggedInUserId =
        await SharedPreferenceService().getValue(loggedInAgentId);

    final response = await landingScreenRepository.getItemAvailability(
        itemSkuId, loggedInUserId);
    return response;
  }
}
