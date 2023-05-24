part of 'zip_store_list_bloc.dart';

enum ZipStoreListStatus { initState, loadState, successState, failedState }

class ZipStoreListState extends Equatable {
  ZipStoreListState(
      {this.zipStoreListStatus = ZipStoreListStatus.initState,
      this.maxExtent = 0.375,
      this.minExtent = 0.375,
      this.initialExtent = 0.375,
      this.isExpanded = false,
      this.offset = 0,
      this.isLoadingData = false,
      this.zipCode = "",
      this.productsInCart =const [],
      this.currentRecord =const [],
      this.getZipCodeListSearch =const [],
      this.getZipCodeList =const []});

  final ZipStoreListStatus zipStoreListStatus;
  final double maxExtent;
  final double minExtent;
  final bool isExpanded;
  final double initialExtent;
  final int offset;
  final bool isLoadingData;
  final String zipCode;
  final List<asm.Records> productsInCart;
  final List<asm.Records> currentRecord;
  final List<GetZipCodeList> getZipCodeListSearch;
  final List<GetZipCodeList> getZipCodeList;

  ZipStoreListState copyWith(
      {ZipStoreListStatus? zipStoreListStatus,
      double? maxExtent,
      double? minExtent,
      bool? isExpanded,
      double? initialExtent,
      int? offset,
      bool? isLoadingData,
      String? zipCode,
      List<asm.Records>? productsInCart,
      List<asm.Records>? currentRecord,
      List<GetZipCodeList>? getZipCodeListSearch,
      List<GetZipCodeList>? getZipCodeList}) {
    return ZipStoreListState(
        zipStoreListStatus: zipStoreListStatus ?? this.zipStoreListStatus,
        maxExtent: maxExtent ?? this.maxExtent,
        minExtent: minExtent ?? this.minExtent,
        isExpanded: isExpanded ?? this.isExpanded,
        initialExtent: initialExtent ?? this.initialExtent,
        offset: offset ?? this.offset,
        isLoadingData: isLoadingData ?? this.isLoadingData,
        zipCode: zipCode ?? this.zipCode,
        currentRecord: currentRecord ?? this.currentRecord,
        productsInCart: productsInCart ?? this.productsInCart,
        getZipCodeListSearch: getZipCodeListSearch ?? this.getZipCodeListSearch,
        getZipCodeList: getZipCodeList ?? this.getZipCodeList);
  }

  @override
  List<Object> get props => [
        zipStoreListStatus,
        maxExtent,
        minExtent,
        isExpanded,
        initialExtent,
        offset,
        isLoadingData,
        zipCode,
        currentRecord,
        productsInCart,
        getZipCodeListSearch,
        getZipCodeList
      ];
}
