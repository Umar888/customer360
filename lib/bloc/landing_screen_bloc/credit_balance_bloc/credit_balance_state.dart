part of 'credit_balance_bloc.dart';

@immutable
abstract class CreditBalanceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreditBalanceInitial extends CreditBalanceState {}

class CreditBalanceProgress extends CreditBalanceState {}

class CreditBalanceFailure extends CreditBalanceState {}

class CreditBalanceSuccess extends CreditBalanceState {
  final CreditBalance? balance;

  CreditBalanceSuccess({this.balance});

  @override
  List<Object?> get props => [balance];
}
