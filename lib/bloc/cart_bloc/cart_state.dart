part of 'cart_bloc.dart';

enum CartStatus { initState, loadState, successState, failedState }

enum CartSaveCustomerStatus { saving, notSaving }

class CartState extends Equatable {
  CartState(
      {this.cartStatus = CartStatus.initState,
      this.saveCustomerStatus = CartSaveCustomerStatus.notSaving,
      this.orderDetailModel = const [],
      this.mainNodeData = const [],
      this.maxExtent = 0.385,
      this.minExtent = 0.2,
      this.initialExtent = 0.2,
      this.isExpanded = false,
      this.overrideReasons = const [],
      this.isOverrideLoading = true,
      this.selectedAddressIndex = 0,
      this.isOverrideSubmitting = false,
      this.isCouponSubmitDone = false,
      this.savingAddress = false,
      this.selectedOverrideReasons = "",
      this.selectedState = "",
      this.recommendedAddress = "",
      this.pickUpStoreId = "",
      this.selectedCity = "",
      this.orderAddress = "",
      this.proceedingOrder = false,
      this.newCustomerAdded = false,
      this.cartPopupMenu = const [],
      this.numberOfCartItems = "0",
      this.cardHolderName = "",
      this.expiryMonth = "",
      this.expiryYear = "",
      this.cardNumber = "",
      this.cardAmount = "",
      this.addCardAmount = "",
      this.heading = "",
      this.address = "",
      this.city = "",
      this.state = "",
      this.zipCode = "",
      this.pickUpZip = "",
      this.showAmount = false,
      this.isUpdating = false,
      this.submitQuoteDone = false,
      this.submittingQuote = false,
      this.showMessageField = false,
      this.updateID = "",
      this.currentQuoteID = "",
      this.sameAsBilling = true,
      this.isDefaultAddress = true,
      this.addAddress = false,
      this.showAddCard = false,
      this.fetchingReason = false,
      this.loadingScreen = false,
      this.fetchMoreInfo = false,
      this.callCompleteOrder = false,
      this.obscureCardNumber = true,
      this.cvvCode = "",
      this.selectedReason = "",
      this.recommendedAddressLine1 = "",
      this.recommendedLabel = "",
      this.recommendedContactPointAddressId = "",
      this.recommendedAddressLine2 = "",
      this.recommendedAddressLineCity = "",
      this.recommendedAddressLineCountry = "",
      this.recommendedAddressLineState = "",
      this.recommendedAddressLineZipCode = "",
      this.orderAddressLine1 = "",
      this.orderLabel = "",
      this.orderContactPointAddressId = "",
      this.orderAddressLine2 = "",
      this.orderAddressLineCity = "",
      this.orderAddressLineCountry = "",
      this.orderAddressLineState = "",
      this.orderAddressLineZipCode = "",
      this.reasonList = const [],
      this.updateIndex = 2,
      this.moreInfo = const [],
      this.cardType = "",
      this.message = "",
      this.subtotal = 0.0,
      this.proCoverage = 0.0,
      this.total = 0.0,
      this.overrideDiscount = 0.0,
      this.isCvvFocused = false,
      this.showRecommendedDialog = false,
      this.addressModel = const [],
      this.deliveryModels = const [],
      this.activeStep = 0,
      this.creditCardModelSave = const [],
      this.hasChanges = false,
      this.deleteDone = false,
      this.fetchingAddresses = false,
      this.smallLoading = false,
      this.smallLoadingId = "",
      this.selectedAddress1 = "",
      this.selectedAddress2 = "",
      this.selectedAddressCity = "",
      this.selectedAddressState = "",
      this.selectedAddressPostalCode = "",
      this.addressDone = false,
      this.appliedCouponDiscount = const [],
      this.selectedPickupStore,
      this.shippingFormKey,
      this.shippingFName = "",
      this.shippingLName = "",
      this.shippingPhone = "",
      this.shippingEmail = "",
      this.selectedPickupStoreList,
      this.customerInfoModel,
      this.isContactMissing = false});

