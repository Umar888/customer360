part of 'store_search_zip_code_bloc.dart';

abstract class StoreSearchZipCodeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class PageLoad extends StoreSearchZipCodeEvent {
  PageLoad();

  @override
  List<Object> get props => [];
}

class SetZoomLevel extends StoreSearchZipCodeEvent {
  double radius;
  SetZoomLevel({required this.radius});

  @override
  List<Object> get props => [radius];
}

class ClearMarkers extends StoreSearchZipCodeEvent {
  ClearMarkers();

  @override
  List<Object> get props => [];
}

class SetMarkers extends StoreSearchZipCodeEvent {
  List<SearchStoreList>? searchStoreList;
  List<SearchStoreListInformation> searchStoreListInformation;
  Function(String)? onTapMarker;
  SetMarkers(
      {required this.searchStoreListInformation,
      this.searchStoreList,
      this.onTapMarker});

  @override
  List<Object> get props => [searchStoreListInformation];
}

class GetAddress extends StoreSearchZipCodeEvent {
  final String radius;
  final String name;
  final String orderId;

  GetAddress({required this.radius, required this.name, required this.orderId});

  @override
  List<Object> get props => [radius, name, orderId];
}

class SetZipCode extends StoreSearchZipCodeEvent {
  final String zipCode;

  SetZipCode({required this.zipCode});

  @override
  List<Object> get props => [zipCode];
}

class SetOffset extends StoreSearchZipCodeEvent {
  final int offset;

  SetOffset({required this.offset});

  @override
  List<Object> get props => [offset];
}

class ClearOtherNodeData extends StoreSearchZipCodeEvent {
  ClearOtherNodeData();

  @override
  List<Object> get props => [];
}

class AddOtherNodeData extends StoreSearchZipCodeEvent {
  final String name;
  AddOtherNodeData({required this.name});

  @override
  List<Object> get props => [name];
}

class ChangeInitialExtent extends StoreSearchZipCodeEvent {
  final double initialExtent;
  ChangeInitialExtent({required this.initialExtent});

  @override
  List<Object> get props => [initialExtent];
}

class ChangeIsExpanded extends StoreSearchZipCodeEvent {
  final bool isExpanded;
  ChangeIsExpanded({required this.isExpanded});

  @override
  List<Object> get props => [isExpanded];
}

class UpdateBottomCartWithItems extends StoreSearchZipCodeEvent {
  final List<Items> items;
  final List<Records> records;

  UpdateBottomCartWithItems({required this.items, required this.records});

  @override
  List<Object> get props => [items, records];
}
