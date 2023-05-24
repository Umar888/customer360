import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gc_customer_app/data/reporsitories/customer_look_up_repository/customer_lookup_repository.dart';
import 'package:gc_customer_app/data/reporsitories/profile/addresses_repository.dart';
import 'package:gc_customer_app/models/address_models/verification_address_model.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'customer_look_up_event.dart';
part 'customer_look_up_state.dart';

enum SearchType { email, phone }

class CustomerLookUpBloc
    extends Bloc<CustomerLookUpEvent, CustomerLookUpState> {
  final CustomerLookUpRepository customerLookUpRepository;
  final AddressesRepository addressesRepository = AddressesRepository();

  int offset = 0;
  List<UserProfile> customers = [];

  Future<List<UserProfile>> getCustomerSearchByName(String searchKey) async {
    searchKey = searchKey.replaceAll(' ', '%25');
    var resp = await customerLookUpRepository.getCustomerSearchByName(
        searchKey, offset);

    return resp;
  }

  CustomerLookUpBloc(this.customerLookUpRepository)
      : super(CustomerLookUpFailure()) {
    on<LoadLookUpData>((event, emit) async {
      List<UserProfile> users = [];
      emit(CustomerLookUpProgress());
      if(!Platform.environment.containsKey("FLUTTER_TEST"))
      FirebaseAnalytics.instance.logEvent(
          name: 'customer_look_up', parameters: {'name': event.keySearch});
      switch (event.searchType) {
        case SearchType.email:
          users = await customerLookUpRepository
              .getCustomerSearchByEmail(event.keySearch)
              .catchError((_) => emit(CustomerLookUpFailure()));
          break;
        case SearchType.phone:
          users = await customerLookUpRepository
              .getCustomerSearchByPhone(event.keySearch)
              .catchError((_) => emit(CustomerLookUpFailure()));
          break;
        default:
          users = await customerLookUpRepository
              .getCustomerSearchByEmail(event.keySearch)
              .catchError((_) => emit(CustomerLookUpFailure()));
          break;
      }

      emit(CustomerLookUpSuccess(users: users, type: event.searchType));

      return;
    });

    on<ClearData>((event, emit) async {
      emit(CustomerLookUpInitial());

      return;
    });

    on<SaveCustomer>((event, emit) async {
      var states;
      if (event.customerLookUpState is SaveCustomerFailure) {
        states = state as SaveCustomerFailure;
      } else {
        states = state as SaveCustomerProgress;
      }
      emit(SaveCustomerProgress(
          isShowOptions: true,
          isShowDialog: false,
          isLoading: true,
          message: "done",
          recommendAddress: states.recommendAddress,
          enteredAddress: states.enteredAddress,
          proficiencies: states.proficiencies,
          frequencies: states.frequencies,
          instruments: states.instruments,
          selectedProficiency: states.selectedProficiency,
          selectedInstruments: states.selectedInstruments,
          selectedFrequency: states.selectedFrequency));

      var customer = await customerLookUpRepository.saveCustomer(
          UserProfile(
            firstName: event.firstName,
            lastName: event.lastName,
            accountEmailC: event.email,
            accountPhoneC: event.phone,
            personMailingStreet: event.address,
            personMailingStreet2: event.address2,
            personMailingCity: event.city,
            personMailingState: event.state,
            personMailingPostalCode: event.zipCode,
          ),
          event.proficiencyLevel,
          event.playFrequency,
          event.playInstruments);
      if (customer.id != null && customer.id != "N/A") {
        emit(SaveCustomerSuccess(customer));
      } else {
        emit(SaveCustomerFailure(
            message: customer.name!,
            recommendAddress: states.recommendAddress,
            enteredAddress: states.enteredAddress,
            proficiencies: states.proficiencies,
            frequencies: states.frequencies,
            instruments: states.instruments,
            isShowOptions: true,
            isShowDialog: false,
            isLoading: true,
            selectedProficiency: states.selectedProficiency,
            selectedInstruments: states.selectedInstruments,
            selectedFrequency: states.selectedFrequency));
      }
    });

    on<ClearScafolldMessage>((event, emit) async {
      var states = state as SaveCustomerFailure;
      emit(SaveCustomerFailure(
          selectedProficiency: states.selectedProficiency,
          proficiencies: states.proficiencies,
          frequencies: states.frequencies,
          instruments: states.instruments,
          isLoading: states.isLoading,
          message: "",
          selectedFrequency: states.selectedFrequency,
          isShowDialog: false,
          isShowOptions: states.isShowOptions,
          recommendAddress: states.recommendAddress,
          enteredAddress: states.enteredAddress,
          selectedInstruments: states.selectedInstruments));
    });

    on<SearchCustomer>(
      (event, emit) async {
        if (offset == 0) {
          emit(CustomerLookUpProgress());
        }
        customers = await getCustomerSearchByName(event.searchText);
        emit(SearchSuccess(searchModels: customers));
        return;
      },
    );
    on<EmptyProgressMessage>((event, emit) async {
      var states = state as SaveCustomerProgress;
      emit(SaveCustomerProgress(
          selectedProficiency: states.selectedProficiency,
          proficiencies: states.proficiencies,
          frequencies: states.frequencies,
          instruments: states.instruments,
          isLoading: states.isLoading,
          message: "",
          selectedFrequency: states.selectedFrequency,
          isShowDialog: false,
          isShowOptions: states.isShowOptions,
          recommendAddress: states.recommendAddress,
          enteredAddress: states.enteredAddress,
          selectedInstruments: states.selectedInstruments));
    });
    on<SelectProficiencyLevel>((event, emit) async {
      var states = state as SaveCustomerProgress;
      emit(SaveCustomerProgress(
          selectedProficiency: event.value,
          proficiencies: states.proficiencies,
          frequencies: states.frequencies,
          instruments: states.instruments,
          isLoading: false,
          message: "done",
          selectedFrequency: states.selectedFrequency,
          isShowDialog: states.isShowDialog,
          isShowOptions: states.isShowOptions,
          recommendAddress: states.recommendAddress,
          enteredAddress: states.enteredAddress,
          selectedInstruments: states.selectedInstruments));
    });
    on<SelectPlayFrequency>((event, emit) async {
      var states = state as SaveCustomerProgress;
      emit(SaveCustomerProgress(
          selectedProficiency: states.selectedProficiency,
          proficiencies: states.proficiencies,
          frequencies: states.frequencies,
          instruments: states.instruments,
          selectedFrequency: event.value,
          isShowDialog: states.isShowDialog,
          isLoading: false,
          message: "done",
          isShowOptions: states.isShowOptions,
          recommendAddress: states.recommendAddress,
          enteredAddress: states.enteredAddress,
          selectedInstruments: states.selectedInstruments));
    });
    on<SelectPreferredInstrument>((event, emit) async {
      var states = state as SaveCustomerProgress;
      List<String> instruments = [];
      instruments = states.selectedInstruments;
      instruments.add(event.value);
      emit(SaveCustomerProgress(
          selectedProficiency: states.selectedProficiency,
          proficiencies: states.proficiencies,
          frequencies: states.frequencies,
          instruments: states.instruments,
          selectedFrequency: states.selectedFrequency,
          isShowDialog: states.isShowDialog,
          isShowOptions: states.isShowOptions,
          isLoading: false,
          message: "done",
          recommendAddress: states.recommendAddress,
          enteredAddress: states.enteredAddress,
          selectedInstruments: instruments));
    });
    on<RemovePreferredInstrument>((event, emit) async {
      var states = state as SaveCustomerProgress;
      List<String> instruments = [];
      instruments = states.selectedInstruments;
      instruments.remove(event.value);
      emit(SaveCustomerProgress(
          selectedProficiency: states.selectedProficiency,
          proficiencies: states.proficiencies,
          frequencies: states.frequencies,
          isLoading: false,
          message: "done",
          instruments: states.instruments,
          selectedFrequency: states.selectedFrequency,
          isShowDialog: states.isShowDialog,
          isShowOptions: states.isShowOptions,
          recommendAddress: states.recommendAddress,
          enteredAddress: states.enteredAddress,
          selectedInstruments: instruments));
    });

    on<VerificationAddressNewCustomer>((event, emit) async {
      print(
          "event.customerLookUpState.toString() ${event.customerLookUpState.toString()}");
      var states;
      if (event.customerLookUpState is SaveCustomerFailure) {
        states = state as SaveCustomerFailure;
      } else {
        if (!event.hasOptions) {
          emit(SaveCustomerProgress(isLoading: true));
        }
        states = state as SaveCustomerProgress;
      }

      if (!states.isShowOptions) {
        String? id = await SharedPreferenceService().getValue(loggedInAgentId);
        List<String> proficiencyLevel = await customerLookUpRepository
            .getRecordOptions(userId: id, recordType: "ProficiencyLevel");
        List<String> preferredInstrument = await customerLookUpRepository
            .getRecordOptions(userId: id, recordType: "PreferredInstrument");
        List<String> playFrequency = await customerLookUpRepository
            .getRecordOptions(userId: id, recordType: "PlayFrequency");
        emit(SaveCustomerProgress(
            proficiencies: proficiencyLevel,
            frequencies: playFrequency,
            instruments: preferredInstrument,
            selectedFrequency: "",
            message: "",
            isShowDialog: false,
            isLoading: false,
            isShowOptions: true,
            recommendAddress: states.recommendAddress,
            enteredAddress: states.enteredAddress,
            selectedInstruments: [],
            selectedProficiency: ""));
      } else {
        emit(SaveCustomerProgress(
            isShowOptions: true,
            isShowDialog: false,
            isLoading: true,
            message: "done",
            proficiencies: states.proficiencies,
            frequencies: states.frequencies,
            instruments: states.instruments,
            selectedProficiency: states.selectedProficiency,
            selectedInstruments: states.selectedInstruments,
            selectedFrequency: states.selectedFrequency));
        String? loggedInUserId =
            await SharedPreferenceService().getValue(loggedInAgentId);
        var enteredAddress = VerifyAddress(
            state: event.state,
            postalcode: event.zipCode,
            isShipping: true,
            isBilling: false,
            country: 'US',
            city: event.city,
            addressline2: event.address2,
            addressline1: event.address);
        var resp = await addressesRepository.verificationAddress(
            loggedInUserId, enteredAddress);
        if (resp.hasDifference &&
            resp.recommendedAddress.isSuccess != null &&
            resp.recommendedAddress.isSuccess!) {
          emit(SaveCustomerProgress(
              isShowOptions: true,
              isShowDialog: true,
              message: "",
              isLoading: true,
              recommendAddress: resp.recommendedAddress,
              enteredAddress: resp.existingAddress,
              proficiencies: states.proficiencies,
              frequencies: states.frequencies,
              instruments: states.instruments,
              selectedProficiency: states.selectedProficiency,
              selectedInstruments: states.selectedInstruments,
              selectedFrequency: states.selectedFrequency));
        } else {
          add(SaveCustomer(
              email: event.email,
              phone: event.phone,
              firstName: event.firstName,
              lastName: event.lastName,
              address: event.address,
              customerLookUpState: states,
              city: event.city,
              zipCode: event.zipCode,
              state: event.state,
              proficiencyLevel: states.selectedProficiency,
              playInstruments: states.selectedInstruments.join(",").toString(),
              playFrequency: states.selectedFrequency,
              address2: event.address2));
        }
      }
    });
  }
}
