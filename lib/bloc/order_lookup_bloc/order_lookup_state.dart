part of 'order_lookup_bloc.dart';

@immutable
abstract class OrderLookUpState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderLookUpInitial extends OrderLookUpState {}

class OrderLookUpProgress extends OrderLookUpState {}

class OrderLookUpFailure extends OrderLookUpState {
  final String? message;

  OrderLookUpFailure({this.message});

  @override
  List<Object?> get props => [message];
}

class OrderLookUpSuccess extends OrderLookUpState {
  final List<OrderLookupModel> orders;
  OrderLookUpSuccess({required this.orders});

  @override
  List<Object?> get props => [orders];
}
