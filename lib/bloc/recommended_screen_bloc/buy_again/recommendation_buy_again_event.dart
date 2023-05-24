part of 'recommendation_buy_again_bloc.dart';

abstract class RecommendationBuyAgainEvent extends Equatable {
  RecommendationBuyAgainEvent();

  @override
  List<Object> get props => [];
}


class EmptyMessage extends RecommendationBuyAgainEvent {
  EmptyMessage();
}
class InitializeProduct extends RecommendationBuyAgainEvent {
  InitializeProduct();
}
class UpdateProductInBuyAgain extends RecommendationBuyAgainEvent {
  final int? index;
  final  Records? records;
  UpdateProductInBuyAgain({this.index, required this.records});

  @override
  List<Object> get props => [index!,records!];
}

class GetItemAvailabilityBuyAgain extends RecommendationBuyAgainEvent {
  final int? parentIndex;
  final int? childIndex;
  GetItemAvailabilityBuyAgain({this.parentIndex, required this.childIndex});

  @override
  List<Object> get props => [parentIndex!,childIndex!];
}

class UpdateProductInBuyAgainOthers extends RecommendationBuyAgainEvent {
  final int? parentIndex;
  final int? childIndex;
  final  Records? records;
  UpdateProductInBuyAgainOthers({this.parentIndex, required this.childIndex, required this.records});

  @override
  List<Object> get props => [parentIndex!,childIndex!,records!];
}


class BuyAgainItems extends RecommendationBuyAgainEvent {
  BuyAgainItems();
  @override
  List<Object> get props => [];
}

class LoadProductDetailBuyAgainOther extends RecommendationBuyAgainEvent {
  final int? parentIndex;
  final int? childIndex;
  final bool? ifDetail;
  final String? customerId;
  final InventorySearchBloc inventorySearchBloc;
  final InventorySearchState state;
  LoadProductDetailBuyAgainOther({this.parentIndex, required this.childIndex,  required this.customerId, required this.ifDetail, required this.inventorySearchBloc, required this.state});

  @override
  List<Object> get props => [parentIndex!,childIndex!,ifDetail!,inventorySearchBloc,state,customerId!];
}

class LoadProductDetailBuyAgain extends RecommendationBuyAgainEvent {
  final int? index;
  final bool? ifDetail;
  final String? customerId;
  final InventorySearchBloc inventorySearchBloc;
  final InventorySearchState state;
  LoadProductDetailBuyAgain({this.index, required this.customerId, required this.ifDetail, required this.inventorySearchBloc, required this.state});

  @override
  List<Object> get props => [index!,ifDetail!,inventorySearchBloc,state,customerId!];
}

