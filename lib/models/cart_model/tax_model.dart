import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';

class TaxCalculateModel {
  GcOrder? gcOrder;
  OrderDetail? orderDetail;
  List<ShippingMethod>? shippingMethod;



  TaxCalculateModel({this.gcOrder,this.shippingMethod,this.orderDetail});

  TaxCalculateModel.fromJson(Map<String, dynamic> json) {
    if (json['ShippingMethod'] != null) {
      shippingMethod = <ShippingMethod>[];
      json['ShippingMethod'].forEach((v) {
        shippingMethod!.add(new ShippingMethod.fromJson(v));
      });
    }
    else{
      shippingMethod = [];
    }
    orderDetail = json['OrderDetail'] != null
        ? OrderDetail.fromJson(json['OrderDetail'])
        : null;
    gcOrder = json['gcOrder'] != null ? new GcOrder.fromJson(json['gcOrder']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.gcOrder != null) {
      data['gcOrder'] = this.gcOrder!.toJson();
    }
    if (this.shippingMethod != null) {
      data['ShippingMethod'] =
          this.shippingMethod!.map((v) => v.toJson()).toList();
    }
    if (this.orderDetail != null) {
      data['OrderDetail'] = this.orderDetail!.toJson();
    }
    return data;
  }
}

class ShippingMethod {
  String? values;
  String? label;

  ShippingMethod({this.values, this.label});

  ShippingMethod.fromJson(Map<String, dynamic> json) {
    values = json['values'];
    label = json['Label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['values'] = this.values;
    data['Label'] = this.label;
    return data;
  }
}

class GcOrder {
  Attributes? attributes;
  String? id;
  String? deliveryOptionC;
  String? firstNameC;
  String? lastNameC;
  String? shippingAddressC;
  String? shippingAddress2C;
  String? shippingCityC;
  String? shippingStateC;
  String? siteIdC;
  double? paymentMethodTotalC;
  String? shippingCountryC;
  String? shippingZipCodeC;
  String? customerC;
  String? phoneC;
  String? shippingMethodC;
  String? shippingMethodNumberC;
  double? shippingAndHandlingC;
  double? taxC;
  double? discountC;
  String? brandCodeC;
  String? orderNumberC;
  String? sourceCodeC;
  String? shippingEmailC;
  bool? taxExemptC;
  double? shippingFeeC;
  double? shippingTaxC;
  String? discountTypeC;
  bool? deliveryFeeEligibleC;
  double? totalC;
  double? finalAmountC;
  String? createdDate;
  String? lastModifiedDate;
  String? orderStatusC;
  double? unAppliedDiscountTotalC;
  double? quoteAmountC;
  double? shippingTotalC;
  String? levelOfServiceC;
  String? channelC;
  double? totalDiscountC;
  String? orderingStoreC;
  String? quoteNumberC;
  String? orderEmployeeC;
  String? accountIdC;

  GcOrder(
      {this.attributes,
        this.id,
        this.deliveryOptionC,
        this.firstNameC,
        this.lastNameC,
        this.shippingAddressC,
        this.shippingAddress2C,
        this.shippingCityC,
        this.shippingStateC,
        this.siteIdC,
        this.paymentMethodTotalC,
        this.shippingCountryC,
        this.shippingZipCodeC,
        this.customerC,
        this.phoneC,
        this.shippingMethodC,
        this.shippingMethodNumberC,
        this.shippingAndHandlingC,
        this.taxC,
        this.discountC,
        this.brandCodeC,
        this.orderNumberC,
        this.sourceCodeC,
        this.shippingEmailC,
        this.taxExemptC,
        this.shippingFeeC,
        this.shippingTaxC,
        this.discountTypeC,
        this.deliveryFeeEligibleC,
        this.totalC,
        this.finalAmountC,
        this.createdDate,
        this.lastModifiedDate,
        this.orderStatusC,
        this.unAppliedDiscountTotalC,
        this.quoteAmountC,
        this.shippingTotalC,
        this.levelOfServiceC,
        this.channelC,
        this.totalDiscountC,
        this.orderingStoreC,
        this.quoteNumberC,
        this.orderEmployeeC,
        this.accountIdC});

