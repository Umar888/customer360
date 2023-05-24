part of 'quote_log_bloc.dart';

abstract class QuoteLogEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class PageLoad extends QuoteLogEvent {
  final String orderID;

  PageLoad({required this.orderID});

  @override
  List<Object> get props => [orderID];
}

class EmptyMessage extends QuoteLogEvent {
  EmptyMessage();
}

class OnPressQuote extends QuoteLogEvent {
  final int index;

  OnPressQuote({required this.index});

  @override
  List<Object> get props => [index];
}
