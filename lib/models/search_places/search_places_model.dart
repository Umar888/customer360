import 'package:equatable/equatable.dart';

class SearchPlacesListModel extends Equatable{
  String? message;
  List<AutoCompleteAddressList>? autoCompleteAddressList;

  SearchPlacesListModel({this.message, this.autoCompleteAddressList});

  SearchPlacesListModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['autoCompleteAddressList'] != null) {
      autoCompleteAddressList = <AutoCompleteAddressList>[];
      json['autoCompleteAddressList'].forEach((v) {
        autoCompleteAddressList!.add(new AutoCompleteAddressList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.autoCompleteAddressList != null) {
      data['autoCompleteAddressList'] =
          this.autoCompleteAddressList!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [message, autoCompleteAddressList];
}

class AutoCompleteAddressList extends Equatable{
  String? zip;
  String? street;
  String? state;
  bool? isSelected;
  String? city;

  AutoCompleteAddressList(
      {this.zip, this.street, this.state, this.isSelected, this.city});

  AutoCompleteAddressList.fromJson(Map<String, dynamic> json) {
    zip = json['zip'];
    street = json['street'];
    state = json['state'];
    isSelected = json['isSelected'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['zip'] = this.zip;
    data['street'] = this.street;
    data['state'] = this.state;
    data['isSelected'] = this.isSelected;
    data['city'] = this.city;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    zip,
    street,
    state,
    isSelected,
    city,
  ];
}