  GcOrder.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    deliveryOptionC = json['Delivery_Option__c'];
    firstNameC = json['First_Name__c'];
    lastNameC = json['Last_Name__c'];
    shippingAddressC = json['Shipping_Address__c'];
    shippingAddress2C = json['Shipping_Address_2__c'];
    shippingCityC = json['Shipping_City__c'];
    shippingStateC = json['Shipping_State__c'];
    siteIdC = json['Site_Id__c'];
    paymentMethodTotalC = json['Payment_Method_Total__c'];
    shippingCountryC = json['Shipping_Country__c'];
    shippingZipCodeC = json['Shipping_Zip_code__c'];
    customerC = json['Customer__c'];
    phoneC = json['Phone__c'];
    shippingMethodC = json['Shipping_Method__c'];
    shippingMethodNumberC = json['Shipping_Method_Number__c'];
    shippingAndHandlingC = json['Shipping_and_Handling__c'];
    taxC = json['Tax__c'];
    discountC = json['Discount__c'];
    brandCodeC = json['Brand_Code__c'];
    orderNumberC = json['Order_Number__c'];
    sourceCodeC = json['Source_Code__c'];
    shippingEmailC = json['Shipping_Email__c'];
    taxExemptC = json['Tax_Exempt__c'];
    shippingFeeC = json['Shipping_Fee__c'];
    shippingTaxC = json['Shipping_Tax__c'];
    discountTypeC = json['Discount_Type__c'];
    deliveryFeeEligibleC = json['DeliveryFeeEligible__c'];
    totalC = json['Total__c'];
    finalAmountC = json['Final_Amount__c'];
    createdDate = json['CreatedDate'];
    lastModifiedDate = json['LastModifiedDate'];
    orderStatusC = json['Order_Status__c'];
    unAppliedDiscountTotalC = json['UnAppliedDiscountTotal__c'];
    quoteAmountC = json['QuoteAmount__c'];
    orderNumberC = json['OrderNumber__c'];
    shippingTotalC = json['ShippingTotal__c'];
    levelOfServiceC = json['LevelOfService__c'];
    channelC = json['Channel__c'];
    totalDiscountC = json['Total_Discount__c'];
    orderingStoreC = json['OrderingStore__c'];
    quoteNumberC = json['QuoteNumber__c'];
    orderEmployeeC = json['OrderEmployee__c'];
    accountIdC = json['accountId__c'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['Delivery_Option__c'] = this.deliveryOptionC;
    data['First_Name__c'] = this.firstNameC;
    data['Last_Name__c'] = this.lastNameC;
    data['Shipping_Address__c'] = this.shippingAddressC;
    data['Shipping_Address_2__c'] = this.shippingAddress2C;
    data['Shipping_City__c'] = this.shippingCityC;
    data['Shipping_State__c'] = this.shippingStateC;
    data['Site_Id__c'] = this.siteIdC;
    data['Payment_Method_Total__c'] = this.paymentMethodTotalC;
    data['Shipping_Country__c'] = this.shippingCountryC;
    data['Shipping_Zip_code__c'] = this.shippingZipCodeC;
    data['Customer__c'] = this.customerC;
    data['Phone__c'] = this.phoneC;
    data['Shipping_Method__c'] = this.shippingMethodC;
    data['Shipping_Method_Number__c'] = this.shippingMethodNumberC;
    data['Shipping_and_Handling__c'] = this.shippingAndHandlingC;
    data['Tax__c'] = this.taxC;
    data['Discount__c'] = this.discountC;
    data['Brand_Code__c'] = this.brandCodeC;
    data['Order_Number__c'] = this.orderNumberC;
    data['Source_Code__c'] = this.sourceCodeC;
    data['Shipping_Email__c'] = this.shippingEmailC;
    data['Tax_Exempt__c'] = this.taxExemptC;
    data['Shipping_Fee__c'] = this.shippingFeeC;
    data['Shipping_Tax__c'] = this.shippingTaxC;
    data['Discount_Type__c'] = this.discountTypeC;
    data['DeliveryFeeEligible__c'] = this.deliveryFeeEligibleC;
    data['Total__c'] = this.totalC;
    data['Final_Amount__c'] = this.finalAmountC;
    data['CreatedDate'] = this.createdDate;
    data['LastModifiedDate'] = this.lastModifiedDate;
    data['Order_Status__c'] = this.orderStatusC;
    data['UnAppliedDiscountTotal__c'] = this.unAppliedDiscountTotalC;
    data['QuoteAmount__c'] = this.quoteAmountC;
    data['OrderNumber__c'] = this.orderNumberC;
    data['ShippingTotal__c'] = this.shippingTotalC;
    data['LevelOfService__c'] = this.levelOfServiceC;
    data['Channel__c'] = this.channelC;
    data['Total_Discount__c'] = this.totalDiscountC;
    data['OrderingStore__c'] = this.orderingStoreC;
    data['QuoteNumber__c'] = this.quoteNumberC;
    data['OrderEmployee__c'] = this.orderEmployeeC;
    data['accountId__c'] = this.accountIdC;
    return data;
  }
}

class Attributes extends Equatable {
  String? type;
  String? url;

