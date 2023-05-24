part of 'inventory_search_bloc.dart';

abstract class InventorySearchEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class InventorySearchFetch extends InventorySearchEvent {
  final String name;
  final String choice;

  final List<Records> productsInCart;
  final List<AddSearchModel> searchDetailModel;
  final fbdm.FavoriteBrandDetailModel favoriteItems;
  final bool isFavouriteScreen;
  final bool isOfferScreen;

  InventorySearchFetch(
      {required this.name,
      required this.choice,
      required this.productsInCart,
      required this.searchDetailModel,
      required this.favoriteItems,
      required this.isFavouriteScreen,
      required this.isOfferScreen});

  @override
  List<Object> get props => [name, productsInCart];
}

class PageLoad extends InventorySearchEvent {
  final int offset;
  final String name;
  final bool? isFirstTime;

  PageLoad({required this.offset, required this.name, required this.isFirstTime});

  @override
  List<Object> get props => [offset, name];
}

class FetchInventoryPaginationData extends InventorySearchEvent {
  final List<AddSearchModel>? searchDetailModel;

  final int currentPage;
  final String searchName;
  final String choice;
  FetchInventoryPaginationData({required this.searchDetailModel, required this.currentPage, required this.searchName, required this.choice});

  @override
  List<Object> get props => [currentPage];
}

class UpdateBottomCart extends InventorySearchEvent {
  final List<Records> items;

  UpdateBottomCart({required this.items});

  @override
  List<Object> get props => [items];
}

class UpdateBottomCartWithItems extends InventorySearchEvent {
  final List<BrandItems> items;
  final List<Records> records;

  UpdateBottomCartWithItems({required this.items, required this.records});

  @override
  List<Object> get props => [items, records];
}

class UpdateScale extends InventorySearchEvent {
  final double zoom;
  final double prevScale;

  UpdateScale({required this.zoom, required this.prevScale});

  @override
  List<Object> get props => [zoom, prevScale];
}

class CommitScale extends InventorySearchEvent {
  final double scale;
  CommitScale({required this.scale});

  @override
  List<Object> get props => [scale];
}

class UpdatePosition extends InventorySearchEvent {
  final Offset newPosition;
  UpdatePosition({required this.newPosition});

  @override
  List<Object> get props => [newPosition];
}

class ChangeShowDiscount extends InventorySearchEvent {
  final bool showDiscount;

  ChangeShowDiscount({required this.showDiscount});

  @override
  List<Object> get props => [showDiscount];
}

class ChangeViewType extends InventorySearchEvent {
  final String view;

  ChangeViewType({required this.view});

  @override
  List<Object> get props => [view];
}

class ChangeSelectedAvailability extends InventorySearchEvent {
  final String availability;

  ChangeSelectedAvailability({required this.availability});

  @override
  List<Object> get props => [availability];
}

class ChangeSelectedDiscount extends InventorySearchEvent {
  final String discount;

  ChangeSelectedDiscount({required this.discount});

  @override
  List<Object> get props => [discount];
}

class ChangeSelectedSort extends InventorySearchEvent {
  final String sort;

  ChangeSelectedSort({required this.sort});

  @override
  List<Object> get props => [sort];
}

class AddToCart extends InventorySearchEvent {
  final Records records;
  final String productId;
  final String skUid;
  final String customerID;
  final String orderID;
  final Warranties warranties;
  final String orderItem;
  final bool ifWarranties;
  final bool fromFavorite;
  final int quantity;
  final FavouriteBrandScreenBloc favouriteBrandScreenBloc;

  AddToCart({
    required this.productId,
    this.skUid = "-101",
    required this.orderItem,
    required this.warranties,
    this.quantity = -1,
    this.fromFavorite = false,
    required this.ifWarranties,
    required this.records,
    required this.customerID,
    required this.orderID,
    required this.favouriteBrandScreenBloc,
  });

  @override
  List<Object> get props => [
        skUid,
        fromFavorite,
        quantity,
        warranties,
        ifWarranties,
        orderItem,
        records,
        productId,
        customerID,
        orderID,
        favouriteBrandScreenBloc,
      ];
}

class RemoveFromCart extends InventorySearchEvent {
  final Records records;
  final String productId;
  final String customerID;
  final String orderID;
  final int quantity;
  final bool fromFavorite;
  final FavouriteBrandScreenBloc favouriteBrandScreenBloc;

  RemoveFromCart({
    required this.records,
    required this.productId,
    this.fromFavorite = false,
    this.quantity = -1,
    required this.customerID,
    required this.orderID,
    required this.favouriteBrandScreenBloc,
  });

  @override
  List<Object> get props => [
        fromFavorite,
        records,
        productId,
        customerID,
        orderID,
        quantity,
        favouriteBrandScreenBloc,
      ];
}

class AddOptions extends InventorySearchEvent {}

class AddFilters extends InventorySearchEvent {
  final int parentIndex;
  final int childIndex;
  AddFilters({
    required this.parentIndex,
    required this.childIndex,
  });

  @override
  List<Object> get props => [parentIndex, childIndex];
}

class EmptyMessage extends InventorySearchEvent {
  EmptyMessage();
}

class DoneMessage extends InventorySearchEvent {
  DoneMessage();
}

