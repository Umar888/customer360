part of 'search_employees_bloc.dart';

@immutable
abstract class SearchEmployeesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchEmployeesInitial extends SearchEmployeesState {}

class SearchEmployeesProgress extends SearchEmployeesState {}

class SearchEmployeesFailure extends SearchEmployeesState {}

class SearchEmployeesSuccess extends SearchEmployeesState {
  final List<SearchedEmployeeModel>? employees;
  final List<SearchedEmployeeModel>? defaultEmployees;

  SearchEmployeesSuccess({this.employees, this.defaultEmployees});

  @override
  List<Object?> get props => [employees, defaultEmployees];
}
