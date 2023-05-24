part of 'add_commission_bloc.dart';

enum AddCommissionStatus { initState, loadState, successState, failedState }

class AddCommissionState extends Equatable {
  AddCommissionState({
    this.addCommissionStatus = AddCommissionStatus.initState,
    this.selectedEmployeeJsonModel =const [],
    this.showSubmissionLoading = false,
    this.currentIndex = 0,
    this.selectedEmployee = "",
    this.currentPercentage = 100,
    this.listSelectedEmployees =const [],
    this.listEmployeesSameStore =const [],
    this.needRebuild = false,
  });

  AddCommissionStatus addCommissionStatus;
  final List<SelectedEmployeeJsonModel> selectedEmployeeJsonModel;
  final bool showSubmissionLoading;
  final int currentIndex;
  final String selectedEmployee;
  final double currentPercentage;
  List<CommissionEmployee> listSelectedEmployees;
  List<SearchedEmployeeModel> listEmployeesSameStore;
  final bool needRebuild;

  AddCommissionState copyWith(
      {AddCommissionStatus? addCommissionStatus,
      List<SelectedEmployeeJsonModel>? selectedEmployeeJsonModel,
      bool? showSubmissionLoading,
      int? currentIndex,
      String? selectedEmployee,
      double? currentPercentage,
      List<String>? listPercentages,
      List<CommissionEmployee>? listSelectedEmployees,
      List<SearchedEmployeeModel>? listEmployeesSameStore,
      bool? needRebuild}) {
    return AddCommissionState(
        addCommissionStatus: addCommissionStatus ?? this.addCommissionStatus,
        selectedEmployeeJsonModel:
            selectedEmployeeJsonModel ?? this.selectedEmployeeJsonModel,
        showSubmissionLoading:
            showSubmissionLoading ?? this.showSubmissionLoading,
        currentIndex: currentIndex ?? this.currentIndex,
        selectedEmployee: selectedEmployee ?? this.selectedEmployee,
        currentPercentage: currentPercentage ?? this.currentPercentage,
        listSelectedEmployees:
            listSelectedEmployees ?? this.listSelectedEmployees,
        listEmployeesSameStore:
            listEmployeesSameStore ?? this.listEmployeesSameStore,
        needRebuild: needRebuild ?? this.needRebuild);
  }

  @override
  List<Object> get props => [
        addCommissionStatus,
        selectedEmployeeJsonModel,
        showSubmissionLoading,
        currentPercentage,
        listSelectedEmployees,
        listEmployeesSameStore,
        needRebuild,
      ];
}
