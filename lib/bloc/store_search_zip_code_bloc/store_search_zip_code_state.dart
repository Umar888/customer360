part of 'store_search_zip_code_bloc.dart';

enum StoreSearchZipCodeStatus {
  initState,
  loadState,
  successState,
  failedState
}

class StoreSearchZipCodeState extends Equatable {
  StoreSearchZipCodeState({
    this.storeSearchZipCodeStatus = StoreSearchZipCodeStatus.initState,
    this.maxExtent = 0.325,
    this.minExtent = 0.325,
    this.initialExtent = 0.325,
    this.zoomLevel = 16,
    this.isExpanded = false,
    this.offset = 0,
    this.isLoadingData = false,
    this.markers =const [],
    this.zipCode = "",
    this.currentRadius = "",
    this.searchStoreZip5,
    this.searchStoreZip10,
    this.searchStoreZip25,
    this.searchStoreZip50,
    this.searchStoreZip100,
    this.searchStoreZip200,
    this.searchStoreZip500,
  });

  final StoreSearchZipCodeStatus storeSearchZipCodeStatus;
  final double maxExtent;
  final double minExtent;
  final bool isExpanded;
  final double zoomLevel;
  final List<Marker> markers;
  final double initialExtent;
  final int offset;
  final bool isLoadingData;
  final SearchStoreModel? searchStoreZip5;
  final SearchStoreModel? searchStoreZip10;
  final SearchStoreModel? searchStoreZip25;
  final SearchStoreModel? searchStoreZip50;
  final SearchStoreModel? searchStoreZip100;
  final SearchStoreModel? searchStoreZip200;
  final SearchStoreModel? searchStoreZip500;
  final String zipCode;
  final String currentRadius;

  StoreSearchZipCodeState copyWith(
      {StoreSearchZipCodeStatus? storeSearchZipCodeStatus,
      double? maxExtent,
      double? minExtent,
      List<Marker>? markers,
      double? zoomLevel,
      bool? isExpanded,
      double? initialExtent,
      int? offset,
      bool? isLoadingData,
      String? zipCode,
      String? currentRadius,
      SearchStoreModel? searchStoreZip5,
      SearchStoreModel? searchStoreZip10,
      SearchStoreModel? searchStoreZip25,
      SearchStoreModel? searchStoreZip50,
      SearchStoreModel? searchStoreZip100,
      SearchStoreModel? searchStoreZip200,
      SearchStoreModel? searchStoreZip500}) {
    return StoreSearchZipCodeState(
      storeSearchZipCodeStatus:
          storeSearchZipCodeStatus ?? this.storeSearchZipCodeStatus,
      maxExtent: maxExtent ?? this.maxExtent,
      markers: markers ?? this.markers,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      minExtent: minExtent ?? this.minExtent,
      isExpanded: isExpanded ?? this.isExpanded,
      initialExtent: initialExtent ?? this.initialExtent,
      offset: offset ?? this.offset,
      currentRadius: currentRadius ?? this.currentRadius,
      isLoadingData: isLoadingData ?? this.isLoadingData,
      zipCode: zipCode ?? this.zipCode,
      searchStoreZip5: searchStoreZip5 ?? this.searchStoreZip5,
      searchStoreZip10: searchStoreZip10 ?? this.searchStoreZip10,
      searchStoreZip25: searchStoreZip25 ?? this.searchStoreZip25,
      searchStoreZip50: searchStoreZip50 ?? this.searchStoreZip50,
      searchStoreZip100: searchStoreZip100 ?? this.searchStoreZip100,
      searchStoreZip200: searchStoreZip200 ?? this.searchStoreZip200,
      searchStoreZip500: searchStoreZip500 ?? this.searchStoreZip500,
    );
  }

  @override
  List<Object?> get props => [
        storeSearchZipCodeStatus,
        currentRadius,
        maxExtent,
        zoomLevel,
        markers,
        minExtent,
        isExpanded,
        initialExtent,
        offset,
        isLoadingData,
        zipCode,
        searchStoreZip5,
        searchStoreZip10,
        searchStoreZip25,
        searchStoreZip50,
        searchStoreZip100,
        searchStoreZip200,
        searchStoreZip500,
      ];
}
