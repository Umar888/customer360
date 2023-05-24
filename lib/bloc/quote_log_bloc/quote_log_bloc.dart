import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/data/data_sources/cart_data_source/cart_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/cart_reporsitory/cart_repository.dart';
import 'package:gc_customer_app/models/quotes_history_list_model/quotes_history_list_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

import '../../data/reporsitories/quote_log_reporsitory/quote_log_repository.dart';
import '../../models/cart_model/cart_detail_model.dart';

part 'quote_log_state.dart';
part 'quote_log_event.dart';

class QuoteLogBloc extends Bloc<QuoteLogEvent, QuoteLogState> {
  QuoteLogRepository quoteLogRepository;

  QuoteLogBloc({required this.quoteLogRepository})
      : super(QuoteLogState()) {

    on<PageLoad>((event, emit) async {
      emit(state.copyWith(quoteLogStatus: QuoteLogStatus.loadState));
      QuotesHistoryListModel quotesHistoryListModel;

      // Quote history work
      var loggedInUserId =
          await SharedPreferenceService().getValue(loggedInAgentId);
      String recordId = await SharedPreferenceService().getValue(agentId);

      final quotesHistoryResponse = await quoteLogRepository.getQuotesHistoryList(
          recordId: recordId,
          orderId: event.orderID,
          loggedInUserId: loggedInUserId);
      quotesHistoryListModel =
          QuotesHistoryListModel.fromJson(quotesHistoryResponse.data);

      if (quotesHistoryListModel.quoteHistoryList.isEmpty) {
        emit(state.copyWith(
            quoteLogStatus: QuoteLogStatus.failedState,
            orderDetailModel: [],
            quoteList: quotesHistoryListModel.quoteHistoryList));
      } else {
        for (var i = 0;
            i < quotesHistoryListModel.quoteHistoryList.length;
            i++) {
          if (i == 0) {
            quotesHistoryListModel.quoteHistoryList[0].isPressed = true;
          } else {
            quotesHistoryListModel.quoteHistoryList[i].isPressed = false;
          }
        }
        emit(state.copyWith(
            quoteLogStatus: QuoteLogStatus.successState,
            orderDetailModel: [],
            quoteList: quotesHistoryListModel.quoteHistoryList));
      }
    });

    on<EmptyMessage>((event, emit) {
      emit(state.copyWith(
          message: ""
      ));
    });

    on<OnPressQuote>((event, emit) async {
      List<QuoteHistoryList> quoteList = state.quoteList;
      for (var i = 0; i < quoteList.length; i++) {
        if (i == event.index) {
          quoteList[event.index].isPressed = true;
        } else {
          quoteList[i].isPressed = false;
        }
      }
      emit(state.copyWith(quoteList: quoteList,message: "done"));
    });
  }
}
