part of 'address_bloc.dart';

@immutable
abstract class AddressEvent extends Equatable {
  AddressEvent();
  @override
  List<Object> get props => [];
}

class LoadAddressesData extends AddressEvent {
  LoadAddressesData();

  @override
  List<Object> get props => [];
}

class SaveAddressesData extends AddressEvent {
  final bool isDefault;
  final AddressList addressModel;
  SaveAddressesData(
      {required this.addressModel, required this.isDefault});

  @override
  List<Object> get props => [];
}

class VerificationAddressProfile extends AddressEvent {
  final bool isDefault;
  final AddressList addressModel;
  final String? contactPointId;
  VerificationAddressProfile({
    required this.addressModel,
    required this.isDefault,
    this.contactPointId,
  });

  @override
  List<Object> get props => [];
}
