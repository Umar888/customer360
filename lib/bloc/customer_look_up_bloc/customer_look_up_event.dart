part of 'customer_look_up_bloc.dart';

@immutable
abstract class CustomerLookUpEvent extends Equatable {
  CustomerLookUpEvent();
  @override
  List<Object> get props => [];
}

class LoadLookUpData extends CustomerLookUpEvent {
  final String keySearch;
  final SearchType searchType;
  LoadLookUpData(this.keySearch, this.searchType);

  @override
  List<Object> get props => [];
}

class ClearData extends CustomerLookUpEvent {
  ClearData();

  @override
  List<Object> get props => [];
}
class EmptyProgressMessage extends CustomerLookUpEvent {
  EmptyProgressMessage();

  @override
  List<Object> get props => [];
}
class FetchUserOptions extends CustomerLookUpEvent {
  FetchUserOptions();
  @override
  List<Object> get props => [];
}
class SelectPreferredInstrument extends CustomerLookUpEvent {
  final String value;
  SelectPreferredInstrument(this.value);
  @override
  List<Object> get props => [value];
}
class RemovePreferredInstrument extends CustomerLookUpEvent {
  final String value;
  RemovePreferredInstrument(this.value);
  @override
  List<Object> get props => [value];
}
class SelectPlayFrequency extends CustomerLookUpEvent {
  final String value;
  SelectPlayFrequency(this.value);
  @override
  List<Object> get props => [value];
}
class SelectProficiencyLevel extends CustomerLookUpEvent {
  final String value;
  SelectProficiencyLevel(this.value);
  @override
  List<Object> get props => [value];
}

class SaveCustomer extends CustomerLookUpEvent {
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String proficiencyLevel;
  final CustomerLookUpState customerLookUpState;
  final String playFrequency;
  final String playInstruments;
  final String address;
  final String address2;
  final String city;
  final String zipCode;
  final String state;
  SaveCustomer({
    required this.email,
    required this.phone,
    required this.proficiencyLevel,
    required this.customerLookUpState,
    required this.playFrequency,
    required this.playInstruments,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.address2,
    required this.city,
    required this.zipCode,
    required this.state,
  });

  @override
  List<Object> get props => [];
}

class ClearScafolldMessage extends CustomerLookUpEvent {
  ClearScafolldMessage();
  @override
  List<Object> get props => [];
}

class SearchCustomer extends CustomerLookUpEvent {
  final String searchText;
  final bool isPaging;
  SearchCustomer(this.searchText, {this.isPaging = false});
}

class VerificationAddressNewCustomer extends CustomerLookUpEvent {
  final String firstName;
  final String lastName;
  final String address;
  final String address2;
  final CustomerLookUpState customerLookUpState;
  final String city;
  final bool hasOptions;
  final String zipCode;
  final String state;
  final String email;
  final String phone;
  VerificationAddressNewCustomer({
    required this.firstName,
    required this.lastName,
    required this.hasOptions,
    required this.state,
    required this.address,
    required this.city,
    required this.zipCode,
    required this.customerLookUpState,
    required this.email,
    required this.phone,
    required this.address2,
  });

  @override
  List<Object> get props => [];
}
