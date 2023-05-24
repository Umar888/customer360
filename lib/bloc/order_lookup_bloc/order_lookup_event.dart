part of 'order_lookup_bloc.dart';

abstract class OrderLookUpEvent extends Equatable {
  OrderLookUpEvent();
}

class SearchOrders extends OrderLookUpEvent {
  final String searchText;
  SearchOrders(this.searchText);

  @override
  List<Object?> get props => [];
}

class ClearOrderLookUp extends OrderLookUpEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}
