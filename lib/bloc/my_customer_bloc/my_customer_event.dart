part of 'my_customer_bloc.dart';

abstract class MyCustomerEvent extends Equatable {
  MyCustomerEvent();
}

class LoadMyCustomerInformation extends MyCustomerEvent {
  final String filter;
  final DateTime startDate;
  final DateTime endDate;
  LoadMyCustomerInformation(this.filter, this.startDate, this.endDate);

  @override
  List<Object?> get props => [];
}

class LoadEmployeeInformation extends MyCustomerEvent {
  final String filter;
  final DateTime startDate;
  final DateTime endDate;
  final String employeeId;
  LoadEmployeeInformation(
      this.filter, this.startDate, this.endDate, this.employeeId);

  @override
  List<Object?> get props => [];
}
