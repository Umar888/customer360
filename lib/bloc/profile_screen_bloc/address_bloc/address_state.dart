part of 'address_bloc.dart';

@immutable
abstract class AddressState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {}

class AddressProgress extends AddressState {
  final bool? isShowDialog;
  final VerifyAddress? enteredAddress;
  final VerifyAddress? recommendAddress;
  final bool? isDefault;
  final String? contactPointId;
  final String? addressLabel;
  final bool? isPrimary;
  AddressProgress({
    this.isShowDialog,
    this.addressLabel,
    this.recommendAddress,
    this.enteredAddress,
    this.isDefault,
    this.contactPointId,
    this.isPrimary,
  });
  @override
  List<Object?> get props => [isShowDialog];
}

class AddressFailure extends AddressState {}

class AddressSuccess extends AddressState {
  final List<AddressList>? addresses;

  AddressSuccess({this.addresses});

  @override
  List<Object?> get props => [addresses];
}
