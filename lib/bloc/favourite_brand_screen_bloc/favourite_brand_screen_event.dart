part of 'favourite_brand_screen_bloc.dart';

abstract class FavouriteBrandScreenEvent extends Equatable {
  FavouriteBrandScreenEvent();

  @override
  List<Object> get props => [];
}

class LoadData extends FavouriteBrandScreenEvent {
  final String? primaryInstrument;
  final String? brandName;
  final List<BrandItems>? brandItems;
  final bool isFavouriteScreen;
  LoadData({
    required this.primaryInstrument,
    required this.brandName,
    required this.brandItems,
    required this.isFavouriteScreen,
  });
  @override
  List<Object> get props => [primaryInstrument!, brandName!, brandItems!];
}

class EmptyMessage extends FavouriteBrandScreenEvent {
  EmptyMessage();
}
class SetProductWarranty extends FavouriteBrandScreenEvent {
  final Warranties? warranties;
  SetProductWarranty({
    required this.warranties
  });
  @override
  List<Object> get props => [warranties!];
}

class InitializeProduct extends FavouriteBrandScreenEvent {
  InitializeProduct();
}

class RefreshList extends FavouriteBrandScreenEvent {
  RefreshList();
}

class UpdateProduct extends FavouriteBrandScreenEvent {
  final int? index;
  final bool? ifNative;
  final asm.Records? records;
  UpdateProduct(
      {this.index, required this.records, required this.ifNative});

  @override
  List<Object> get props => [index!, records!, ifNative!];
}

class LoadProductDetail extends FavouriteBrandScreenEvent {
  final int? index;
  final bool? ifDetail;
  final bool? ifNative;
  final String? customerId;
  final String id;
  final InventorySearchBloc inventorySearchBloc;
  final InventorySearchState state;
  LoadProductDetail(
      {required this.ifNative,
      required this.index,
      required this.id,
      required this.ifDetail,
      required this.inventorySearchBloc,
      required this.state,
      required this.customerId});

  @override
  List<Object> get props =>
      [id,ifNative!, index!, ifDetail!, inventorySearchBloc, state, customerId!];
}