  final CartStatus cartStatus;
  final CartSaveCustomerStatus saveCustomerStatus;
  final List<String> overrideReasons;
  final bool isOverrideLoading;
  final bool fetchingAddresses;
  final bool isOverrideSubmitting;
  final bool isCouponSubmitDone;
  final bool showRecommendedDialog;
  final String selectedOverrideReasons;
  final String currentQuoteID;
  final String orderAddress;
  final String recommendedAddress;
  final String recommendedAddressLine1;
  final String recommendedLabel;
  final String recommendedContactPointAddressId;
  final String recommendedAddressLine2;
  final String recommendedAddressLineCity;
  final String recommendedAddressLineState;
  final String recommendedAddressLineCountry;
  final String recommendedAddressLineZipCode;
  final String orderAddressLine1;
  final String orderLabel;
  final String orderContactPointAddressId;
  final String orderAddressLine2;
  final String orderAddressLineCity;
  final String orderAddressLineState;
  final String orderAddressLineCountry;
  final String orderAddressLineZipCode;
  final List<OrderDetail> orderDetailModel;
  final List<MoreInfo> moreInfo;
  final List<MainNodeData> mainNodeData;
  final double maxExtent;
  final int selectedAddressIndex;
  final double minExtent;
  final double initialExtent;
  final bool isExpanded;
  final bool submitQuoteDone;
  final bool submittingQuote;
  final bool showMessageField;
  final bool smallLoading;
  final String smallLoadingId;
  final bool addressDone;
  final String selectedState;
  final String selectedCity;
  final bool isUpdating;
  final bool deleteDone;
  final String updateID;
  final bool proceedingOrder;
  final bool fetchMoreInfo;
  final bool callCompleteOrder;
  final List<CartPopupMenu> cartPopupMenu;
  final int updateIndex;
  final String numberOfCartItems;
  final String cardHolderName;
  final String expiryMonth;
  final String expiryYear;
  final String cardNumber;
  final String cardAmount;
  final String addCardAmount;
  final String heading;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String pickUpZip;
  final String message;
  final bool showAmount;
  final bool newCustomerAdded;
  final bool sameAsBilling;
  final bool isDefaultAddress;
  final bool addAddress;
  final bool showAddCard;
  final bool obscureCardNumber;
  final bool loadingScreen;
  final String cvvCode;
  final String cardType;
  final bool isCvvFocused;
  final bool savingAddress;
  final List<AddressList> addressModel;
  final String selectedAddress1;
  final String selectedAddress2;
  final String selectedAddressCity;
  final String selectedAddressState;
  final String selectedAddressPostalCode;
  final List<DeliveryModel> deliveryModels;
  final int activeStep;
  List<CreditCardModelSave> creditCardModelSave;
  final List<String> reasonList;
  final String selectedReason;
  final bool fetchingReason;
  final bool hasChanges;
  final double subtotal;
  final double proCoverage;
  final double total;
  final double overrideDiscount;
  final List<DiscountModel> appliedCouponDiscount;
  final SearchStoreListInformation? selectedPickupStore;
  final SearchStoreList? selectedPickupStoreList;
  final String? pickUpStoreId;
  final GlobalKey<FormState>? shippingFormKey;
  final String shippingFName;
  final String shippingLName;
  final String shippingPhone;
  final String shippingEmail;
  final bool isContactMissing;
  final cim.CustomerInfoModel? customerInfoModel;
  CartState copyWith(
      {CartStatus? cartStatus,
      CartSaveCustomerStatus? saveCustomerStatus,
      String? selectedAddress1,
      String? selectedAddress2,
      String? selectedAddressCity,
      String? selectedAddressState,
      String? selectedAddressPostalCode,
      List<OrderDetail>? orderDetailModel,
      List<String>? overrideReasons,
      List<MoreInfo>? moreInfo,
      List<MainNodeData>? mainNodeData,
      bool? fetchMoreInfo,
      bool? isOverrideLoading,
      int? selectedAddressIndex,
      bool? fetchingAddresses,
      bool? savingAddress,
      bool? isOverrideSubmitting,
      bool? callCompleteOrder,
      bool? isCouponSubmitDone,
      bool? showMessageField,
      String? selectedOverrideReasons,
      cim.CustomerInfoModel? customerInfoModel,
      String? recommendedAddress,
      String? pickUpStoreId,
      bool? newCustomerAdded,
      String? orderAddress,
      double? maxExtent,
      double? minExtent,
      double? subtotal,
      double? proCoverage,
      double? total,
      double? overrideDiscount,
      bool? isExpanded,
      bool? deleteDone,
      bool? showRecommendedDialog,
      bool? loadingScreen,
      bool? submittingQuote,
      bool? submitQuoteDone,
      double? initialExtent,
      String? selectedState,
      String? selectedCity,
      bool? proceedingOrder,
      String? recommendedLabel,
      String? recommendedContactPointAddressId,
      String? recommendedAddressLine1,
      String? recommendedAddressLine2,
      String? recommendedAddressLineCity,
      String? recommendedAddressLineState,
      String? recommendedAddressLineCountry,
      String? recommendedAddressLineZipCode,
      String? orderLabel,
      String? orderContactPointAddressId,
      String? orderAddressLine1,
      String? orderAddressLine2,
      String? orderAddressLineCity,
      String? orderAddressLineState,
      String? orderAddressLineCountry,
      String? orderAddressLineZipCode,
      bool? isUpdating,
      String? updateID,
      String? message,
      List<CartPopupMenu>? cartPopupMenu,
      String? numberOfCartItems,
      String? cardHolderName,
      String? expiryMonth,
      String? currentQuoteID,
      String? expiryYear,
      String? cardNumber,
      String? cardAmount,
      String? addCardAmount,
      String? heading,
      String? address,
      String? city,
      String? state,
      String? zipCode,
      String? pickUpZip,
      bool? showAmount,
      bool? sameAsBilling,
      bool? isDefaultAddress,
      bool? addAddress,
      bool? showAddCard,
      bool? obscureCardNumber,
      String? cvvCode,
      String? cardType,
      bool? isCvvFocused,
      List<AddressList>? addressModel,
      List<DeliveryModel>? deliveryModels,
      int? activeStep,
      List<CreditCardModelSave>? creditCardModelSave,
      bool? hasChanges,
      List<String>? reasonList,
      String? selectedReason,
      bool? fetchingReason,
      List<DiscountModel>? appliedCouponDiscount,
      int? updateIndex,
      SearchStoreListInformation? selectedPickupStore,
      SearchStoreList? selectedPickupStoreList,
      bool? smallLoading,
      String? smallLoadingId,
      GlobalKey<FormState>? shippingFormKey,
      String? shippingFName,
      String? shippingLName,
      String? shippingPhone,
      String? shippingEmail,
      bool? addressDone,
      bool? isContactMissing}) {
    return CartState(
      shippingEmail: shippingEmail ?? this.shippingEmail,
      customerInfoModel: customerInfoModel ?? this.customerInfoModel,
      pickUpStoreId: pickUpStoreId ?? this.pickUpStoreId,
      shippingPhone: shippingPhone ?? this.shippingPhone,
      shippingLName: shippingLName ?? this.shippingLName,
      shippingFName: shippingFName ?? this.shippingFName,
      shippingFormKey: shippingFormKey ?? this.shippingFormKey,
      selectedAddress1: selectedAddress1 ?? this.selectedAddress1,
      saveCustomerStatus: saveCustomerStatus ?? this.saveCustomerStatus,
      selectedAddress2: selectedAddress2 ?? this.selectedAddress2,
      selectedAddressCity: selectedAddressCity ?? this.selectedAddressCity,
      selectedAddressState: selectedAddressState ?? this.selectedAddressState,
      selectedAddressPostalCode:
          selectedAddressPostalCode ?? this.selectedAddressPostalCode,
      updateIndex: updateIndex ?? this.updateIndex,
      smallLoading: smallLoading ?? this.smallLoading,
      smallLoadingId: smallLoadingId ?? this.smallLoadingId,
      addressDone: addressDone ?? this.addressDone,
      newCustomerAdded: newCustomerAdded ?? this.newCustomerAdded,
      recommendedAddressLine1:
          recommendedAddressLine1 ?? this.recommendedAddressLine1,
      recommendedLabel: recommendedLabel ?? this.recommendedLabel,
      recommendedContactPointAddressId: recommendedContactPointAddressId ??
          this.recommendedContactPointAddressId,
      recommendedAddressLine2:
          recommendedAddressLine2 ?? this.recommendedAddressLine2,
      recommendedAddressLineCity:
          recommendedAddressLineCity ?? this.recommendedAddressLineCity,
      recommendedAddressLineState:
          recommendedAddressLineState ?? this.recommendedAddressLineState,
      recommendedAddressLineCountry:
          recommendedAddressLineCountry ?? this.recommendedAddressLineCountry,
      recommendedAddressLineZipCode:
          recommendedAddressLineZipCode ?? this.recommendedAddressLineZipCode,
      orderAddressLine1: orderAddressLine1 ?? this.orderAddressLine1,
      orderLabel: orderLabel ?? this.orderLabel,
      orderContactPointAddressId:
          orderContactPointAddressId ?? this.orderContactPointAddressId,
      orderAddressLine2: orderAddressLine2 ?? this.orderAddressLine2,
      orderAddressLineCity: orderAddressLineCity ?? this.orderAddressLineCity,
      orderAddressLineState:
          orderAddressLineState ?? this.orderAddressLineState,
      orderAddressLineCountry:
          orderAddressLineCountry ?? this.orderAddressLineCountry,
      orderAddressLineZipCode:
          orderAddressLineZipCode ?? this.orderAddressLineZipCode,
      cartStatus: cartStatus ?? this.cartStatus,
      callCompleteOrder: callCompleteOrder ?? this.callCompleteOrder,
      showRecommendedDialog:
          showRecommendedDialog ?? this.showRecommendedDialog,
      mainNodeData: mainNodeData ?? this.mainNodeData,
      fetchingAddresses: fetchingAddresses ?? this.fetchingAddresses,
      recommendedAddress: recommendedAddress ?? this.recommendedAddress,
      reasonList: reasonList ?? this.reasonList,
      selectedReason: selectedReason ?? this.selectedReason,
      fetchingReason: fetchingReason ?? this.fetchingReason,
      subtotal: subtotal ?? this.subtotal,
      proCoverage: proCoverage ?? this.proCoverage,
      total: total ?? this.total,
      deleteDone: deleteDone ?? this.deleteDone,
      loadingScreen: loadingScreen ?? this.loadingScreen,
      showMessageField: showMessageField ?? this.showMessageField,
      overrideDiscount: overrideDiscount ?? this.overrideDiscount,
      currentQuoteID: currentQuoteID ?? this.currentQuoteID,
      submitQuoteDone: submitQuoteDone ?? this.submitQuoteDone,
      submittingQuote: submittingQuote ?? this.submittingQuote,
      maxExtent: maxExtent ?? this.maxExtent,
      selectedAddressIndex: selectedAddressIndex ?? this.selectedAddressIndex,
      overrideReasons: overrideReasons ?? this.overrideReasons,
      isOverrideLoading: isOverrideLoading ?? this.isOverrideLoading,
      isOverrideSubmitting: isOverrideSubmitting ?? this.isOverrideSubmitting,
      isCouponSubmitDone: isCouponSubmitDone ?? this.isCouponSubmitDone,
      selectedOverrideReasons:
          selectedOverrideReasons ?? this.selectedOverrideReasons,
      message: message ?? this.message,
      minExtent: minExtent ?? this.minExtent,
      isExpanded: isExpanded ?? this.isExpanded,
      isUpdating: isUpdating ?? this.isUpdating,
      updateID: updateID ?? this.updateID,
      initialExtent: initialExtent ?? this.initialExtent,
      orderDetailModel: orderDetailModel ?? this.orderDetailModel,
      selectedState: selectedState ?? this.selectedState,
      selectedCity: selectedCity ?? this.selectedCity,
      proceedingOrder: proceedingOrder ?? this.proceedingOrder,
      cartPopupMenu: cartPopupMenu ?? this.cartPopupMenu,
      numberOfCartItems: numberOfCartItems ?? this.numberOfCartItems,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cardNumber: cardNumber ?? this.cardNumber,
      cardAmount: cardAmount ?? this.cardAmount,
      addCardAmount: addCardAmount ?? this.addCardAmount,
      heading: heading ?? this.heading,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      pickUpZip: pickUpZip ?? this.pickUpZip,
      orderAddress: orderAddress ?? this.orderAddress,
      showAmount: showAmount ?? this.showAmount,
      sameAsBilling: sameAsBilling ?? this.sameAsBilling,
      isDefaultAddress: isDefaultAddress ?? this.isDefaultAddress,
      addAddress: addAddress ?? this.addAddress,
      showAddCard: showAddCard ?? this.showAddCard,
      obscureCardNumber: obscureCardNumber ?? this.obscureCardNumber,
      cvvCode: cvvCode ?? this.cvvCode,
      moreInfo: moreInfo ?? this.moreInfo,
      cardType: cardType ?? this.cardType,
      isCvvFocused: isCvvFocused ?? this.isCvvFocused,
      addressModel: addressModel ?? this.addressModel,
      fetchMoreInfo: fetchMoreInfo ?? this.fetchMoreInfo,
      deliveryModels: deliveryModels ?? this.deliveryModels,
      activeStep: activeStep ?? this.activeStep,
      creditCardModelSave: creditCardModelSave ?? this.creditCardModelSave,
      hasChanges: hasChanges ?? this.hasChanges,
      savingAddress: savingAddress ?? this.savingAddress,
      appliedCouponDiscount:
          appliedCouponDiscount ?? this.appliedCouponDiscount,
      selectedPickupStore: selectedPickupStore ?? this.selectedPickupStore,
      selectedPickupStoreList:
          selectedPickupStoreList ?? this.selectedPickupStoreList,
      isContactMissing: isContactMissing ?? this.isContactMissing,
    );
  }

