import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/profile_screen_bloc/payment_cards_bloc/payment_cards_bloc.dart';
import 'package:gc_customer_app/data/data_sources/profile_screen/payment_cards_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/profile/payment_cards_repository.dart';
import 'package:gc_customer_app/models/payment_card_model.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PaymentCardsBloc paymentCardsBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
  });

  setUp(
    () {
      var paymentCardDataSource = PaymentCardsDataSource();
      paymentCardDataSource.httpService.client = MockClient(
        (request) async {
          return Response(
              json.encode({
                "cardOnFileResponse": {
                  "userCards": [
                    {
                      "paymentType": "CreditCard",
                      "isExpired": null,
                      "id": "1300001",
                      "expYear": "2017",
                      "expMonth": "04",
                      "cardType": "VISA",
                      "cardNumberDecrypted": "4486320000000007",
                      "cardNumber": "4486320000000007",
                      "address": {
                        "zipCode": "10004",
                        "street2": null,
                        "street1": "104 Maple Dr.",
                        "state": "NY",
                        "phone": {
                          "value": "0404040404",
                          "type": "mobile",
                          "isPrimary": false
                        },
                        "lastName": "04",
                        "firstName": "Customer",
                        "country": "US",
                        "companyName": null,
                        "city": "New York"
                      }
                    }
                  ],
                  "status": "CONFIRMED",
                  "profileId": "259380082",
                  "failureMessage": null
                }
              }),
              200);
        },
      );
      paymentCardsBloc =
          PaymentCardsBloc(PaymentCardsRepository(paymentCardDataSource));
    },
  );

  blocTest(
    'Get added cards',
    build: () => paymentCardsBloc,
    act: (bloc) => bloc.add(LoadCardsData()),
    expect: () => [
      PaymentCardsSuccess(paymentCardsModel: [
        PaymentCardModel.fromJson({
          "paymentType": "CreditCard",
          "isExpired": null,
          "id": "1300001",
          "expYear": "2017",
          "expMonth": "04",
          "cardType": "VISA",
          "cardNumberDecrypted": "4486320000000007",
          "cardNumber": "4486320000000007",
          "address": {
            "zipCode": "10004",
            "street2": null,
            "street1": "104 Maple Dr.",
            "state": "NY",
            "phone": {
              "value": "0404040404",
              "type": "mobile",
              "isPrimary": false
            },
            "lastName": "04",
            "firstName": "Customer",
            "country": "US",
            "companyName": null,
            "city": "New York"
          }
        })
      ]),
    ],
  );
}
