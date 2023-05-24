part of 'search_employees_bloc.dart';

@immutable
abstract class SearchEmployeesEvent extends Equatable {
  SearchEmployeesEvent();
  @override
  List<Object> get props => [];
}

class GetDefaultEmployees extends SearchEmployeesEvent {
  final String orderId;
  GetDefaultEmployees({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class SearchEmployees extends SearchEmployeesEvent {
  final String keySearch;
  final bool isPaging;
  SearchEmployees({required this.keySearch, required this.isPaging});

  @override
  List<Object> get props => [];
}

class ClearData extends SearchEmployeesEvent {
  ClearData();

  @override
  List<Object> get props => [];
}