  Attributes({this.type, this.url});

  Attributes.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['url'] = this.url;
    return data;
  }

  @override
  List<Object?> get props => [type, url];
}

class OrderDetail extends Equatable {
  double? total;
  bool? taxExempt;
  double? tax;
  double? subtotal;
  String? storeId;
  OrderStore? orderStore;
  OrderStoreInfo? orderStoreInfo;
  String? sourceCode;
  String? shippingZipcode;
  double? shippingTax;
  String? shippingState;
  String? shippingMethodNumber;
  String? shippingMethod;
  double? shippingFee;
  String? shippingEmail;
  String? shippingCountry;
  String? shippingCity;
  double? shippingAndHandling;
  List<PaymentMethods>? paymentMethods;
  double? shippingAdjustment;
  String? shippingAddress2;
  String? shippingAddress;
  String? shipmentOverrideReason;
  String? selectedStoreCity;
  String? phone;
  double? paymentMethodTotal;
  String? orderOverrideReason;
  String? orderNumber;
  String? orderDate;
  String? orderCreatedDate;
  String? orderApprovalRequest;
  String? orderAdjustment;
  String? middleName;
  String? lastname;
  List<Items>? items;
  String? firstName;
  String? discountType;
  String? discounts;
  String? discountCodes;
  String? discountCode;
  double? discount;
  double? totalDiscount;
  double? totalLineDiscount;
  String? deliveryOption;
  bool? deliveryFeeEligible;
  String? customerId;
  String? brandCode;
  String? billingZipcode;
  String? billingState;
  String? billingPhone;
  String? billingEmail;
  String? billingCountry;
  String? billingCity;
  String? billingAddress2;
  String? billingAddress;
  String? approvalRequest;
  String? orderStatus;

  OrderDetail(
      {
        this.total,
        this.taxExempt,
        this.tax,
        this.subtotal,
        this.storeId,
        this.sourceCode,
        this.shippingZipcode,
        this.shippingTax,
        this.shippingState,
        this.shippingMethodNumber,
        this.shippingMethod,
        this.shippingFee,
        this.orderStore,
        this.orderStoreInfo,
        this.shippingEmail,
        this.shippingCountry,
        this.shippingCity,
        this.shippingAndHandling,
        this.paymentMethods,
        this.shippingAdjustment,
        this.shippingAddress2,
        this.shippingAddress,
        this.shipmentOverrideReason,
        this.selectedStoreCity,
        this.phone,
        this.paymentMethodTotal,
        this.orderOverrideReason,
        this.orderNumber,
        this.orderDate,
        this.orderCreatedDate,
        this.orderApprovalRequest,
        this.orderAdjustment,
        this.middleName,
        this.lastname,
        this.items,
        this.firstName,
        this.discountType,
        this.discounts,
        this.discountCodes,
        this.discountCode,
        this.discount,
        this.totalDiscount,
        this.totalLineDiscount,
        this.deliveryOption,
        this.deliveryFeeEligible,
        this.customerId,
        this.brandCode,
        this.billingZipcode,
        this.billingState,
        this.billingPhone,
        this.billingEmail,
        this.billingCountry,
        this.billingCity,
        this.billingAddress2,
        this.billingAddress,
        this.approvalRequest,
        this.orderStatus,
      });

