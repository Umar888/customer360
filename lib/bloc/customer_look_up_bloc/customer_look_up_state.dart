part of 'customer_look_up_bloc.dart';

@immutable
abstract class CustomerLookUpState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CustomerLookUpInitial extends CustomerLookUpState {}

class CustomerLookUpProgress extends CustomerLookUpState {}

class SaveCustomerProgress extends CustomerLookUpState {
  final bool? isShowDialog;
  final String? message;
  final bool? isLoading;
  final bool? isShowOptions;
  final List<String>? proficiencies;
  final List<String>? frequencies;
  final List<String>? instruments;
  final String selectedProficiency;
  final String selectedFrequency;
  final List<String> selectedInstruments;
  final VerifyAddress? enteredAddress;
  final VerifyAddress? recommendAddress;
  SaveCustomerProgress(
      {this.isShowDialog,
        this.recommendAddress,
        this.frequencies=const [],
        this.selectedProficiency="",
        this.message="",
        this.selectedFrequency="",
        this.selectedInstruments=const [],
        this.instruments=const [],
        this.proficiencies=const [],
        this.enteredAddress,
        this.isLoading = false,
        this.isShowOptions=false});
  @override
  List<Object?> get props => [message,
    isLoading,
    isShowDialog,
    enteredAddress,
    isShowOptions,
    recommendAddress,
    frequencies,
    selectedProficiency,
    selectedFrequency,
    selectedInstruments,
    instruments,
    proficiencies];
}

class CustomerLookUpFailure extends CustomerLookUpState {}

class SaveCustomerFailure extends CustomerLookUpState {
  final bool? isShowDialog;
  final String? message;
  final bool? isLoading;
  final bool? isShowOptions;
  final List<String>? proficiencies;
  final List<String>? frequencies;
  final List<String>? instruments;
  final String selectedProficiency;
  final String selectedFrequency;
  final List<String> selectedInstruments;
  final VerifyAddress? enteredAddress;
  final VerifyAddress? recommendAddress;
  SaveCustomerFailure(
      {this.isShowDialog,
        this.recommendAddress,
        this.frequencies=const [],
        this.selectedProficiency="",
        this.message="",
        this.selectedFrequency="",
        this.selectedInstruments=const [],
        this.instruments=const [],
        this.proficiencies=const [],
        this.enteredAddress,
        this.isLoading = false,
        this.isShowOptions=false});
  @override
  List<Object?> get props => [message,
    isLoading,
    isShowDialog,
    enteredAddress,
    isShowOptions,
    recommendAddress,
    frequencies,
    selectedProficiency,
    selectedFrequency,
    selectedInstruments,
    instruments,
    proficiencies];
}

class CustomerLookUpSuccess extends CustomerLookUpState {
  final List<UserProfile>? users;
  final SearchType type;

  CustomerLookUpSuccess({this.users, required this.type});

  @override
  List<Object?> get props => [users, type];
}

class SaveCustomerSuccess extends CustomerLookUpState {
  final UserProfile customer;
  SaveCustomerSuccess(this.customer);

  @override
  List<Object?> get props => [customer];
}

class SearchSuccess extends CustomerLookUpState {
  final List<UserProfile>? searchModels;
  SearchSuccess({this.searchModels});

  @override
  List<Object?> get props => [searchModels];
}
