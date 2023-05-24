part of 'add_customer_bloc.dart';

enum AddCustomerType { email, phone }

enum SaveCustomerStatus { saving, notSaving }

enum CustomerLookUpStatus { initial, success, loading, failure }

class AddCustomerState extends Equatable {
  final AddCustomerType addCustomerType;
  final SaveCustomerStatus saveCustomerStatus;
  final CustomerLookUpStatus customerLookUpStatus;
  final List<UserProfile>? users;
  final List<String>? proficiencies;
  final List<String>? frequencies;
  final List<String>? instruments;
  final String selectedProficiency;
  final String selectedFrequency;
  final List<String> selectedInstruments;
  final GlobalKey<FormState>? formKey;
  final String message;
  final String currentFName;
  final String currentLName;
  final String currentEmail;
  final String currentPhone;
  final String currentZip;
  final String currentCity;
  final String currentState;
  final String currentAddress1;
  final String currentAddress2;
  final String orderAddress;
  final String recommendedAddress;
  final String recommendedAddressLine1;
  final String recommendedAddressLine2;
  final String recommendedAddressLineCity;
  final String recommendedAddressLineState;
  final String recommendedAddressLineCountry;
  final String recommendedAddressLineZipCode;
  final bool showRecommendedDialog;
  final bool showOption;
  final bool callCompleteOrder;
  final bool newCustomerAdded;

  AddCustomerState({
    this.addCustomerType = AddCustomerType.email,
    this.saveCustomerStatus = SaveCustomerStatus.notSaving,
    this.customerLookUpStatus = CustomerLookUpStatus.initial,
    this.users = const [],
    this.proficiencies = const [],
    this.frequencies = const [],
    this.instruments = const [],
    this.selectedInstruments = const [],
    this.formKey,
    this.selectedFrequency = "",
    this.selectedProficiency = "",
    this.currentFName = "",
    this.currentLName = "",
    this.currentZip = "",
    this.currentCity = "",
    this.currentState = "",
    this.currentAddress1 = "",
    this.orderAddress = "",
    this.recommendedAddress = "",
    this.recommendedAddressLine1 = "",
    this.recommendedAddressLine2 = "",
    this.recommendedAddressLineCity = "",
    this.recommendedAddressLineCountry = "",
    this.recommendedAddressLineState = "",
    this.recommendedAddressLineZipCode = "",
    this.message = "",
    this.currentEmail = "",
    this.currentPhone = "",
    this.currentAddress2 = "",
    this.showRecommendedDialog = false,
    this.showOption = false,
    this.newCustomerAdded = false,
    this.callCompleteOrder = false,
  });

  AddCustomerState copyWith(
      {AddCustomerType? addCustomerType,
      CustomerLookUpStatus? customerLookUpStatus,
      SaveCustomerStatus? saveCustomerStatus,
      List<UserProfile>? users,
      List<String>? proficiencies,
      List<String>? frequencies,
      List<String>? instruments,
      String? selectedProficiency,
      String? selectedFrequency,
      bool? showOption,
      List<String>? selectedInstruments,
      GlobalKey<FormState>? formKey,
      String? message,
      String? orderAddress,
      String? recommendedAddress,
      String? recommendedAddressLine1,
      String? recommendedAddressLine2,
      String? recommendedAddressLineCity,
      String? recommendedAddressLineState,
      String? recommendedAddressLineCountry,
      String? recommendedAddressLineZipCode,
      String? currentFName,
      String? currentLName,
      String? currentZip,
      String? currentCity,
      String? currentState,
      String? currentAddress1,
      String? currentAddress2,
      String? currentEmail,
      String? currentPhone,
      bool? showRecommendedDialog,
      bool? newCustomerAdded,
      bool? callCompleteOrder}) {
    return AddCustomerState(
        addCustomerType: addCustomerType ?? this.addCustomerType,
        users: users ?? this.users,
        proficiencies: proficiencies ?? this.proficiencies,
        frequencies: frequencies ?? this.frequencies,
        instruments: instruments ?? this.instruments,
        selectedInstruments: selectedInstruments ?? this.selectedInstruments,
        selectedProficiency: selectedProficiency ?? this.selectedProficiency,
        selectedFrequency: selectedFrequency ?? this.selectedFrequency,
        newCustomerAdded: newCustomerAdded ?? this.newCustomerAdded,
        message: message ?? this.message,
        showOption: showOption ?? this.showOption,
        formKey: formKey ?? this.formKey,
        saveCustomerStatus: saveCustomerStatus ?? this.saveCustomerStatus,
        customerLookUpStatus: customerLookUpStatus ?? this.customerLookUpStatus,
        orderAddress: orderAddress ?? this.orderAddress,
        recommendedAddress: recommendedAddress ?? this.recommendedAddress,
        recommendedAddressLine1: recommendedAddressLine1 ?? this.recommendedAddressLine1,
        recommendedAddressLine2: recommendedAddressLine2 ?? this.recommendedAddressLine2,
        recommendedAddressLineCity: recommendedAddressLineCity ?? this.recommendedAddressLineCity,
        recommendedAddressLineState: recommendedAddressLineState ?? this.recommendedAddressLineState,
        recommendedAddressLineCountry: recommendedAddressLineCountry ?? this.recommendedAddressLineCountry,
        recommendedAddressLineZipCode: recommendedAddressLineZipCode ?? this.recommendedAddressLineZipCode,
        showRecommendedDialog: showRecommendedDialog ?? this.showRecommendedDialog,
        callCompleteOrder: callCompleteOrder ?? this.callCompleteOrder,
        currentFName: currentFName ?? this.currentFName,
        currentLName: currentLName ?? this.currentLName,
        currentCity: currentCity ?? this.currentCity,
        currentState: currentState ?? this.currentState,
        currentAddress1: currentAddress1 ?? this.currentAddress1,
        currentZip: currentZip ?? this.currentZip,
        currentEmail: currentEmail ?? this.currentEmail,
        currentPhone: currentPhone ?? this.currentPhone,
        currentAddress2: currentAddress2 ?? this.currentAddress2);
  }

  @override
  List<Object?> get props => [
        addCustomerType,
        customerLookUpStatus,
        users,
        message,
        formKey,
        saveCustomerStatus,
        proficiencies,
        frequencies,
        instruments,
        selectedInstruments,
        selectedProficiency,
        selectedFrequency,
        orderAddress,
        showOption,
        newCustomerAdded,
        recommendedAddress,
        recommendedAddressLine1,
        recommendedAddressLine2,
        recommendedAddressLineCity,
        recommendedAddressLineState,
        recommendedAddressLineCountry,
        showRecommendedDialog,
        recommendedAddressLineZipCode,
        callCompleteOrder,
        currentFName,
        currentLName,
        currentCity,
        currentState,
        currentAddress1,
        currentZip,
        currentEmail,
        currentAddress2,
        currentPhone,
      ];
}
