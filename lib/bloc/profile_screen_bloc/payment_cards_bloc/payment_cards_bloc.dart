import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gc_customer_app/data/reporsitories/profile/payment_cards_repository.dart';
import 'package:gc_customer_app/models/payment_card_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'payment_cards_event.dart';
part 'payment_cards_state.dart';

class PaymentCardsBloc extends Bloc<PaymentCardsEvent, PaymentCardsState> {
  final PaymentCardsRepository paymentCardsRepository;

  PaymentCardsBloc(this.paymentCardsRepository) : super(PaymentCardsFailure()) {
    on<LoadCardsData>((event, emit) async {
      String userRecordId = await SharedPreferenceService().getValue(agentId);
      if ((userRecordId).isNotEmpty) {
        var paymentCards = await paymentCardsRepository
            .getProfilePaymentCards(userRecordId)
            .catchError((error) {
          emit(PaymentCardsFailure());
          return error;
        });

        emit(PaymentCardsSuccess(paymentCardsModel: paymentCards));

        return;
      }

      emit(PaymentCardsFailure());
      return;
    });
  }

  get kUserRecordId => null;
}
