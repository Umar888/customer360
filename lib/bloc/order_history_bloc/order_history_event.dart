part of 'order_history_bloc.dart';

@immutable
abstract class OrderHistoryEvent extends Equatable {
  OrderHistoryEvent();
  @override
  List<Object> get props => [];
}

class LoadDataOrderHistory extends OrderHistoryEvent {
  LoadDataOrderHistory();

  @override
  List<Object> get props => [];
}

class SearchOrderHistory extends OrderHistoryEvent {
  final String searchText;
  SearchOrderHistory(this.searchText);

  @override
  List<Object> get props => [searchText];
}

class FetchOrderHistory extends OrderHistoryEvent {
  final int currentPage;
  FetchOrderHistory({this.currentPage = 1});

  @override
  List<Object> get props => [currentPage];
}

class GetItemStock extends OrderHistoryEvent {
  final String itemSkuId;
  final int orderIndex;
  final int recordIndex;
  GetItemStock(
      {required this.recordIndex,
      required this.orderIndex,
      required this.itemSkuId});
  @override
  List<Object> get props => [orderIndex, recordIndex, itemSkuId];
}

class GetOpenOrders extends OrderHistoryEvent {
  GetOpenOrders();

  @override
  List<Object> get props => [];
}

class EmptyMessage extends OrderHistoryEvent {
  EmptyMessage();

  @override
  List<Object> get props => [];
}
