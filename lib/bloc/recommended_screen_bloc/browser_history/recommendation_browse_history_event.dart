part of 'recommendation_browse_history_bloc.dart';

abstract class RecommendationScreenEvent extends Equatable {
  RecommendationScreenEvent();

  @override
  List<Object> get props => [];
}

class LoadBrowseHistoryItems extends RecommendationScreenEvent {
  LoadBrowseHistoryItems();
  @override
  List<Object> get props => [];
}


class EmptyMessage extends RecommendationScreenEvent {
  EmptyMessage();
}
class InitializeProduct extends RecommendationScreenEvent {
  InitializeProduct();
}
class UpdateProductInBrowsing extends RecommendationScreenEvent {
  final int? parentIndex;
  final int? childIndex;
  final  Records? records;
  UpdateProductInBrowsing({this.parentIndex, required this.childIndex, required this.records});

  @override
  List<Object> get props => [parentIndex!,childIndex!,records!];
}
class UpdateProductInBrowsingOthers extends RecommendationScreenEvent {
  final int? parentIndex;
  final int? childIndex;
  final  Records? records;
  UpdateProductInBrowsingOthers({this.parentIndex, required this.childIndex, required this.records});

  @override
  List<Object> get props => [parentIndex!,childIndex!,records!];
}
class GetItemAvailabilityBrowsing extends RecommendationScreenEvent {
  final int? parentIndex;
  final int? childIndex;
  GetItemAvailabilityBrowsing({this.parentIndex, required this.childIndex});

  @override
  List<Object> get props => [parentIndex!,childIndex!];
}

class LoadProductDetailBrowseOtherHistory extends RecommendationScreenEvent {
  final int? parentIndex;
  final int? childIndex;
  final bool? ifDetail;
  final String? customerId;
  final InventorySearchBloc inventorySearchBloc;
  final InventorySearchState state;
  LoadProductDetailBrowseOtherHistory({this.parentIndex, required this.childIndex, required this.ifDetail, required this.inventorySearchBloc, required this.state, required this.customerId});

  @override
  List<Object> get props => [parentIndex!,childIndex!,ifDetail!,inventorySearchBloc,state,customerId!];
}

class LoadProductDetailBrowseHistory extends RecommendationScreenEvent {
  final int? parentIndex;
  final int? childIndex;
  final bool? ifDetail;
  final String? customerId;
  final InventorySearchBloc inventorySearchBloc;
  final InventorySearchState state;
  LoadProductDetailBrowseHistory({this.parentIndex, required this.childIndex, required this.ifDetail, required this.inventorySearchBloc, required this.state, required this.customerId});

  @override
  List<Object> get props => [parentIndex!,childIndex!,ifDetail!,inventorySearchBloc,state,customerId!];
}

