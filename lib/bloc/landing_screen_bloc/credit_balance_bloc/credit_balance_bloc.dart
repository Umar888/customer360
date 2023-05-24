import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gc_customer_app/data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'package:gc_customer_app/models/landing_screen/credit_balance.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'credit_balance_event.dart';
part 'credit_balance_state.dart';

class CreditBalanceBloc extends Bloc<CreditBalanceEvent, CreditBalanceState> {
  final LandingScreenRepository landingScreenRepository =
      LandingScreenRepository();

  CreditBalanceBloc() : super(CreditBalanceFailure()) {
    on<LoadCreditData>((event, emit) async {
      emit(CreditBalanceProgress());
      String email = await SharedPreferenceService().getValue(agentEmail);
      var balance =
          await landingScreenRepository.getCreditBalance(email).catchError((_) {
        return null;
      });
      emit(CreditBalanceSuccess(balance: balance));

      return;
    });
  }
}