class UpdateIsFirst extends InventorySearchEvent {
  bool value;
  UpdateIsFirst({required this.value});

  @override
  List<Object> get props => [value];
}

class FetchEligibility extends InventorySearchEvent {
  int index;
  FetchEligibility({required this.index});

  @override
  List<Object> get props => [index];
}

class SetCart extends InventorySearchEvent {
  final List<ItemsOfCart> itemOfCart;
  final List<Records> records;
  final String orderId;
  SetCart({
    required this.itemOfCart,
    required this.records,
    required this.orderId,
  });

  @override
  List<Object> get props => [itemOfCart, orderId, records];
}

class OnExpandMainTile extends InventorySearchEvent {
  final List<AddSearchModel>? searchDetailModel;
  final int index;
  OnExpandMainTile({
    required this.searchDetailModel,
    required this.index,
  });

  @override
  List<Object> get props => [searchDetailModel!, index];
}

class OnClearFilters extends InventorySearchEvent {
  final List<AddSearchModel>? searchDetailModel;
  final bool buildOnTap;
  final bool? isSearchName;
  final String? searchName;
  final bool? sortBy;
  final bool? isFavouriteScreen;
  final String? brandName;
  final String? primaryInstrument;
  final List<BrandItems>? brandItems;
  final FavouriteBrandScreenBloc? favouriteBrandScreenBloc;
  final fbdm.FavoriteBrandDetailModel? favoriteItems;
  final List<Records> productsInCart;

  OnClearFilters(
      {required this.searchDetailModel,
      required this.buildOnTap,
      this.searchName,
      this.isSearchName,
      this.sortBy,
      required this.isFavouriteScreen,
      required this.brandName,
      required this.primaryInstrument,
      required this.brandItems,
      required this.favouriteBrandScreenBloc,
      required this.favoriteItems,
      required this.productsInCart});

  @override
  List<Object> get props => [
        searchDetailModel!,
        buildOnTap,
        searchName!,
        sortBy!,
        isFavouriteScreen!,
        isSearchName!,
        brandName!,
        primaryInstrument!,
        brandItems!,
        favouriteBrandScreenBloc!,
      ];
}

class GetWarranties extends InventorySearchEvent {
  final String skuEntId;
  final String productId;
  final Records records;
  GetWarranties({required this.skuEntId, required this.records, required this.productId});

  @override
  List<Object> get props => [skuEntId, records, productId];
}

class ClearWarranties extends InventorySearchEvent {
  ClearWarranties();

  @override
  List<Object> get props => [];
}

class RefreshFavorite extends InventorySearchEvent {
  RefreshFavorite();

  @override
  List<Object> get props => [];
}

class ChangeWarranties extends InventorySearchEvent {
  final Warranties warranties;
  final String orderItem;
  final String warrantyId;
  final String orderID;
  final String warrantyName;
  final String warrantyPrice;
  final int index;
  ChangeWarranties(
      {required this.orderID,
      required this.warrantyId,
      required this.warrantyName,
      required this.warrantyPrice,
      required this.orderItem,
      required this.warranties,
      required this.index});

  @override
  List<Object> get props => [orderID, warrantyId, warrantyName, warrantyPrice, warranties, orderItem];
}

class ChangeSelectedChoice extends InventorySearchEvent {
  final String choice;
  final String? searchText;
  final List<AddSearchModel>? searchDetailModel;
  final List<Records> productsInCart;
  final int? indexOfItem;
  final fbdm.FavoriteBrandDetailModel favoriteItems;
  final bool isFavouriteScreen;
  final bool isOfferScreen;

  ChangeSelectedChoice(
      {this.searchText,
      required this.choice,
      required this.searchDetailModel,
      required this.productsInCart,
      this.indexOfItem,
      required this.favoriteItems,
      required this.isFavouriteScreen,
      required this.isOfferScreen});

  @override
  List<Object> get props => [choice, searchText!, searchDetailModel!, productsInCart, indexOfItem!, favoriteItems, isFavouriteScreen];
}

class ChangeShowDialog extends InventorySearchEvent {
  bool value;
  ChangeShowDialog(this.value);

  @override
  List<Object> get props => [value];
}

class SearchProductWithFilters extends InventorySearchEvent {
  final List<AddSearchModel>? searchDetailModel;
  final List<Records> productsInCart;
  final List<Refinement> filteredListOfRefinements;
  final String searText;
  final String choice;
  final fbdm.FavoriteBrandDetailModel? favoriteItems;
  final bool? isFavouriteScreen;
  final String? brandName;
  final String? primaryInstrument;
  final List<BrandItems>? brandItems;
  final bool? isOfferScreen;

  SearchProductWithFilters(
    this.searText, {
    required this.searchDetailModel,
    required this.productsInCart,
    required this.choice,
    required this.filteredListOfRefinements,
    required this.favoriteItems,
    required this.isFavouriteScreen,
    required this.brandItems,
    required this.brandName,
    required this.primaryInstrument,
    required this.isOfferScreen,
  });

  @override
  List<Object> get props => [
        searchDetailModel!,
        productsInCart,
        choice,
        filteredListOfRefinements,
        favoriteItems!,
        isFavouriteScreen!,
        searText,
        brandName!,
        brandItems!,
        primaryInstrument!,
      ];
}
