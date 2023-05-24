part of 'quote_log_bloc.dart';

enum QuoteLogStatus { initState, loadState, successState, failedState }

class QuoteLogState extends Equatable {
  QuoteLogState({
    this.quoteLogStatus = QuoteLogStatus.initState,
    this.orderDetailModel =const [],
    this.maxExtent = 0.325,
    this.minExtent = 0.325,
    this.initialExtent = 0.325,
    this.message = "",
    this.isExpanded = false,
    this.quoteList =const [],
  });

  final QuoteLogStatus quoteLogStatus;
  final List<CartDetailModel> orderDetailModel;
  final double maxExtent;
  final double minExtent;
  final bool isExpanded;
  final double initialExtent;
  final List<QuoteHistoryList> quoteList;
  final String message;

  QuoteLogState copyWith({
    QuoteLogStatus? quoteLogStatus,
    List<CartDetailModel>? orderDetailModel,
    double? maxExtent,
    double? minExtent,
    bool? isExpanded,
    String? message,
    double? initialExtent,
    List<QuoteHistoryList>? quoteList,
  }) {
    return QuoteLogState(
      quoteLogStatus: quoteLogStatus ?? this.quoteLogStatus,
      maxExtent: maxExtent ?? this.maxExtent,
      minExtent: minExtent ?? this.minExtent,
      message: message ?? this.message,
      isExpanded: isExpanded ?? this.isExpanded,
      initialExtent: initialExtent ?? this.initialExtent,
      orderDetailModel: orderDetailModel ?? this.orderDetailModel,
      quoteList: quoteList ?? this.quoteList,
    );
  }

  @override
  List<Object> get props => [
        quoteLogStatus,
        maxExtent,
        minExtent,
        isExpanded,
        initialExtent,
        orderDetailModel,
        quoteList,
         message ///missed variable
      ];
}