  @override
  List<Object?> get props => [
        selectedPickupStore,
        selectedPickupStoreList,
        pickUpStoreId,
        shippingFormKey,
        shippingFName,
    customerInfoModel,
        shippingLName,
        shippingPhone,
        shippingEmail,
        updateIndex,
        newCustomerAdded,
        recommendedAddressLine1,
        recommendedLabel,
        recommendedContactPointAddressId,
        recommendedAddressLine2,
        recommendedAddressLineCity,
        recommendedAddressLineCountry,
        recommendedAddressLineState,
        recommendedAddressLineZipCode,
        orderAddressLine1,
        orderLabel,
        orderContactPointAddressId,
        orderAddressLine2,
        orderAddressLineCity,
        orderAddressLineCountry,
        orderAddressLineState,
        orderAddressLineZipCode,
        cartStatus,
        saveCustomerStatus,
        mainNodeData,
        maxExtent,
        showRecommendedDialog,
        minExtent,
        overrideDiscount,
        recommendedAddress,
        subtotal,
        proCoverage,
        overrideDiscount,
        orderAddress,
        isExpanded,
        initialExtent,
        orderDetailModel,
        selectedState,
        deleteDone,
        selectedCity,
        fetchMoreInfo,
        moreInfo,
        showMessageField,
        loadingScreen,
        callCompleteOrder,
        savingAddress,
        currentQuoteID,
        fetchingAddresses,
        submittingQuote,
        reasonList,
        selectedReason,
        fetchingReason,
        submitQuoteDone,
        overrideReasons,
        isOverrideLoading,
        isOverrideSubmitting,
        isCouponSubmitDone,
        selectedOverrideReasons,
        proceedingOrder,
        cartPopupMenu,
        numberOfCartItems,
        cardHolderName,
        expiryMonth,
        expiryYear,
        cardNumber,
        updateID,
        isUpdating,
        cardAmount,
        addCardAmount,
        heading,
        address,
        city,
        state,
        zipCode,
        message,
        pickUpZip,
        showAmount,
        sameAsBilling,
        isDefaultAddress,
        addAddress,
        showAddCard,
        obscureCardNumber,
        cvvCode,
        cardType,
        isCvvFocused,
        selectedAddressIndex,
        addressModel,
        deliveryModels,
        activeStep,
        creditCardModelSave,
        hasChanges,
        appliedCouponDiscount,
        smallLoading,
        smallLoadingId,
        addressDone,
        selectedAddress1,
        selectedAddress2,
        selectedAddressCity,
        selectedAddressState,
        selectedAddressPostalCode,
        isContactMissing,
      ];
}
