import 'package:equatable/equatable.dart';
class AddressesModel {
  String? message;
  List<AddressList>? addressList;

  AddressesModel({this.message, this.addressList});

  AddressesModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['addressList'] != null) {
      addressList = <AddressList>[];
      json['addressList'].forEach((v) {
        addressList!.add(new AddressList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.addressList != null) {
      data['addressList'] = this.addressList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AddressList extends Equatable{
  AddressList({
    this.state,
    this.postalCode,
    this.country,
    this.contactPointAddressId,
    this.city,
    this.addressLabel,
    this.address1,
    this.address2,
    this.addAddress,
    this.isSelected,
    this.isPrimary,
  });

  String? state;
  String? postalCode;
  String? country;
  String? contactPointAddressId;
  String? city;
  String? addressLabel;
  String? address1;
  String? address2;
  bool? addAddress;
  bool? isSelected;
  bool? isFacing;
  bool? isPrimary;

  AddressList.fromJson(Map<String, dynamic> json) {
    state = json['state']??"";
    isFacing = false;
    isSelected = false;
    addAddress = false;
    postalCode = json['postalCode']??"";
    isPrimary = json['isPrimary'];
    country = json['country']??"";
    contactPointAddressId = json['contactPointAddressId'];
    city = json['city']??"";
    addressLabel = json['addressLabel']??"";
    address1 = json['address1']??"";
    address2 = json['address2']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['state'] = this.state;
    data['postalCode'] = this.postalCode;
    data['isPrimary'] = this.isPrimary;
    data['country'] = this.country;
    data['contactPointAddressId'] = this.contactPointAddressId;
    data['city'] = this.city;
    data['addressLabel'] = this.addressLabel;
    data['address1'] = this.address1;
    data['address2'] = this.address2;
    return data;
  }

  @override
  List<Object?> get props => [state,postalCode,country,
  contactPointAddressId,city,addressLabel,address1,address2,addAddress,isSelected,isPrimary];
}
