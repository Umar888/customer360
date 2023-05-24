part of 'zip_store_list_bloc.dart';

abstract class ZipStoreListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class PageLoad extends ZipStoreListEvent {
  final List<GetZipCodeList> getZipCodeListSearch;
  final List<GetZipCodeList> getZipCodeList;
  final List<asm.Records> productsInCart;
  final asm.Records records;

  PageLoad(
      {required this.getZipCodeListSearch,
      required this.getZipCodeList,
      required this.productsInCart,
      required this.records});

  @override
  List<Object> get props =>
      [getZipCodeListSearch, getZipCodeList, productsInCart, records];
}

class SetZipCode extends ZipStoreListEvent {
  final String zipCode;

  SetZipCode({required this.zipCode});

  @override
  List<Object> get props => [zipCode];
}

class SetOffset extends ZipStoreListEvent {
  final int offset;

  SetOffset({required this.offset});

  @override
  List<Object> get props => [offset];
}

class ClearOtherNodeData extends ZipStoreListEvent {
  ClearOtherNodeData();

  @override
  List<Object> get props => [];
}

class AddOtherNodeData extends ZipStoreListEvent {
  final String name;
  AddOtherNodeData({required this.name});

  @override
  List<Object> get props => [name];
}

class ChangeInitialExtent extends ZipStoreListEvent {
  final double initialExtent;
  ChangeInitialExtent({required this.initialExtent});

  @override
  List<Object> get props => [initialExtent];
}

class ChangeIsExpanded extends ZipStoreListEvent {
  final bool isExpanded;
  ChangeIsExpanded({required this.isExpanded});

  @override
  List<Object> get props => [isExpanded];
}

class UpdateBottomCartWithItems extends ZipStoreListEvent {
  final List<Items> items;
  final List<asm.Records> records;

  UpdateBottomCartWithItems({required this.items, required this.records});

  @override
  List<Object> get props => [items, records];
}
