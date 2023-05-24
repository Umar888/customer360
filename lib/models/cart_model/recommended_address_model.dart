class RecommendedAddressModel {
  String? message;
  AddressInfo? addressInfo;

  RecommendedAddressModel({this.message, this.addressInfo});

  RecommendedAddressModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    addressInfo = json['addressInfo'] != null
        ? new AddressInfo.fromJson(json['addressInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.addressInfo != null) {
      data['addressInfo'] = this.addressInfo!.toJson();
    }
    return data;
  }
}

class AddressInfo {
  RecommendedAddress? recommendedAddress;
  bool? hasDifference;
  ExistingAddress? existingAddress;

  AddressInfo(
      {this.recommendedAddress, this.hasDifference, this.existingAddress});

  AddressInfo.fromJson(Map<String, dynamic> json) {
    recommendedAddress = json['recommendedAddress'] != null
        ? new RecommendedAddress.fromJson(json['recommendedAddress'])
        : null;
    hasDifference = json['hasDifference'];
    existingAddress = json['existingAddress'] != null
        ? new ExistingAddress.fromJson(json['existingAddress'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.recommendedAddress != null) {
      data['recommendedAddress'] = this.recommendedAddress!.toJson();
    }
    data['hasDifference'] = this.hasDifference;
    if (this.existingAddress != null) {
      data['existingAddress'] = this.existingAddress!.toJson();
    }
    return data;
  }
}

class RecommendedAddress {
  String? state;
  String? postalcode;
  bool? isSuccess;
  bool? isShipping;
  bool? isBilling;
  String? country;
  String? city;
  String? addressline2;
  String? addressline1;

  RecommendedAddress(
      {this.state,
        this.postalcode,
        this.isSuccess,
        this.isShipping,
        this.isBilling,
        this.country,
        this.city,
        this.addressline2,
        this.addressline1});

  RecommendedAddress.fromJson(Map<String, dynamic> json) {
    state = json['state']??"";
    postalcode = json['postalcode']??"";
    isSuccess = json['isSuccess']??false;
    isShipping = json['isShipping']??false;
    isBilling = json['isBilling']??false;
    country = json['country']??"";
    city = json['city']??"";
    addressline2 = json['addressline2']??"";
    addressline1 = json['addressline1']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['state'] = this.state;
    data['postalcode'] = this.postalcode;
    data['isSuccess'] = this.isSuccess;
    data['isShipping'] = this.isShipping;
    data['isBilling'] = this.isBilling;
    data['country'] = this.country;
    data['city'] = this.city;
    data['addressline2'] = this.addressline2;
    data['addressline1'] = this.addressline1;
    return data;
  }
}

class ExistingAddress {
  String? state;
  String? postalcode;
  Null? isSuccess;
  bool? isShipping;
  bool? isBilling;
  String? country;
  String? city;
  String? addressline2;
  String? addressline1;

  ExistingAddress(
      {this.state,
        this.postalcode,
        this.isSuccess,
        this.isShipping,
        this.isBilling,
        this.country,
        this.city,
        this.addressline2,
        this.addressline1});

  ExistingAddress.fromJson(Map<String, dynamic> json) {
    state = json['state'];
    postalcode = json['postalcode'];
    isSuccess = json['isSuccess'];
    isShipping = json['isShipping'];
    isBilling = json['isBilling'];
    country = json['country'];
    city = json['city'];
    addressline2 = json['addressline2'];
    addressline1 = json['addressline1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['state'] = this.state;
    data['postalcode'] = this.postalcode;
    data['isSuccess'] = this.isSuccess;
    data['isShipping'] = this.isShipping;
    data['isBilling'] = this.isBilling;
    data['country'] = this.country;
    data['city'] = this.city;
    data['addressline2'] = this.addressline2;
    data['addressline1'] = this.addressline1;
    return data;
  }
}
