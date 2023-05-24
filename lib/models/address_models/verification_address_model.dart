class VerificationAddressModel {
  VerificationAddressModel({
    required this.recommendedAddress,
    required this.hasDifference,
    required this.existingAddress,
  });

  VerifyAddress recommendedAddress;
  bool hasDifference;
  VerifyAddress existingAddress;

  factory VerificationAddressModel.fromJson(Map<String, dynamic> json) =>
      VerificationAddressModel(
        recommendedAddress: VerifyAddress.fromJson(json["recommendedAddress"]),
        hasDifference: json["hasDifference"],
        existingAddress: VerifyAddress.fromJson(json["existingAddress"]),
      );

  Map<String, dynamic> toJson() => {
        "recommendedAddress": recommendedAddress.toJson(),
        "hasDifference": hasDifference,
        "existingAddress": existingAddress.toJson(),
      };
}

class VerifyAddress {
  VerifyAddress({
    required this.state,
    required this.postalcode,
    this.isSuccess,
    required this.isShipping,
    required this.isBilling,
    required this.country,
    required this.city,
    required this.addressline2,
    required this.addressline1,
  });

  String? state;
  String? postalcode;
  bool? isSuccess;
  bool? isShipping;
  bool? isBilling;
  String? country;
  String? city;
  String? addressline2;
  String? addressline1;

  factory VerifyAddress.fromJson(Map<String, dynamic> json) => VerifyAddress(
        state: json["state"],
        postalcode: json["postalcode"],
        isSuccess: json["isSuccess"],
        isShipping: json["isShipping"],
        isBilling: json["isBilling"],
        country: json["country"],
        city: json["city"],
        addressline2: json["addressline2"],
        addressline1: json["addressline1"],
      );

  Map<String, dynamic> toJson() => {
        "state": state,
        "postalcode": postalcode,
        "isSuccess": isSuccess,
        "isShipping": isShipping,
        "isBilling": isBilling,
        "country": country,
        "city": city,
        "addressline2": addressline2,
        "addressline1": addressline1,
      };
}
