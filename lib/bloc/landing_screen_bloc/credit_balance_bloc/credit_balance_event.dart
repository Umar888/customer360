part of 'credit_balance_bloc.dart';

@immutable
abstract class CreditBalanceEvent extends Equatable {
  CreditBalanceEvent();
  @override
  List<Object> get props => [];
}

class LoadCreditData extends CreditBalanceEvent {}
