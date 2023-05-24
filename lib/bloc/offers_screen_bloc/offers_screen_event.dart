part of 'offers_screen_bloc.dart';

abstract class OffersScreenEvent extends Equatable {
  OffersScreenEvent();

  @override
  List<Object> get props => [];
}

class LoadData extends OffersScreenEvent {
  final List<Offers>? offers;
  LoadData({required this.offers});
  @override
  List<Object> get props => [offers!];
}

class EmptyMessage extends OffersScreenEvent {
  EmptyMessage();
}

class InitializeProduct extends OffersScreenEvent {
  InitializeProduct();
}

class UpdateProduct extends OffersScreenEvent {
  final int? index;
  final  Records? records;
  UpdateProduct({this.index, required this.records});

  @override
  List<Object> get props => [index!, records!];
}

class LoadProductDetail extends OffersScreenEvent {
  final int? index;
  final bool? ifDetail;
  final String? customerId;
  final InventorySearchBloc inventorySearchBloc;
  final InventorySearchState state;
  LoadProductDetail(
      {required this.index,
      required this.ifDetail,
      required this.inventorySearchBloc,
      required this.state,
      required this.customerId});

  @override
  List<Object> get props =>
      [index!, ifDetail!, inventorySearchBloc, state, customerId!];
}

class LoadOffers extends OffersScreenEvent {
  LoadOffers();
  @override
  List<Object> get props => [];
}
