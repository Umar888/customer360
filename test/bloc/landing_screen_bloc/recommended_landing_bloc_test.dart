import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/recommended_landing_bloc/recommended_landing_bloc.dart';
import 'package:gc_customer_app/data/data_sources/landing_screen_data_source/landing_screen_data_source.dart';
import 'package:gc_customer_app/models/landing_screen/landing_screen_recommendation_model_buy_again.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RecommendedLandingBloc recommendedLandingBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;

  setUp(
    () {
      var landingScreenDataSource = LandingScreenDataSource();
      landingScreenDataSource.httpService.client = MockClient((request) async {
        if (successScenario) {
          if (request.matches(Endpoints.lRecommendation.escape)) {
            print("Success: ${request.url}");
            return Response(
                json.encode({
                  "message": "record found.",
                  "productBuyAgain": [{}],
                }),
                200);
          } else {
            print("API call not mocked: ${request.url}");
            return Response(json.encode({}), 205);
          }
        } else {
          print("Failed: ${request.url}");
          return Response(json.encode({}), 205);
        }
      });
      recommendedLandingBloc = RecommendedLandingBloc();
      recommendedLandingBloc.landingScreenRepository.landingScreenDataSource = landingScreenDataSource;
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<RecommendedLandingBloc, RecommendedLandingState>(
        'Load Recommended Data',
        build: () => recommendedLandingBloc,
        act: (bloc) => bloc.add(LoadRecommendedData()),
        expect: () => [
          RecommendedLandingProgress(),
          RecommendedLandingSuccess(
            recommendedBuyAgain: LandingScreenRecommendationModelBuyAgain(
              productBuyAgain: [ProductBuyAgain.fromJson({})],
              message: "record found.",
            ),
          ),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);

      blocTest<RecommendedLandingBloc, RecommendedLandingState>(
        'Load Recommended Data Failure',
        build: () => recommendedLandingBloc,
        act: (bloc) => bloc.add(LoadRecommendedData()),
        expect: () => [
          RecommendedLandingProgress(),
          RecommendedLandingSuccess(recommendedBuyAgain: LandingScreenRecommendationModelBuyAgain(productBuyAgain: [])),
        ],
      );
    },
  );
}
