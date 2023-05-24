part of 'inventory_search_bloc.dart';

enum InventorySearchStatus { initState, loadState, successState, failedState }

class InventorySearchState extends Equatable {
  InventorySearchState(
      {this.inventorySearchStatus = InventorySearchStatus.initState,
        this.searchDetailModel =const [],
        this.productsInCart =const [],
        this.orderId = "",
        this.orderNumber = "",
        this.message = "",
        this.orderLineItemId = "",
        this.selectedDiscount = "40%+ OFF",
        this.fetchWarranties = false,
        this.isFirst = true,
        this.showDiscount = false,
        this.isUpdating = false,
        this.updateID = "",
        this.loadingSearch = false,
        this.showDialog = false,
        this.selectedChoice = "",
        this.selectedAvailability = "",
        this.selectedSort = "",
        this.searchString = '',
        this.updateSKUID = '',
        this.offset = 0,
        this.viewType = "List",
        this.options = const[],
        this.warrantiesRecord = const[],
        this.itemOfCart = const[],
        this.warrantiesModel = const[],
        this.position = const Offset(0, 700),
        this.prevScale = 1,
        this.scale = 1,
        this.sortName = 'Sort By',
        this.haveMore = true,
        this.fetchInventoryData,
        this.currentPage = 1,
        this.paginationFetching = false
        });

  final InventorySearchStatus inventorySearchStatus;
  final List<AddSearchModel> searchDetailModel;
  final List<Records> productsInCart;
  final List<Records> warrantiesRecord;
  final List<Warranties> warrantiesModel;
  final List<ItemsOfCart> itemOfCart;
  final String orderId;
  final String orderNumber;
  final Offset position;
  final double prevScale;
  final double scale;
  final String message;
  final String orderLineItemId;
  final String selectedDiscount;
  final bool showDiscount;
  final bool isFirst;
  final bool showDialog;
  final bool isUpdating;
  final String updateID;
  final bool loadingSearch;
  final bool fetchWarranties;
  final String selectedChoice;
  final String updateSKUID;
  final String selectedAvailability;
  final String selectedSort;
  final List<OptionsModel> options;
  final String searchString;
  final int offset;
  final String viewType;
  final String sortName;
  final bool haveMore;
  final bool? fetchInventoryData;
  final int currentPage;
  final bool? paginationFetching;


  InventorySearchState copyWith({
    InventorySearchStatus? inventorySearchStatus,
    List<AddSearchModel>? searchDetailModel,
    List<Records>? productsInCart,
    List<Records>? warrantiesRecord,
    List<Warranties>? warrantiesModel,
    List<ItemsOfCart>? itemOfCart,
    String? orderId,
    String? orderNumber,
    String? message,
    String? orderLineItemId,
    Offset? position,
    double? prevScale,
    double? scale,
    String? selectedDiscount,
    bool? showDiscount,
    bool? isFirst,
    bool? fetchWarranties,
    bool? showDialog,
    bool? loadingSearch,
    bool? isUpdating,
    String? updateID,
    String? updateSKUID,
    String? selectedChoice,
    String? selectedAvailability,
    String? selectedSort,
    List<OptionsModel>? options,
    String? searchString,
    int? offset,
    String? viewType,
    String? sortName,
    bool? haveMore,
    bool? fetchInventoryData,
    int? currentPage,
    bool? paginationFetching,

  }) {
    return InventorySearchState(
      inventorySearchStatus:
      inventorySearchStatus ?? this.inventorySearchStatus,
      warrantiesModel: warrantiesModel ?? this.warrantiesModel,
      searchDetailModel: searchDetailModel ?? this.searchDetailModel,
      message: message ?? this.message,
      orderNumber: orderNumber ?? this.orderNumber,
      showDialog: showDialog ?? this.showDialog,
      updateSKUID: updateSKUID ?? this.updateSKUID,
      isUpdating: isUpdating ?? this.isUpdating,
      updateID: updateID ?? this.updateID,
      position: position ?? this.position,
      isFirst: isFirst ?? this.isFirst,
      fetchWarranties: fetchWarranties ?? this.fetchWarranties,
      scale: scale ?? this.scale,
      prevScale: prevScale ?? this.prevScale,
      loadingSearch: loadingSearch ?? this.loadingSearch,
      productsInCart: productsInCart ?? this.productsInCart,
      orderId: orderId ?? this.orderId,
      orderLineItemId: orderLineItemId ?? this.orderLineItemId,
      selectedDiscount: selectedDiscount ?? this.selectedDiscount,
      showDiscount: showDiscount ?? this.showDiscount,
      warrantiesRecord: warrantiesRecord ?? this.warrantiesRecord,
      selectedChoice: selectedChoice ?? this.selectedChoice,
      selectedAvailability: selectedAvailability ?? this.selectedAvailability,
      selectedSort: selectedSort ?? this.selectedSort,
      options: options ?? this.options,
      searchString: searchString ?? this.searchString,
      offset: offset ?? this.offset,
      viewType: viewType ?? this.viewType,
      sortName: sortName ?? this.sortName,
      itemOfCart: itemOfCart ?? this.itemOfCart,
      haveMore: haveMore ?? this.haveMore,
      fetchInventoryData: fetchInventoryData ?? this.fetchInventoryData,
      currentPage: currentPage ?? this.currentPage,
      paginationFetching: paginationFetching ?? this.paginationFetching
    );
  }

  @override
  List<Object?> get props=> [
    inventorySearchStatus,
    searchDetailModel,
    warrantiesRecord,
    productsInCart,
    orderId,
    orderNumber,
    isFirst,
    warrantiesModel,
    orderLineItemId,
    selectedDiscount,
    message,
    loadingSearch,
    prevScale,
    updateSKUID,
    scale,
    fetchWarranties,
    position,
    showDiscount,
    selectedChoice,
    selectedAvailability,
    updateID,
    isUpdating,
    selectedSort,
    options,
    viewType,
    itemOfCart,
    offset,
    showDialog,
    searchString,
    sortName,
    haveMore,
    fetchInventoryData,
    currentPage,
    paginationFetching
  ];
}
