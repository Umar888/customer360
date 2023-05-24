import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_recommendation_model_buy_again.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'recommended_landing_event.dart';

part 'recommended_landing_state.dart';

class RecommendedLandingBloc extends Bloc<RecommendedLandingEvent, RecommendedLandingState> {
  final LandingScreenRepository landingScreenRepository = LandingScreenRepository();

  RecommendedLandingBloc() : super(RecommendedLandingFailure()) {
    on<LoadRecommendedData>((event, emit) async {
      emit(RecommendedLandingProgress());
      String recordId = await SharedPreferenceService().getValue(agentId);

      String id = await SharedPreferenceService().getValue(agentId);
      try {
//        final recommended = await landingScreenRepository.getRecommendation("BrowsingHistory", id);

        final recommendedBuyAgain = await landingScreenRepository.getRecommendationBuyAgain("BuyAgain", id);

        emit(RecommendedLandingSuccess(recommendedBuyAgain: recommendedBuyAgain));
      } catch (e) {
        emit(RecommendedLandingFailure());
      }

      return;
    });
  }
}
