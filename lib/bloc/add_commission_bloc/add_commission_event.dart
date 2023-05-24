part of 'add_commission_bloc.dart';

abstract class AddCommissionEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// class SearchEmployees extends AddCommissionEvent {
//   final String searchText;
//   SearchEmployees(this.searchText);

//   @override
//   List<Object> get props => [searchText];
// }

class PageLoad extends AddCommissionEvent {
  String orderId;
  PageLoad(this.orderId);

  @override
  List<Object> get props => [];
}

class ListSelectedEmployeesRemove extends AddCommissionEvent {
  final CommissionEmployee selectedEmployeeModel;
  ListSelectedEmployeesRemove({required this.selectedEmployeeModel});

  @override
  List<Object> get props => [selectedEmployeeModel];
}

class ListSelectedEmployeesAdd extends AddCommissionEvent {
  final SearchedEmployeeModel employee;
  ListSelectedEmployeesAdd({required this.employee});

  @override
  List<Object> get props => [employee];
}

class ListSelectedEmployeesSet extends AddCommissionEvent {
  final List<SelectedEmployeeModel> selectedEmployeeModel;
  ListSelectedEmployeesSet({required this.selectedEmployeeModel});

  @override
  List<Object> get props => [selectedEmployeeModel];
}

class SelectedEmployeeJsonModelClear extends AddCommissionEvent {
  SelectedEmployeeJsonModelClear();

  @override
  List<Object> get props => [];
}

class SelectedEmployeeJsonModelAdd extends AddCommissionEvent {
  final SelectedEmployeeModel selectedEmployeeModel;
  SelectedEmployeeJsonModelAdd({required this.selectedEmployeeModel});

  @override
  List<Object> get props => [selectedEmployeeModel];
}

class SaveCommission extends AddCommissionEvent {
  final List<CommissionEmployee> selectedEmployeesModel;
  final String orderID;
  final BuildContext context;
  SaveCommission({required this.selectedEmployeesModel, required this.orderID, required this.context});

  @override
  List<Object> get props => [selectedEmployeesModel, orderID,context];
}

class DivideSelectedEmployeeCommission extends AddCommissionEvent {
  DivideSelectedEmployeeCommission();
}
