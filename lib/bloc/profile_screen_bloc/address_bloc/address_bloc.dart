import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gc_customer_app/data/reporsitories/profile/addresses_repository.dart';
import 'package:gc_customer_app/models/address_models/address_model.dart';
import 'package:gc_customer_app/models/address_models/verification_address_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressesRepository addressRepository;

  AddressBloc(this.addressRepository) : super(AddressFailure()) {
    on<LoadAddressesData>((event, emit) async {
      String userRecordId = await SharedPreferenceService().getValue(agentId);
      if ((userRecordId).isNotEmpty) {
        emit(AddressProgress());
        var addresses = await addressRepository
            .getProfileAddresses(userRecordId)
            .catchError((_) {
          emit(AddressFailure());
        });
        addresses.first.isPrimary = true;
        emit(AddressSuccess(addresses: addresses));

        return;
      }

      emit(AddressFailure());
      return;
    });

    on<SaveAddressesData>((event, emit) async {
      String userRecordId = await SharedPreferenceService().getValue(agentId);
      if ((userRecordId).isNotEmpty) {
        emit(AddressProgress());
        var addresses = await addressRepository.saveProfileAddresses(
            userRecordId, event.addressModel, event.isDefault);
        addresses.first.isPrimary = true;
        emit(AddressSuccess(addresses: addresses));

        return;
      }

      emit(AddressFailure());
      return;
    });

    on<VerificationAddressProfile>((event, emit) async {
      String? loggedInUserId =
          await SharedPreferenceService().getValue(loggedInAgentId);
      print("event.addressModel.address2 ${event.addressModel.address2}");
      var enteredAddress = VerifyAddress(
          state: event.addressModel.state,
          postalcode: event.addressModel.postalCode,
          isShipping: true,
          isBilling: false,
          country: 'US',
          city: event.addressModel.city,
          addressline2: event.addressModel.address2,
          addressline1: event.addressModel.address1);

      var resp = await addressRepository.verificationAddress(loggedInUserId, enteredAddress);

      if (resp.hasDifference && resp.recommendedAddress.isSuccess != null && resp.recommendedAddress.isSuccess!) {
        emit(AddressProgress(
            isShowDialog: true,
            addressLabel: event.addressModel.addressLabel,
            recommendAddress: resp.recommendedAddress,
            enteredAddress: resp.existingAddress,
            contactPointId: event.addressModel.contactPointAddressId,
            isPrimary: event.addressModel.isPrimary,
            isDefault: event.isDefault));
      } else {
        if (event.contactPointId != null) {
          event.addressModel.contactPointAddressId = event.contactPointId;
        }
        event.addressModel.isPrimary = event.addressModel.isPrimary;
        add(SaveAddressesData(
            isDefault: event.isDefault,
            addressModel: event.addressModel));
      }

      return;
    });
  }
}
