import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/promotion_bloc/promotion_bloc.dart';
import 'package:gc_customer_app/data/data_sources/promotion_screen_data_source/promotion_screen_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/promotions_screen_repository/promotions_screen_repository.dart';
import 'package:gc_customer_app/models/promotion_model.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PromotionBloC promotionBloc;
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
      var promotionDataSource = PromotionsScreenDataSource()
        ..httpService.client = MockClient((request) async {
          if (successScenario) {
            if (request.matches(Endpoints.kClientPromotions.escape)) {
              print("Success: ${request.url}");
              return Response(json.encode({"topPromotion": {}, "activePromotions":[{}]}), 200);
            } else {
              print("API call not mocked: ${request.url}");
              return Response(json.encode({}), 205);
            }
          } else {
            print("Failed: ${request.url}");
            return Response(json.encode({}), 205);
          }
        });
      promotionBloc = PromotionBloC(PromotionsScreenRepository());
      promotionBloc.promotionRepo.promotionsScreenDataSource = promotionDataSource;
    },
  );

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<PromotionBloC, PromotionScreenState>(
        'Load Promotions',
        build: () => promotionBloc,
        act: (bloc) => bloc.add(LoadPromotions()),
        expect: () => [
          PromotionScreenSuccess(topPromotion: PromotionModel(), activePromotions: [PromotionModel()]),
        ],
      );
    },
  );
}
