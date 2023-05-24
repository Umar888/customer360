part of 'order_history_bloc.dart';

enum OrderHistoryStatus { initial, success, failure }

class OrderHistoryState extends Equatable {
  final CustomerOrderInfoModel? customerOrderInfoModel;
  final OpenOrderModel? openOrderModel;
  final OrderHistoryStatus? orderHistoryStatus;
  final bool? fetchingOpenOrders;
  final bool? fetchOrderHistory;
  final List<OrderDetail>? orderHistory;
  final Map<dynamic, dynamic>? accessoriesValues;
  final String? lastPurchased;
  final String? cancelledOrder;
  final String? message;
  final int currentPage;
  final bool? isFetchDone;
  final bool haveMore;
  final OrderHistory? searchedOrderHistory;

  OrderHistoryState({
    this.openOrderModel,
    this.haveMore = true,
    this.orderHistoryStatus,
    this.message,
    this.currentPage = 1,
    this.fetchOrderHistory,
    this.customerOrderInfoModel,
    this.orderHistory = const [],
    this.fetchingOpenOrders,
    this.accessoriesValues,
    this.lastPurchased,
    this.cancelledOrder,
    this.isFetchDone,
    this.searchedOrderHistory,
  });

  OrderHistoryState copyWith({
    OrderHistoryStatus? orderHistoryStatus,
    OpenOrderModel? openOrderModel,
    CustomerOrderInfoModel? customerOrderInfoModel,
    List<OrderDetail>? orderHistory,
    int? currentPage,
    String? message,
    bool? haveMore,
    bool? fetchingOpenOrders,
    bool? fetchOrderHistory,
    Map<dynamic, dynamic>? accessoriesValues,
    String? lastPurchased,
    String? cancelledOrder,
    bool? isFetchDone,
    OrderHistory? searchedOrderHistory,
  }) {
    return OrderHistoryState(
      customerOrderInfoModel:
          customerOrderInfoModel ?? this.customerOrderInfoModel,
      message: message ?? this.message,
      haveMore: haveMore ?? this.haveMore,
      currentPage: currentPage ?? this.currentPage,
      orderHistory: orderHistory ?? this.orderHistory,
      openOrderModel: openOrderModel ?? this.openOrderModel,
      fetchOrderHistory: fetchOrderHistory ?? this.fetchOrderHistory,
      orderHistoryStatus: orderHistoryStatus ?? this.orderHistoryStatus,
      fetchingOpenOrders: fetchingOpenOrders ?? this.fetchingOpenOrders,
      accessoriesValues: accessoriesValues ?? this.accessoriesValues,
      lastPurchased: lastPurchased ?? this.lastPurchased,
      cancelledOrder: cancelledOrder ?? this.cancelledOrder,
      isFetchDone: isFetchDone ?? false,
      searchedOrderHistory: searchedOrderHistory ?? this.searchedOrderHistory,
    );
  }

  @override
  List<Object?> get props => [
        customerOrderInfoModel,
        openOrderModel,
        currentPage,
        fetchingOpenOrders,
        haveMore,
        message,
        orderHistory,
        accessoriesValues,
        fetchOrderHistory,
        cancelledOrder,
        isFetchDone,
        searchedOrderHistory,
      ];
}
