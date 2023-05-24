part of 'recommendation_cart_bloc.dart';

abstract class RecommendationCartEvent extends Equatable {
  RecommendationCartEvent();

  @override
  List<Object> get props => [];
}

class GetItemAvailabilityCart extends RecommendationCartEvent {
  final int? parentIndex;
  final int? childIndex;

  GetItemAvailabilityCart({this.parentIndex, required this.childIndex});

  @override
  List<Object> get props => [parentIndex!, childIndex!];
}

class LoadCartItems extends RecommendationCartEvent {
  LoadCartItems();

  @override
  List<Object> get props => [];
}

class EmptyMessage extends RecommendationCartEvent {
  EmptyMessage();
}

class InitializeProduct extends RecommendationCartEvent {
  InitializeProduct();
}

class UpdateProductInCartOthers extends RecommendationCartEvent {
  final int? parentIndex;
  final int? childIndex;
  final asm.Records? records;

  UpdateProductInCartOthers({this.parentIndex, required this.childIndex, required this.records});

  @override
  List<Object> get props => [parentIndex!, childIndex!, records!];
}

class UpdateProductInCart extends RecommendationCartEvent {
  final int? parentIndex;
  final int? childIndex;
  final asm.Records? records;

  UpdateProductInCart({this.parentIndex, required this.childIndex, required this.records});

  @override
  List<Object> get props => [parentIndex!, childIndex!, records!];
}

class LoadProductDetailCartOthers extends RecommendationCartEvent {
  final int? parentIndex;
  final int? childIndex;
  final bool? ifDetail;
  final String? customerId;
  final InventorySearchBloc inventorySearchBloc;
  final InventorySearchState state;

  LoadProductDetailCartOthers(
      {this.parentIndex,
      required this.childIndex,
      required this.customerId,
      required this.ifDetail,
      required this.inventorySearchBloc,
      required this.state});

  @override
  List<Object> get props => [parentIndex!, childIndex!, ifDetail!, inventorySearchBloc, state, customerId!];
}

class LoadProductDetailCart extends RecommendationCartEvent {
  final int? parentIndex;
  final int? childIndex;
  final bool? ifDetail;
  final String? customerId;
  final InventorySearchBloc inventorySearchBloc;
  final InventorySearchState state;

  LoadProductDetailCart(
      {this.parentIndex,
      required this.childIndex,
      required this.customerId,
      required this.ifDetail,
      required this.inventorySearchBloc,
      required this.state});

  @override
  List<Object> get props => [parentIndex!, childIndex!, ifDetail!, inventorySearchBloc, state, customerId!];
}