  OrderDetail.fromJson(Map<String, dynamic> json) {
    total = json['Total'];
    taxExempt = json['TaxExempt'];
    tax = json['Tax'] ?? 0.0;
    subtotal = json['Subtotal'] ?? 0.0;
    storeId = json['StoreId'] ?? '';
    sourceCode = json['SourceCode'] ?? '';
    shippingZipcode = json['ShippingZipcode'] ?? '';
    shippingTax = json['ShippingTax'];
    shippingState = json['ShippingState'] ?? '';
    shippingMethodNumber = json['ShippingMethodNumber'] ?? '';
    shippingMethod = json['ShippingMethod'] ?? '';
    shippingFee = json['ShippingFee'];
    shippingEmail = json['ShippingEmail'] ?? '';
    shippingCountry = json['ShippingCountry'] ?? '';
    shippingCity = json['ShippingCity'] ?? '';
    shippingAndHandling = json['ShippingAndHandling'] ?? 0.0;
    if (json['PaymentMethods'] != null && json['PaymentMethods'].isNotEmpty) {
      paymentMethods = List.from(json['PaymentMethods'])
          .map((e) => PaymentMethods.fromJson(e))
          .toList();
    } else {
      paymentMethods = [];
    }
    shippingAdjustment = json['ShippingAdjustment'];
    shippingAddress2 = json['ShippingAddress2'] ?? '';
    shippingAddress = json['ShippingAddress'] ?? '';
    shipmentOverrideReason = json['ShipmentOverrideReason'] ?? '';
    selectedStoreCity = json['SelectedStoreCity'] ?? '';
    phone = json['Phone'] ?? '';
    orderStore = json['orderStore'] != null
        ? new OrderStore.fromJson(json['orderStore'])
        : null;
    orderStoreInfo = json['orderStoreInfo'] != null
        ? new OrderStoreInfo.fromJson(json['orderStoreInfo'])
        : null;
    paymentMethodTotal = json['PaymentMethodTotal'] ?? 0.00;
    orderOverrideReason = json['OrderOverrideReason'] ?? '';
    orderNumber = json['OrderNumber'] ?? '';
    orderDate = json['OrderDate'] ?? '';
    orderCreatedDate = json['OrderCreatedDate'] ?? '';
    orderApprovalRequest = json['OrderApprovalRequest'] ?? '';
    orderAdjustment = (json['OrderAdjustment'] ?? '').toString();
    middleName = json['MiddleName'] ?? '';
    lastname = json['Lastname'] ?? '';
    if (json['Items'] != null) {
      items = <Items>[];
      json['Items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    firstName = json['FirstName'] ?? '';
    discountType = json['DiscountType'] ?? '';
    discounts = json['Discounts'] ?? '';
    discountCodes = json['DiscountCodes'] ?? '';
    discountCode = json['DiscountCode'] ?? '';
    discount = json['Discount'] ?? 0.00;
    totalDiscount = json['TotalDiscount'] ?? 0.00;
    totalLineDiscount = json['TotalLineDiscount'] ?? 0.00;
    deliveryOption = json['DeliveryOption'] ?? '';
    deliveryFeeEligible = json['DeliveryFeeEligible'];
    customerId = json['CustomerId'] ?? '';
    brandCode = json['BrandCode'] ?? '';
    billingZipcode = json['BillingZipcode'] ?? '';
    billingState = json['BillingState'] ?? '';
    billingPhone = json['BillingPhone'] ?? '';
    billingEmail = json['BillingEmail'] ?? '';
    billingCountry = json['BillingCountry'] ?? '';
    billingCity = json['BillingCity'] ?? '';
    billingAddress2 = json['BillingAddress2'] ?? '';
    billingAddress = json['BillingAddress'] ?? '';
    approvalRequest = json['ApprovalRequest'] ?? "";
    orderStatus = json['OrderStatus'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Total'] = this.total;
    data['TaxExempt'] = this.taxExempt;
    data['Tax'] = this.tax;
    data['Subtotal'] = this.subtotal;
    data['StoreId'] = this.storeId;
    data['SourceCode'] = this.sourceCode;
    data['ShippingZipcode'] = this.shippingZipcode;
    data['ShippingTax'] = this.shippingTax;
    data['ShippingState'] = this.shippingState;
    data['ShippingMethodNumber'] = this.shippingMethodNumber;
    data['ShippingMethod'] = this.shippingMethod;
    data['ShippingFee'] = this.shippingFee;
    data['ShippingEmail'] = this.shippingEmail;
    data['ShippingCountry'] = this.shippingCountry;
    data['ShippingCity'] = this.shippingCity;
    data['ShippingAndHandling'] = this.shippingAndHandling;
    data['PaymentMethods'] = paymentMethods!.map((e) => e.toJson()).toList();
    data['ShippingAdjustment'] = this.shippingAdjustment;
    data['ShippingAddress2'] = this.shippingAddress2;
    data['ShippingAddress'] = this.shippingAddress;
    data['ShipmentOverrideReason'] = this.shipmentOverrideReason;
    data['SelectedStoreCity'] = this.selectedStoreCity;
    data['Phone'] = this.phone;
    data['PaymentMethodTotal'] = this.paymentMethodTotal;
    data['OrderOverrideReason'] = this.orderOverrideReason;
    data['OrderNumber'] = this.orderNumber;
    data['OrderDate'] = this.orderDate;
    data['OrderCreatedDate'] = this.orderCreatedDate;
    data['OrderApprovalRequest'] = this.orderApprovalRequest;
    data['OrderAdjustment'] = this.orderAdjustment;
    data['MiddleName'] = this.middleName;
    data['Lastname'] = this.lastname;
    if (this.items != null) {
      data['Items'] = this.items!.map((v) => v.toJson()).toList();
    }
    if (this.orderStore != null) {
      data['orderStore'] = this.orderStore!.toJson();
    }
    if (this.orderStoreInfo != null) {
      data['orderStoreInfo'] = this.orderStoreInfo!.toJson();
    }
    data['FirstName'] = this.firstName;
    data['DiscountType'] = this.discountType;
    data['Discounts'] = this.discounts;
    data['DiscountCodes'] = this.discountCodes;
    data['DiscountCode'] = this.discountCode;
    data['Discount'] = this.discount;
    data['TotalDiscount'] = this.totalDiscount;
    data['TotalLineDiscount'] = this.totalLineDiscount;
    data['DeliveryOption'] = this.deliveryOption;
    data['DeliveryFeeEligible'] = this.deliveryFeeEligible;
    data['CustomerId'] = this.customerId;
    data['BrandCode'] = this.brandCode;
    data['BillingZipcode'] = this.billingZipcode;
    data['BillingState'] = this.billingState;
    data['BillingPhone'] = this.billingPhone;
    data['BillingEmail'] = this.billingEmail;
    data['BillingCountry'] = this.billingCountry;
    data['BillingCity'] = this.billingCity;
    data['BillingAddress2'] = this.billingAddress2;
    data['BillingAddress'] = this.billingAddress;
    data['ApprovalRequest'] = this.approvalRequest;
    data['OrderStatus'] = this.orderStatus;
    return data;
  }

  @override
  List<Object?> get props => [
    total,
    taxExempt,
    tax,
    subtotal,
    storeId,
    sourceCode,
    shippingZipcode,
    shippingTax,
    shippingState,
    shippingMethodNumber,
    shippingMethod,
    shippingFee,
    orderStore,
    orderStoreInfo,
    shippingEmail,
    shippingCountry,
    shippingCity,
    shippingAndHandling,
    paymentMethods,
    shippingAdjustment,
    shippingAddress2,
    shippingAddress,
    shipmentOverrideReason,
    selectedStoreCity,
    phone,
    paymentMethodTotal,
    orderOverrideReason,
    orderNumber,
    orderDate,
    orderCreatedDate,
    orderApprovalRequest,
    orderAdjustment,
    middleName,
    lastname,
    items,
    firstName,
    discountType,
    discounts,
    discountCodes,
    discountCode,
    discount,
    totalDiscount,
    totalLineDiscount,
    deliveryOption,
    deliveryFeeEligible,
    customerId,
    brandCode,
    billingZipcode,
    billingState,
    billingPhone,
    billingEmail,
    billingCountry,
    billingCity,
    billingAddress2,
    billingAddress,
    approvalRequest,
    orderStatus,
  ];
}

class PaymentMethods extends Equatable {
  PaymentMethods({
    this.attributes,
    this.firstName_C,
    this.lastName_C,
    this.paymentMethod_C,
    this.lastCardNumber_C,
    this.order_C,
    this.address_C,
    this.amount_C,
    this.city_C,
    this.country_C,
    this.state_C,
    this.zipCode_C,
    this.id,
    this.name,
    this.isDeleted,
    this.phone_C,
  });
  Attributes? attributes;
  String? firstName_C;
  String? lastName_C;
  String? paymentMethod_C;
  String? lastCardNumber_C;
  String? order_C;
  String? address_C;
  double? amount_C;
  String? city_C;
  String? country_C;
  String? state_C;
  String? zipCode_C;
  String? id;
  String? name;
  bool? isDeleted;
  String? phone_C;

  PaymentMethods.fromJson(Map<String, dynamic> json) {
    attributes = Attributes.fromJson(json['attributes']);
    firstName_C = json['First_Name__c'] ?? '';
    lastName_C = json['Last_Name__c'] ?? '';
    paymentMethod_C = json['Payment_Method__c'] ?? '';
    lastCardNumber_C = json['Last_card_number__c'] ?? '';
    order_C = json['Order__c'] ?? '';
    address_C = json['Address__c'] ?? '';
    amount_C = json['Amount__c'] ?? 0.00;
    city_C = json['City__c'] ?? '';
    country_C = json['Country__c'] ?? '';
    state_C = json['State__c'] ?? '';
    zipCode_C = json['Zip_Code__c'] ?? '';
    id = json['Id'] ?? '';
    name = json['Name'] ?? '';
    isDeleted = json['IsDeleted'];
    phone_C = json['Phone__c'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['attributes'] = attributes!.toJson();
    _data['First_Name__c'] = firstName_C;
    _data['Last_Name__c'] = lastName_C;
    _data['Payment_Method__c'] = paymentMethod_C;
    _data['Last_card_number__c'] = lastCardNumber_C;
    _data['Order__c'] = order_C;
    _data['Address__c'] = address_C;
    _data['Amount__c'] = amount_C;
    _data['City__c'] = city_C;
    _data['Country__c'] = country_C;
    _data['State__c'] = state_C;
    _data['Zip_Code__c'] = zipCode_C;
    _data['Id'] = id;
    _data['Name'] = name;
    _data['IsDeleted'] = isDeleted;
    _data['Phone__c'] = phone_C;
    return _data;
  }

  @override
  List<Object?> get props => [
    attributes,
    firstName_C,
    lastName_C,
    paymentMethod_C,
    lastCardNumber_C,
    order_C,
    address_C,
    amount_C,
    city_C,
    country_C,
    state_C,
    zipCode_C,
    id,
    name,
    isDeleted,
    phone_C,
  ];
}



class Items extends Equatable {
  String? warrantyStyleDesc;
  String? warrantySkuId;
  double? warrantyPrice;
  String? warrantyId;
  String? warrantyDisplayName;
  double? unitPrice;
  double? quantity;
  List<Warranties>? warranties;
  String? pimSkuId;
  bool? isCartAdding;
  bool? isUpdatingCoverage;
  bool? isWarrantiesLoading;
  bool? isExpanded;
  bool? isOverridden;
  String? sourcingReason;
  String? reservationLocationStock;
  String? reservationLocation;

  ///used for custom switch
  String? overridePriceReason;
  String? overridePriceApproval;
  double? overridePrice;
  double? marginValue;
  double? margin;
  String? itemNumber;

  /// this is skuID
  String? itemId;

  /// this is oli Rec ID
  String? itemDesc;
  String? title;
  String? imageUrl;
  String? productId;
  String? posSkuId;
  String? condition;
  String? itemStatus;
  double? discountedMarginValue;
  double? discountedMargin;
  double? cost;
  String? purchasedPrice;
  String? sKU;

  Items(
      {
        this.unitPrice,
        this.quantity,
        this.warrantyStyleDesc,
        this.warrantySkuId,
        this.warrantyPrice,
        this.warrantyId,
        this.warrantyDisplayName,
        this.isUpdatingCoverage,
        this.warranties,
        this.sourcingReason,
        this.reservationLocationStock,
        this.reservationLocation,
        this.pimSkuId,
        this.isWarrantiesLoading,
        this.overridePriceReason,
        this.overridePriceApproval,
        this.overridePrice,
        this.marginValue,
        this.margin,
        this.itemNumber,
        this.itemId,
        this.itemDesc,
        this.title,
        this.imageUrl,
        this.discountedMarginValue,
        this.isCartAdding,
        this.isExpanded,
        this.discountedMargin,
        this.productId,
        this.posSkuId,
        this.condition,
        this.isOverridden,
        this.itemStatus,
        this.purchasedPrice,
        this.sKU,
        this.cost,
      });

  Items.fromJson(Map<String, dynamic> json) {
    unitPrice = json['UnitPrice'] ?? 0.0;
    pimSkuId = json['PimSkuId'] ?? "";
    quantity = json['Quantity'] ?? 0.0;
    overridePriceReason = json['OverridePriceReason'] ?? "";
    overridePriceApproval = json['OverridePriceApproval'] ?? "";
    overridePrice = json['OverridePrice'] ?? 0.0;
    marginValue = json['MarginValue'] ?? 0.0;
    margin = json['Margin'] ?? 0.0;
    itemNumber = json['ItemNumber'];
    itemId = json['ItemId'];
    itemDesc = json['ItemDesc'] ?? '';
    sourcingReason = json["SourcingReason"];
    reservationLocationStock = json["ReservationLocationStock"];
    reservationLocation = json["ReservationLocation"];
    title = json['Title'] ?? '';
    imageUrl = json['ImageUrl'];
    discountedMarginValue = json['DiscountedMarginValue'] ?? 0.0;
    discountedMargin = json['DiscountedMargin'] ?? 0.0;
    cost = json['Cost'] ?? 0.0;
    warrantyStyleDesc = json['WarrantyStyleDesc'] ?? "";
    warrantySkuId = json['WarrantySkuId'] ?? "";
    warrantyPrice = json['WarrantyPrice'] ?? 0.0;
    warrantyId = json['WarrantyId'] ?? "";
    warrantyDisplayName = json['WarrantyDisplayName'] ?? "";
    productId = json['ProductId'] ?? "";
    posSkuId = json['PosSkuId'] ?? "";
    condition = json['Condition'] ?? "";
    itemStatus = json['ItemStatus'] ?? "";
    warranties = [];
    isCartAdding = false;
    isUpdatingCoverage = false;
    isWarrantiesLoading = false;
    isExpanded = false;
    isOverridden = false;
    purchasedPrice = json['PurchasedPrice'];
    sKU = json['SKU'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['WarrantyStyleDesc'] = this.warrantyStyleDesc;
    data['ItemStatus'] = this.itemStatus;
    data['PosSkuId'] = this.posSkuId;
    data['ProductId'] = this.productId;
    data['Condition'] = this.condition;
    data['WarrantySkuId'] = this.warrantySkuId;
    data['WarrantyPrice'] = this.warrantyPrice;
    data['WarrantyId'] = this.warrantyId;
    data['WarrantyDisplayName'] = this.warrantyDisplayName;
    data['UnitPrice'] = this.unitPrice;
    data['Quantity'] = this.quantity;
    data['PimSkuId'] = this.pimSkuId;
    data["SourcingReason"] = this.sourcingReason;
    data["ReservationLocationStock"] = this.reservationLocationStock;
    data["ReservationLocation"] = this.reservationLocation;
    data['OverridePriceReason'] = this.overridePriceReason;
    data['OverridePriceApproval'] = this.overridePriceApproval;
    data['OverridePrice'] = this.overridePrice;
    data['MarginValue'] = this.marginValue;
    data['Margin'] = this.margin;
    data['ItemNumber'] = this.itemNumber;
    data['ItemId'] = this.itemId;
    data['ItemDesc'] = this.itemDesc;
    data['Title'] = this.title;
    data['ImageUrl'] = this.imageUrl;
    data['DiscountedMarginValue'] = this.discountedMarginValue;
    data['DiscountedMargin'] = this.discountedMargin;
    data['Cost'] = this.cost;
    data['PurchasedPrice'] = this.purchasedPrice;
    data['SKU'] = this.sKU;
    return data;
  }

  @override
  List<Object?> get props => [
    unitPrice,
    quantity,
    warrantyStyleDesc,
    warrantySkuId,
    warrantyPrice,
    warrantyId,
    warrantyDisplayName,
    isUpdatingCoverage,
    warranties,
    sourcingReason,
    reservationLocationStock,
    reservationLocation,
    pimSkuId,
    isWarrantiesLoading,
    overridePriceReason,
    overridePriceApproval,
    overridePrice,
    marginValue,
    margin,
    itemNumber,
    itemId,
    itemDesc,
    title,
    imageUrl,
    discountedMarginValue,
    isCartAdding,
    isExpanded,
    discountedMargin,
    productId,
    posSkuId,
    condition,
    isOverridden,
    itemStatus,
    purchasedPrice,
    sKU,
    cost,
  ];
}

class OrderStore extends Equatable {
  bool? rowClicked;
  String? postalCode;
  String? name;
  String? id;
  String? distance;
  String? dimensionID;
  String? avaibility;

  OrderStore(
      {
        this.rowClicked,
        this.postalCode,
        this.name,
        this.id,
        this.distance,
        this.dimensionID,
        this.avaibility,
      });

  OrderStore.fromJson(Map<String, dynamic> json) {
    rowClicked = json['rowClicked'];
    postalCode = json['postalCode'];
    name = json['name'];
    id = json['id'];
    distance = json['distance'];
    dimensionID = json['dimensionID'];
    avaibility = json['Avaibility'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rowClicked'] = this.rowClicked;
    data['postalCode'] = this.postalCode;
    data['name'] = this.name;
    data['id'] = this.id;
    data['distance'] = this.distance;
    data['dimensionID'] = this.dimensionID;
    data['Avaibility'] = this.avaibility;
    return data;
  }

  @override
  List<Object?> get props => [
    rowClicked,
    postalCode,
    name,
    id,
    distance,
    dimensionID,
    avaibility,
  ];
}
class OrderStoreInfo extends Equatable{
  Attributes? attributes;
  String? id;
  String? developerName;
  String? masterLabel;
  String? language;
  String? label;
  String? qualifiedApiName;
  String? corporateC;
  String? companyC;
  double? regionC;
  String? regionDescriptionC;
  double? districtC;
  String? districtDescriptionC;
  String? storeC;
  String? storeDescriptionC;
  String? storeNameC;
  String? storeAddressC;
  String? storeCityC;
  String? stateC;
  String? countryC;
  String? postalCodeC;
  String? latitudeC;
  String? longitudeC;
  String? faxC;
  String? phoneC;
  bool? lessonsC;
  bool? activeC;

  OrderStoreInfo(
      {
        this.attributes,
        this.id,
        this.developerName,
        this.masterLabel,
        this.language,
        this.label,
        this.qualifiedApiName,
        this.corporateC,
        this.companyC,
        this.regionC,
        this.regionDescriptionC,
        this.districtC,
        this.districtDescriptionC,
        this.storeC,
        this.storeDescriptionC,
        this.storeNameC,
        this.storeAddressC,
        this.storeCityC,
        this.stateC,
        this.countryC,
        this.postalCodeC,
        this.latitudeC,
        this.longitudeC,
        this.faxC,
        this.phoneC,
        this.lessonsC,
        this.activeC,
      });

  OrderStoreInfo.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    id = json['Id'];
    developerName = json['DeveloperName'];
    masterLabel = json['MasterLabel'];
    language = json['Language'];
    label = json['Label'];
    qualifiedApiName = json['QualifiedApiName'];
    corporateC = json['Corporate__c'];
    companyC = json['Company__c'];
    regionC = int.parse((json['Region__c']??0).toString()).toDouble();
    regionDescriptionC = json['RegionDescription__c'];
    districtC = int.parse((json['District__c']??0).toString()).toDouble();
    districtDescriptionC = json['DistrictDescription__c'];
    storeC = json['Store__c'];
    storeDescriptionC = json['StoreDescription__c'];
    storeNameC = json['StoreName__c'];
    storeAddressC = json['StoreAddress__c'];
    storeCityC = json['StoreCity__c'];
    stateC = json['State__c'];
    countryC = json['Country__c'];
    postalCodeC = json['PostalCode__c'];
    latitudeC = json['Latitude__c'];
    longitudeC = json['Longitude__c'];
    faxC = json['Fax__c'];
    phoneC = json['Phone__c'];
    lessonsC = json['Lessons__c'];
    activeC = json['Active__c'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes!.toJson();
    }
    data['Id'] = this.id;
    data['DeveloperName'] = this.developerName;
    data['MasterLabel'] = this.masterLabel;
    data['Language'] = this.language;
    data['Label'] = this.label;
    data['QualifiedApiName'] = this.qualifiedApiName;
    data['Corporate__c'] = this.corporateC;
    data['Company__c'] = this.companyC;
    data['Region__c'] = this.regionC;
    data['RegionDescription__c'] = this.regionDescriptionC;
    data['District__c'] = this.districtC;
    data['DistrictDescription__c'] = this.districtDescriptionC;
    data['Store__c'] = this.storeC;
    data['StoreDescription__c'] = this.storeDescriptionC;
    data['StoreName__c'] = this.storeNameC;
    data['StoreAddress__c'] = this.storeAddressC;
    data['StoreCity__c'] = this.storeCityC;
    data['State__c'] = this.stateC;
    data['Country__c'] = this.countryC;
    data['PostalCode__c'] = this.postalCodeC;
    data['Latitude__c'] = this.latitudeC;
    data['Longitude__c'] = this.longitudeC;
    data['Fax__c'] = this.faxC;
    data['Phone__c'] = this.phoneC;
    data['Lessons__c'] = this.lessonsC;
    data['Active__c'] = this.activeC;
    return data;
  }

  @override
  List<Object?> get props => [
    attributes,
    id,
    developerName,
    masterLabel,
    language,
    label,
    qualifiedApiName,
    corporateC,
    companyC,
    regionC,
    regionDescriptionC,
    districtC,
    districtDescriptionC,
    storeC,
    storeDescriptionC,
    storeNameC,
    storeAddressC,
    storeCityC,
    stateC,
    countryC,
    postalCodeC,
    latitudeC,
    longitudeC,
    faxC,
    phoneC,
    lessonsC,
    activeC,
  ];
}