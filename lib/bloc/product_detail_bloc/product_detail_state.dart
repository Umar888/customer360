part of 'product_detail_bloc.dart';

enum ProductDetailStatus { initState, loadState, successState, failedState }

class ProductDetailState extends Equatable {
  ProductDetailState({
    this.productDetailStatus = ProductDetailStatus.initState,
    this.currentImage = "",
    this.currentCondition = "",
    this.records =const [],
    this.moreInfo =const [],
    this.productsInCart =const [],
    this.currentProCoverage =const [],
    this.currentColor =const [],
    this.images =const [],
    this.proCoverage =const [],
    this.colors =const [],
    this.isUpdating = false,
    this.fetchEligibility = true,
    this.orderLineItemId = "",
    this.updateID = "",
    this.orderId = "",
    this.message = "",
    this.proCoverageModel =const [],
    this.mainNodeData =const [],
    this.productRecommands =const [],
    this.getZipCodeListSearch =const [],
    this.getZipCodeList =const [],
    this.isInStoreLoading = true,
    this.showDesc = true,
    this.expandBundle = false,
    this.expandColor = false,
    this.expandCoverage = false,
    this.expandEligibility = false,
    this.loadingBundles = true,
  });

  final ProductDetailStatus productDetailStatus;
  final String currentImage;
  final String message;
  final String currentCondition;
  final String orderLineItemId;
  final String orderId;
  final List<Records> records;
  final List<Records> productsInCart;
  final List<Warranties> currentProCoverage;
  final List<ColorModel> currentColor;
  final bool isUpdating;
  final bool loadingBundles;
  final bool fetchEligibility;
  final String updateID;
  final List<pem.MoreInfo> moreInfo;
  final List<pem.MainNodeData> mainNodeData;
  final List<String> images;
  final List<CoverageModel> proCoverage;
  final List<ColorModel> colors;
  final List<WarrantiesModel> proCoverageModel;
  final List<ProductRecommands> productRecommands;
  final List<GetZipCodeList> getZipCodeListSearch;
  final List<GetZipCodeList> getZipCodeList;
  final bool isInStoreLoading;
  final bool showDesc;
  final bool expandBundle;
  final bool expandColor;
  final bool expandEligibility;
  final bool expandCoverage;

  ProductDetailState copyWith({
    ProductDetailStatus? productDetailStatus,
    String? message,
    String? currentImage,
    String? orderId,
    String? orderLineItemId,
    String? currentCondition,
    List<Warranties>? currentProCoverage,
    List<Records>? records,
    List<pem.MoreInfo>? moreInfo,
    List<pem.MainNodeData>? mainNodeData,
    List<Records>? productsInCart,
    List<ColorModel>? currentColor,
    List<ProductRecommands>? productRecommands,
    List<String>? images,
    List<CoverageModel>? proCoverage,
    List<ColorModel>? colors,
    List<WarrantiesModel>? proCoverageModel,
    List<GetZipCodeList>? getZipCodeListSearch,
    List<GetZipCodeList>? getZipCodeList,
    bool? isInStoreLoading,
    bool? fetchEligibility,
    bool? showDesc,
    bool? loadingBundles,
    bool? expandBundle,
    bool? expandColor,
    bool? expandEligibility,
    bool? expandCoverage,
    bool? isUpdating,
    String? updateID,
  }) {
    return ProductDetailState(
        productDetailStatus: productDetailStatus ?? this.productDetailStatus,
        currentImage: currentImage ?? this.currentImage,
        expandEligibility: expandEligibility ?? this.expandEligibility,
        fetchEligibility: fetchEligibility ?? this.fetchEligibility,
        productRecommands: productRecommands ?? this.productRecommands,
        moreInfo: moreInfo ?? this.moreInfo,
        orderLineItemId: orderLineItemId ?? this.orderLineItemId,
        mainNodeData: mainNodeData ?? this.mainNodeData,
        records: records ?? this.records,
        message: message ?? this.message,
        orderId: orderId ?? this.orderId,
        loadingBundles: loadingBundles ?? this.loadingBundles,
        productsInCart: productsInCart ?? this.productsInCart,
        currentCondition: currentCondition ?? this.currentCondition,
        currentProCoverage: currentProCoverage ?? this.currentProCoverage,
        currentColor: currentColor ?? this.currentColor,
        images: images ?? this.images,
        isUpdating: isUpdating ?? this.isUpdating,
        updateID: updateID ?? this.updateID,
        proCoverage: proCoverage ?? this.proCoverage,
        colors: colors ?? this.colors,
        proCoverageModel: proCoverageModel ?? this.proCoverageModel,
        getZipCodeListSearch: getZipCodeListSearch ?? this.getZipCodeListSearch,
        getZipCodeList: getZipCodeList ?? this.getZipCodeList,
        isInStoreLoading: isInStoreLoading ?? this.isInStoreLoading,
        showDesc: showDesc ?? this.showDesc,
        expandBundle: expandBundle ?? this.expandBundle,
        expandColor: expandColor ?? this.expandColor,
        expandCoverage: expandCoverage ?? this.expandCoverage);
  }

  @override
  List<Object> get props => [
    orderId,
    orderLineItemId,
        expandCoverage,
        expandColor,
    expandEligibility,
        expandBundle,
    fetchEligibility,
    moreInfo,
        showDesc,
    mainNodeData,
        isInStoreLoading,
    productRecommands,
    loadingBundles,
        getZipCodeList,
        getZipCodeListSearch,
        proCoverageModel,
        message,
        colors,
        proCoverage,
        images,
        records,
        isUpdating,
        updateID,
        productsInCart,
        currentColor,
        currentProCoverage,
        currentCondition,
        currentImage,
        productDetailStatus
      ];
}
