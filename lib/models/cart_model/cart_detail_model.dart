import 'package:equatable/equatable.dart';

import 'cart_warranties_model.dart';

class CartDetailModel {
  OrderDetail? orderDetail;
  String? message;

  CartDetailModel({this.orderDetail, this.message});

  CartDetailModel.fromJson(Map<String, dynamic> json) {
    orderDetail = json['OrderDetail'] != null
        ? OrderDetail.fromJson(json['OrderDetail'])
        : null;
    message = json['message'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (orderDetail != null) {
      data['OrderDetail'] = orderDetail!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class OrderDetail extends Equatable{
  double? total;
  bool? taxExempt;
  double? tax;
  double? subtotal;
  String? storeId;
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
      {this.total,
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
      this.orderStatus});

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

class PaymentMethods extends Equatable{
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

class Attributes extends Equatable{
  Attributes({
    this.type,
    this.url,
  });
  String? type;
  String? url;

  Attributes.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['type'] = type;
    _data['url'] = url;
    return _data;
  }

  @override
  List<Object?> get props => [type, url];
}

class Items extends Equatable{
  String? warrantyStyleDesc;
  String? warrantySkuId;
  double? warrantyPrice;
  String? warrantyId;
  String? warrantyDisplayName;
  String? sourcingReason;
  String? reservationLocationStock;
  String? reservationLocation;
  double? unitPrice;
  double? quantity;
  List<Warranties>? warranties;
  String? pimSkuId;
  bool? isCartAdding;
  bool? isUpdatingCoverage;
  bool? isWarrantiesLoading;
  bool? isExpanded;
  bool? isOverridden;

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
      {this.unitPrice,
      this.quantity,
      this.warrantyStyleDesc,
      this.warrantySkuId,
      this.warrantyPrice,
      this.warrantyId,
      this.warrantyDisplayName,
      this.sourcingReason,
      this.reservationLocationStock,
      this.reservationLocation,
      this.isUpdatingCoverage,
      this.warranties,
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
      this.cost});

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
    sourcingReason = json["SourcingReason"];
    reservationLocationStock = json["ReservationLocationStock"];
    reservationLocation = json["ReservationLocation"];
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
    data["SourcingReason"] = this.sourcingReason;
    data["ReservationLocationStock"] = this.reservationLocationStock;
    data["ReservationLocation"] = this.reservationLocation;
    data['UnitPrice'] = this.unitPrice;
    data['Quantity'] = this.quantity;
    data['PimSkuId'] = this.pimSkuId;
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
    sourcingReason,
    reservationLocationStock,
    reservationLocation,
    isUpdatingCoverage,
    warranties,
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
