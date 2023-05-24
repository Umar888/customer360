part of 'add_customer_bloc.dart';

@immutable
abstract class AddCustomerEvent extends Equatable {
  AddCustomerEvent();

  @override
  List<Object> get props => [];
}

class ChangeCustomerType extends AddCustomerEvent {
  final bool isEmail;
  ChangeCustomerType(this.isEmail);

  @override
  List<Object> get props => [isEmail];
}

class FetchUserOptions extends AddCustomerEvent {
  FetchUserOptions();

  @override
  List<Object> get props => [];
}

class SelectPreferredInstrument extends AddCustomerEvent {
  final String value;
  SelectPreferredInstrument(this.value);

  @override
  List<Object> get props => [value];
}

class RemovePreferredInstrument extends AddCustomerEvent {
  final String value;
  RemovePreferredInstrument(this.value);

  @override
  List<Object> get props => [value];
}

class SelectPlayFrequency extends AddCustomerEvent {
  final String value;
  SelectPlayFrequency(this.value);

  @override
  List<Object> get props => [value];
}

class SelectProficiencyLevel extends AddCustomerEvent {
  final String value;
  SelectProficiencyLevel(this.value);

  @override
  List<Object> get props => [value];
}

class UpdateShowOptions extends AddCustomerEvent {
  final bool value;
  UpdateShowOptions(this.value);

  @override
  List<Object> get props => [value];
}

class LoadLookUpData extends AddCustomerEvent {
  final String keySearch;
  final SearchType searchType;
  LoadLookUpData(this.keySearch, this.searchType);

  @override
  List<Object> get props => [];
}

class GetRecommendedAddressesAddCustomer extends AddCustomerEvent {
  String address1;
  String address2;
  String city;
  String state;
  String postalCode;
  String country;
  String currentFName;
  CartBloc cartBloc;
  String currentLName;
  String currentEmail;
  String currentPhone;
  bool isShipping;
  bool isBilling;
  GetRecommendedAddressesAddCustomer(
      {required this.address1,
      required this.address2,
      required this.city,
      required this.state,
      required this.postalCode,
      required this.country,
      required this.isShipping,
      required this.isBilling,
      required this.currentFName,
      required this.currentLName,
      required this.currentEmail,
      required this.currentPhone,
      required this.cartBloc});

  @override
  List<Object> get props =>
      [address1, address2, city, cartBloc, currentFName, currentLName, currentEmail, currentPhone, state, postalCode, country, isShipping, isBilling];
}

class ClearRecommendedAddressesAddCustomer extends AddCustomerEvent {
  ClearRecommendedAddressesAddCustomer();

  @override
  List<Object> get props => [];
}

class HideRecommendedDialogAddCustomer extends AddCustomerEvent {
  HideRecommendedDialogAddCustomer();

  @override
  List<Object> get props => [];
}

class SaveCustomer extends AddCustomerEvent {
  final String orderId;
  final int index;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String address1;
  final String address2;
  final String city;
  final String zipCode;
  final String state;
  final CartBloc cartBloc;
  SaveCustomer({
    required this.email,
    required this.index,
    required this.orderId,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.address1,
    required this.address2,
    required this.city,
    required this.zipCode,
    required this.state,
    required this.cartBloc,
  });

  @override
  List<Object> get props => [
        email,
        phone,
        orderId,
        index,
        firstName,
        lastName,
        address1,
        address2,
        city,
        zipCode,
        state,
        cartBloc,
      ];
}

class ResetData extends AddCustomerEvent {
  ResetData();

  @override
  List<Object> get props => [];
}

class LoadFormKey extends AddCustomerEvent {
  LoadFormKey();

  @override
  List<Object> get props => [];
}

class SelectUser extends AddCustomerEvent {
  final int index;
  final String orderId;
  final Function() function;
  final CartBloc cartBloc;
  SelectUser({required this.function, required this.index, required this.orderId, required this.cartBloc});

  @override
  List<Object> get props => [function, index, orderId, cartBloc];
}

class ClearMessage extends AddCustomerEvent {
  ClearMessage();

  @override
  List<Object> get props => [];
}
