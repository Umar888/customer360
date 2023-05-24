import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/cart_bloc/cart_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/cart_reporsitory/cart_repository.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:rxdart/transformers.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../models/cart_model/recommended_address_model.dart';
import '../../../models/user_profile_model.dart';

part 'add_customer_event.dart';

part 'add_customer_state.dart';

enum SearchType { email, phone }

class AddCustomerBloc extends Bloc<AddCustomerEvent, AddCustomerState> {
  final CartRepository cartRepository;

  String cardHolderName = '';
  String orderId = '';

  AddCustomerBloc(this.cartRepository) : super(AddCustomerState()) {
    on<FetchUserOptions>((event, emit) async {
      var id = await SharedPreferenceService().getValue(loggedInAgentId);
      List<String> proficiencyLevel = await cartRepository.getRecordOptions(
          userId: id, recordType: "ProficiencyLevel");
      List<String> preferredInstrument = await cartRepository.getRecordOptions(
          userId: id, recordType: "PreferredInstrument");
      List<String> playFrequency = await cartRepository.getRecordOptions(
          userId: id, recordType: "PlayFrequency");
      emit(state.copyWith(
          proficiencies: proficiencyLevel,
          frequencies: playFrequency,
          instruments: preferredInstrument,
          selectedFrequency: "",
          selectedInstruments: [],
          selectedProficiency: ""));
    });
    on<SelectProficiencyLevel>((event, emit) async {
      emit(state.copyWith(selectedProficiency: event.value, message: "done"));
    });
    on<SelectPlayFrequency>((event, emit) async {
      emit(state.copyWith(selectedFrequency: event.value, message: "done"));
    });
    on<SelectPreferredInstrument>((event, emit) async {
      List<String> instruments = [];
      instruments = [...state.selectedInstruments];
      instruments.add(event.value);
      emit(state.copyWith(selectedInstruments: instruments, message: "done"));
    });
    on<RemovePreferredInstrument>((event, emit) async {
      List<String> instruments = [];
      instruments = [...state.selectedInstruments];
      instruments.remove(event.value);
      emit(state.copyWith(selectedInstruments: instruments, message: "done"));
    });
    on<UpdateShowOptions>((event, emit) async {
      if (!event.value) {
        emit(state.copyWith(
            showOption: event.value,
            selectedFrequency: "",
            selectedInstruments: [],
            selectedProficiency: ""));
      } else {
        emit(state.copyWith(showOption: event.value));
      }
    });
    on<LoadFormKey>((event, emit) async {
      emit(state.copyWith(formKey: GlobalKey<FormState>()));
    });
    on<ChangeCustomerType>((event, emit) async {
      emit(state.copyWith(
          addCustomerType:
              event.isEmail ? AddCustomerType.email : AddCustomerType.phone));
    });
    on<HideRecommendedDialogAddCustomer>((event, emit) async {
      emit(state.copyWith(
        showRecommendedDialog: false,
      ));
    });
    on<GetRecommendedAddressesAddCustomer>((event, emit) async {
      emit(state.copyWith(saveCustomerStatus: SaveCustomerStatus.saving));

      emit(state.copyWith(
        recommendedAddress: "",
        recommendedAddressLine1: "",
        saveCustomerStatus: SaveCustomerStatus.saving,
        recommendedAddressLine2: "",
        recommendedAddressLineCity: "",
        recommendedAddressLineCountry: "",
        recommendedAddressLineState: "",
        recommendedAddressLineZipCode: "",
        showRecommendedDialog: false,
        message: "done",
        orderAddress: "",
        currentFName: event.currentFName,
        currentLName: event.currentLName,
        currentEmail: event.currentEmail,
        currentPhone: event.currentPhone,
        currentAddress1: event.address1,
        currentAddress2: event.address2,
        currentCity: event.city,
        currentState: event.state,
        currentZip: event.postalCode,
      ));
      event.cartBloc.add(UpdateStateMessage());
      emit(state.copyWith(saveCustomerStatus: SaveCustomerStatus.saving));

      RecommendedAddressModel recommendedAddressModel =
          await cartRepository.getRecommendedAddress(
              event.address1,
              event.address2,
              event.city,
              event.state,
              event.postalCode,
              event.country,
              event.isShipping,
              event.isBilling);
      if (recommendedAddressModel.addressInfo != null) {
        if (recommendedAddressModel.addressInfo!.hasDifference != null &&
            recommendedAddressModel.addressInfo!.recommendedAddress != null &&
            recommendedAddressModel
                    .addressInfo!.recommendedAddress!.isSuccess !=
                null &&
            recommendedAddressModel
                .addressInfo!.recommendedAddress!.isSuccess!) {
          if (recommendedAddressModel.addressInfo!.hasDifference!) {
            RecommendedAddress recommendedAddress =
                recommendedAddressModel.addressInfo!.recommendedAddress!;
            ExistingAddress orderAddress =
                recommendedAddressModel.addressInfo!.existingAddress!;
            emit(state.copyWith(
                recommendedAddress:
                    "${recommendedAddress.addressline1!.isNotEmpty ? recommendedAddress.addressline1! : ""}"
                    "${recommendedAddress.addressline1!.isNotEmpty || recommendedAddress.addressline2!.isNotEmpty ? ", " : ""}"
                    "${recommendedAddress.addressline2!.isNotEmpty ? recommendedAddress.addressline2 : ""}"
                    "${recommendedAddress.addressline2!.isNotEmpty || recommendedAddress.city!.isNotEmpty ? ", " : ""}"
                    "${recommendedAddress.city!.isNotEmpty ? recommendedAddress.city! : ""}"
                    "${recommendedAddress.city!.isNotEmpty || recommendedAddress.state!.isNotEmpty ? ", " : ""}"
                    "${recommendedAddress.state!.isNotEmpty ? recommendedAddress.state! : ""}"
                    "${recommendedAddress.state!.isNotEmpty || recommendedAddress.country!.isNotEmpty ? ", " : ""}"
                    "${recommendedAddress.country!.isNotEmpty ? recommendedAddress.country! : ""}"
                    "${recommendedAddress.country!.isNotEmpty || recommendedAddress.postalcode!.isNotEmpty ? ", " : ""}"
                    "${recommendedAddress.postalcode!.isNotEmpty ? recommendedAddress.postalcode! : ""}",
                orderAddress:
                    "${orderAddress.addressline1!.isNotEmpty ? orderAddress.addressline1! : ""}"
                    "${orderAddress.addressline1!.isNotEmpty || orderAddress.addressline2!.isNotEmpty ? ", " : ""}"
                    "${orderAddress.addressline2!.isNotEmpty ? orderAddress.addressline2 : ""}"
                    "${orderAddress.addressline2!.isNotEmpty || orderAddress.city!.isNotEmpty ? ", " : ""}"
                    "${orderAddress.city!.isNotEmpty ? orderAddress.city! : ""}"
                    "${orderAddress.city!.isNotEmpty || orderAddress.state!.isNotEmpty ? ", " : ""}"
                    "${orderAddress.state!.isNotEmpty ? orderAddress.state! : ""}"
                    "${orderAddress.state!.isNotEmpty || orderAddress.country!.isNotEmpty ? ", " : ""}"
                    "${orderAddress.country!.isNotEmpty ? orderAddress.country! : ""}"
                    "${orderAddress.country!.isNotEmpty || orderAddress.postalcode!.isNotEmpty ? ", " : ""}"
                    "${orderAddress.postalcode!.isNotEmpty ? orderAddress.postalcode! : ""}",
                showRecommendedDialog: true,
                recommendedAddressLine1: recommendedAddress.addressline1!,
                recommendedAddressLine2: recommendedAddress.addressline2!,
                recommendedAddressLineCity: recommendedAddress.city!,
                saveCustomerStatus: SaveCustomerStatus.notSaving,
                message: "done",
                recommendedAddressLineCountry: recommendedAddress.country!,
                recommendedAddressLineState: recommendedAddress.state!,
                recommendedAddressLineZipCode: recommendedAddress.postalcode!));
          } else {
            emit(state.copyWith(
              message: "Recommended address not found",
              recommendedAddress: "",
              recommendedAddressLine1: "",
              recommendedAddressLine2: "",
              recommendedAddressLineCity: "",
              recommendedAddressLineCountry: "",
              recommendedAddressLineState: "",
              saveCustomerStatus: SaveCustomerStatus.notSaving,
              recommendedAddressLineZipCode: "",
              showRecommendedDialog: false,
              orderAddress: "",
            ));
          }
        } else {
          emit(state.copyWith(
              message: "Recommended address not found",
              recommendedAddress: "",
              saveCustomerStatus: SaveCustomerStatus.notSaving,
              recommendedAddressLine1: event.address1,
              recommendedAddressLine2: event.address2,
              recommendedAddressLineCity: event.city,
              recommendedAddressLineCountry: event.country,
              recommendedAddressLineState: event.state,
              recommendedAddressLineZipCode: event.postalCode,
              showRecommendedDialog: true,
              orderAddress: ""));
        }
      } else {
        emit(state.copyWith(
            message: "Recommended address not found",
            recommendedAddress: "",
            saveCustomerStatus: SaveCustomerStatus.notSaving,
            recommendedAddressLine1: event.address1,
            recommendedAddressLine2: event.address2,
            recommendedAddressLineCity: event.city,
            recommendedAddressLineCountry: event.country,
            recommendedAddressLineState: event.state,
            recommendedAddressLineZipCode: event.postalCode,
            showRecommendedDialog: false,
            orderAddress: ""));
      }
      event.cartBloc.add(UpdateStateMessage());
    });
    on<ClearRecommendedAddressesAddCustomer>((event, emit) async {
      emit(state.copyWith(
          recommendedAddress: "",
          orderAddress: "",
          recommendedAddressLine1: "",
          recommendedAddressLine2: "",
          recommendedAddressLineCity: "",
          recommendedAddressLineCountry: "",
          recommendedAddressLineState: "",
          recommendedAddressLineZipCode: ""));
    });
    on<LoadLookUpData>(
      (event, emit) async {
        List<UserProfile> users = [];
        emit(
            state.copyWith(customerLookUpStatus: CustomerLookUpStatus.loading));
        switch (event.searchType) {
          case SearchType.email:
            users =
                await cartRepository.getCustomerSearchByEmail(event.keySearch);
            if (users.isNotEmpty) {
              for (UserProfile userProfile in users) {
                print("widget.customer.id! ${userProfile.id!}");
                var id = await SharedPreferenceService().getValue(agentId);
                if (id != null && id.isNotEmpty) {
                  if (userProfile.id == id) {
                    userProfile.isSelected = true;
                  }
                }
              }
              emit(state.copyWith(
                  customerLookUpStatus: CustomerLookUpStatus.success,
                  users: users,
                  addCustomerType: event.searchType == SearchType.email
                      ? AddCustomerType.email
                      : AddCustomerType.phone,
                  message: "done"));
            } else {
              emit(state.copyWith(
                  customerLookUpStatus: CustomerLookUpStatus.failure,
                  users: [],
                  addCustomerType: event.searchType == SearchType.email
                      ? AddCustomerType.email
                      : AddCustomerType.phone));
            }
            break;
          case SearchType.phone:
            users =
                await cartRepository.getCustomerSearchByPhone(event.keySearch);
            if (users.isNotEmpty) {
              for (UserProfile userProfile in users) {
                print("widget.customer.id! ${userProfile.id!}");
                var id = await SharedPreferenceService().getValue(agentId);
                if (id != null && id.isNotEmpty) {
                  if (userProfile.id == id) {
                    userProfile.isSelected = true;
                  }
                }
              }
              emit(state.copyWith(
                  customerLookUpStatus: CustomerLookUpStatus.success,
                  users: users,
                  addCustomerType: event.searchType == SearchType.email
                      ? AddCustomerType.email
                      : AddCustomerType.phone));
            } else {
              emit(state.copyWith(
                  customerLookUpStatus: CustomerLookUpStatus.failure,
                  users: [],
                  addCustomerType: event.searchType == SearchType.email
                      ? AddCustomerType.email
                      : AddCustomerType.phone));
            }
            break;
          default:
            users =
                await cartRepository.getCustomerSearchByEmail(event.keySearch);
            if (users.isNotEmpty) {
              emit(state.copyWith(
                  customerLookUpStatus: CustomerLookUpStatus.success,
                  users: users,
                  addCustomerType: event.searchType == SearchType.email
                      ? AddCustomerType.email
                      : AddCustomerType.phone));
            } else {
              emit(state.copyWith(
                  customerLookUpStatus: CustomerLookUpStatus.failure,
                  users: [],
                  addCustomerType: event.searchType == SearchType.email
                      ? AddCustomerType.email
                      : AddCustomerType.phone));
            }
            break;
        }
        return;
      },
      transformer: (events, mapper) {
        return events
            .debounceTime(Duration(milliseconds: 500))
            .asyncExpand(mapper);
      },
    );
    on<ResetData>((event, emit) async {
      emit(state.copyWith(
          customerLookUpStatus: CustomerLookUpStatus.initial, message: "done"));
      return;
    });
    on<ClearMessage>((event, emit) async {
      print("state.message: ${this.state.message}");
      emit(state.copyWith(
          message: "", saveCustomerStatus: SaveCustomerStatus.notSaving));
    });
    on<SelectUser>((event, emit) async {
      if (state.users!.isNotEmpty) {
        List<UserProfile> userProfiles = state.users!;
        for (int i = 0; i < userProfiles.length; i++) {
          if (i == event.index) {
            userProfiles[event.index].isSelected = true;
            if (userProfiles[event.index].id == null) {
              try {
                await launchUrlString(
                    'salesforce1://sObject/${userProfiles[event.index].id}/view');
              } catch (e) {
                print(e);
              }
            } else {
              if (userProfiles[event.index].accountEmailC != null) {
                await SharedPreferenceService().setKey(
                    key: agentEmail,
                    value: userProfiles[event.index].accountEmailC!);
              }
              else if (userProfiles[event.index].emailC != null) {
                await SharedPreferenceService().setKey(
                    key: agentEmail, value: userProfiles[event.index].emailC!);
              }
              else if (userProfiles[event.index].personEmail != null) {
                await SharedPreferenceService().setKey(
                    key: agentEmail,
                    value: userProfiles[event.index].personEmail!);
              }

              if (userProfiles[event.index].name != null) {
                await SharedPreferenceService().setKey(
                    key: savedAgentName,
                    value: userProfiles[event.index].name!);
              }
              if (userProfiles[event.index].firstName != null) {
                await SharedPreferenceService().setKey(
                    key: savedAgentFirstName,
                    value: userProfiles[event.index].firstName!);
              }
              if (userProfiles[event.index].lastName != null) {
                await SharedPreferenceService().setKey(
                    key: savedAgentLastName,
                    value: userProfiles[event.index].lastName!);
              }

              if (userProfiles[event.index].phone != null) {
                await SharedPreferenceService().setKey(
                    key: agentPhone, value: userProfiles[event.index].phone!);
              } else if (userProfiles[event.index].phoneC != null) {
                await SharedPreferenceService().setKey(
                    key: agentPhone, value: userProfiles[event.index].phoneC!);
              } else if (userProfiles[event.index].accountPhoneC != null) {
                await SharedPreferenceService().setKey(
                    key: agentPhone,
                    value: userProfiles[event.index].accountPhoneC!);
              }
              emit(state.copyWith(users: userProfiles, message: "done"));
              event.cartBloc.add(UpdateOrderUser(
                    index: event.index,
                    orderId: event.orderId,
                    accountId: userProfiles[event.index].id!,
                    newCustomer: true,
                  ));
              event.function();
              if (userProfiles[event.index].id != null) {
                await SharedPreferenceService()
                    .setKey(key: agentId, value: userProfiles[event.index].id!);
                await SharedPreferenceService()
                    .setKey(key: agentIndex, value: event.index.toString());
              }
            }
          }
          else {
            userProfiles[i].isSelected = false;
          }
        }
      }
    });
    on<SaveCustomer>((event, emit) async {
      emit(state.copyWith(
          currentFName: event.firstName,
          currentLName: event.lastName,
          currentEmail: event.email,
          currentPhone: event.phone,
          currentAddress1: event.address1,
          currentAddress2: event.address2,
          currentCity: event.city,
          currentState: event.state,
          currentZip: event.zipCode,
          saveCustomerStatus: SaveCustomerStatus.saving));
      var customer = await cartRepository.saveCustomer(
          UserProfile(
            firstName: event.firstName,
            lastName: event.lastName,
            accountEmailC: event.email,
            accountPhoneC: event.phone,
            personMailingStreet: event.address1,
            personMailingCity: event.city,
            personMailingState: event.state,
            personMailingPostalCode: event.zipCode,
          ),
          event.address2,
          state.selectedProficiency,
          state.selectedFrequency,
          state.selectedInstruments.join(",").toString());
      if (customer.id != null && customer.id != "N/A") {
        if (customer.id == null) {
          try {
            await launchUrlString('salesforce1://sObject/${customer.id}/view');
          } catch (e) {
            print(e);
          }
        } else {
          if (customer.id != null) {
            await SharedPreferenceService()
                .setKey(key: agentId, value: customer.id!);
          }
          List<UserProfile> users = [];
          if (customer.accountEmailC != null &&
              customer.accountEmailC!.isNotEmpty) {
            users = await cartRepository
                .getCustomerSearchByEmail(customer.accountEmailC!);
          } else if (customer.emailC != null && customer.emailC!.isNotEmpty) {
            users =
                await cartRepository.getCustomerSearchByEmail(customer.emailC!);
          } else if (customer.personEmail != null &&
              customer.personEmail!.isNotEmpty) {
            users = await cartRepository
                .getCustomerSearchByEmail(customer.personEmail!);
          } else if (customer.accountPhoneC != null &&
              customer.accountPhoneC!.isNotEmpty) {
            users = await cartRepository
                .getCustomerSearchByPhone(customer.accountPhoneC!);
          } else if (customer.phone != null && customer.phone!.isNotEmpty) {
            users =
                await cartRepository.getCustomerSearchByPhone(customer.phone!);
          } else if (customer.phoneC != null && customer.phoneC!.isNotEmpty) {
            users =
                await cartRepository.getCustomerSearchByPhone(customer.phoneC!);
          }
          var id = await SharedPreferenceService().getValue(agentId);

          if (users.isNotEmpty) {
            for (UserProfile userProfile in users) {
              print("widget.customer.id! ${userProfile.id!}");
              if (id != null && id.isNotEmpty) {
                if (userProfile.id == id) {
                  userProfile.isSelected = true;

                  if (userProfile.accountEmailC != null) {
                    await SharedPreferenceService().setKey(
                        key: agentEmail, value: userProfile.accountEmailC!);
                  } else if (userProfile.emailC != null) {
                    await SharedPreferenceService()
                        .setKey(key: agentEmail, value: userProfile.emailC!);
                  } else if (userProfile.personEmail != null) {
                    await SharedPreferenceService().setKey(
                        key: agentEmail, value: userProfile.personEmail!);
                  }

                  if (userProfile.name != null) {
                    await SharedPreferenceService()
                        .setKey(key: savedAgentName, value: userProfile.name!);
                  }

                  if (userProfile.phone != null) {
                    await SharedPreferenceService()
                        .setKey(key: agentPhone, value: userProfile.phone!);
                  } else if (userProfile.phoneC != null) {
                    await SharedPreferenceService()
                        .setKey(key: agentPhone, value: userProfile.phoneC!);
                  } else if (userProfile.accountPhoneC != null) {
                    await SharedPreferenceService().setKey(
                        key: agentPhone, value: userProfile.accountPhoneC!);
                  }
                }
              }
            }
            event.cartBloc.add(UpdateOrderUser(
                  index: users.indexOf(
                      users.firstWhere((element) => element.isSelected!)),
                  orderId: event.orderId,
                  accountId: id,
                  newCustomer: true,
                ));
          }
          emit(state.copyWith(
              saveCustomerStatus: SaveCustomerStatus.notSaving,
              customerLookUpStatus: CustomerLookUpStatus.success,
              message: "done",
              users: users,
              newCustomerAdded: true));
        }
      } else {
        emit(state.copyWith(
            saveCustomerStatus: SaveCustomerStatus.notSaving,
            message: customer.name));
      }
    });
  }
}
