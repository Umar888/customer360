part of 'product_detail_bloc.dart';

abstract class ProductDetailEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class PageLoad extends ProductDetailEvent {
  final String skuENTId;
  final String orderId;
  final String warrantyId;
  final String orderLineItemId;
  final InventorySearchBloc inventorySearchBloc;
  final List<Records> productsInCart;

  PageLoad({required this.skuENTId,
      required this.warrantyId,
      required this.orderId,
      required this.orderLineItemId,
      required this.inventorySearchBloc,
      required this.productsInCart});

  @override
  List<Object> get props => [orderId,orderLineItemId,inventorySearchBloc,skuENTId, warrantyId, productsInCart];
}

class GetAddressProduct extends ProductDetailEvent {
  final String skuENTId;
  GetAddressProduct({required this.skuENTId});
  @override
  List<Object> get props => [skuENTId];
}

class SearchAddressProduct extends ProductDetailEvent {
  final String searchName;

  SearchAddressProduct({required this.searchName});

  @override
  List<Object> get props => [searchName];
}

class GetProductEligibility extends ProductDetailEvent {
  final String itemSKUId;
  GetProductEligibility({required this.itemSKUId});
  @override
  List<Object> get props => [itemSKUId];
}

class GetProductDetail extends ProductDetailEvent {
  final int? index;
  final String? customerId;
  final String id;
  final InventorySearchBloc inventorySearchBloc;
  final InventorySearchState state;
  GetProductDetail(
      {required this.index,
      required this.id,
      required this.inventorySearchBloc,
      required this.state,
      required this.customerId});

  @override
  List<Object> get props =>
      [id, index!, inventorySearchBloc, state, customerId!];
}

class ClearMessage extends ProductDetailEvent {}

class AddToCart extends ProductDetailEvent {
  final Records records;
  final String customerID;
  final String orderID;

  AddToCart(
      {required this.records, required this.customerID, required this.orderID});

  @override
  List<Object> get props => [records, customerID, orderID];
}

class SetCurrentImage extends ProductDetailEvent {
  final String image;
  SetCurrentImage({required this.image});

  @override
  List<Object> get props => [image];
}

class SetExpandBundle extends ProductDetailEvent {
  final bool expandBundle;
  SetExpandBundle({required this.expandBundle});

  @override
  List<Object> get props => [expandBundle];
}

class SetExpandColor extends ProductDetailEvent {
  final bool expandColor;
  SetExpandColor({required this.expandColor});

  @override
  List<Object> get props => [expandColor];
}

class SetCurrentColor extends ProductDetailEvent {
  final ColorModel currentColor;
  SetCurrentColor({required this.currentColor});

  @override
  List<Object> get props => [currentColor];
}

class UpdateBottomCartWithItems extends ProductDetailEvent {
  final List<Items> items;
  final List<Records> records;

  UpdateBottomCartWithItems({required this.items, required this.records});

  @override
  List<Object> get props => [items, records];
}

class UpdateBottomCart extends ProductDetailEvent {
  final List<Records> items;

  UpdateBottomCart({required this.items});

  @override
  List<Object> get props => [items];
}

class SetExpandCoverage extends ProductDetailEvent {
  final bool expandCoverage;
  SetExpandCoverage({required this.expandCoverage});

  @override
  List<Object> get props => [expandCoverage];
}

class SetExpandEligibility extends ProductDetailEvent {
  final bool value;
  SetExpandEligibility({required this.value});

  @override
  List<Object> get props => [value];
}

class SetCurrentCoverage extends ProductDetailEvent {
  final Warranties currentCoverage;
  final String orderID;
  final String styleDescription1;
  final InventorySearchBloc inventorySearchBloc;
  final List<ItemsOfCart> itemsOfCart;
  final List<Records> productsInCart;
  final String orderLineItemID;
  SetCurrentCoverage({
    required this.currentCoverage,
    required this.inventorySearchBloc,
    required this.itemsOfCart,
    required this.orderID,
    required this.productsInCart,
    required this.orderLineItemID,
    required this.styleDescription1,
  });

  @override
  List<Object> get props => [currentCoverage,orderID,orderLineItemID,inventorySearchBloc,itemsOfCart,styleDescription1,productsInCart];
}

class RemoveFromCart extends ProductDetailEvent {
  final Records records;
  final String customerID;
  final String orderID;

  RemoveFromCart(
      {required this.records, required this.customerID, required this.orderID});

  @override
  List<Object> get props => [records, customerID, orderID];
}

class AddOptions extends ProductDetailEvent {}

// class GetAddressProduct extends ProductDetailEvent {
//   final String skuENTId;
//   GetAddressProduct({required this.skuENTId});
//   @override
//   List<Object> get props => [skuENTId];
// }

// class SearchAddressProduct extends ProductDetailEvent {
//   final String searchName;
//   SearchAddressProduct({required this.searchName});
//   @override
//   List<Object> get props => [searchName];
// }
