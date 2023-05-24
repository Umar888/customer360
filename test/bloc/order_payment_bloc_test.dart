import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/cart_bloc/order_cards_bloc/order_cards_bloc.dart';
import 'package:gc_customer_app/data/data_sources/cart_data_source/cart_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/cart_reporsitory/cart_repository.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/model/credit_card_model_save.dart';
import 'package:gc_customer_app/models/landing_screen/credit_balance.dart';
import 'package:gc_customer_app/models/payment_card_model.dart';
import 'package:gc_customer_app/services/networking/networking_service.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderPaymentScreenBlocImpl extends Mock implements CartDataSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CartDataSource orderPaymentScreenBlocImpl;
  late OrderCardsBloc orderCardsBloc;
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
  });

  setUp(
    () {
      orderPaymentScreenBlocImpl = CartDataSource();
      orderPaymentScreenBlocImpl.httpService = HttpService();
      orderPaymentScreenBlocImpl.httpService.client = MockClient((request) async {
        return Response(
            json.encode({
              "promoCode": [
                {"PromoName": "PLC promos", "promoDesc": []},
                {"PromoName": "Fortiva promos", "promoDesc": []}
              ],
              "giftCardBalance": null,
              "gearCardInfo": null,
              "essentialCardInfo": null,
              "COAStatus":
                  "{\"status\":\"CONFIRMED\",\"OMSCustomerID\":\"700665666\",\"CurrentBalance\":\"-2061.93\",\"AvailableAmount\":\"1435.66\"}",
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
                      "phone": {"value": "0404040404", "type": "mobile", "isPrimary": false},
                      "lastName": "04",
                      "firstName": "Customer",
                      "country": "US",
                      "companyName": null,
                      "city": "New York"
                    }
                  }
                ]
              }
            }),
            200);
      });
      orderCardsBloc = OrderCardsBloc(CartRepository(cartDataSource: orderPaymentScreenBlocImpl));
    },
  );

  group(
    "Success Scenarios",
    () {
      blocTest<OrderCardsBloc, OrderCardsState>(
        "Load data before go to Order Payment Screen",
        setUp: () {},
        build: () {
          return orderCardsBloc;
        },
        wait: Duration(milliseconds: 500),
        act: (bloc) => bloc.add(LoadCardsData('', 1234)),
        expect: () {
          var existingCard = PaymentCardModel.fromJson({
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
              "phone": {"value": "0404040404", "type": "mobile", "isPrimary": false},
              "lastName": "04",
              "firstName": "Customer",
              "country": "US",
              "companyName": null,
              "city": "New York"
            }
          });
          var creditBalance = CreditBalance.fromJson(jsonDecode(
              "{\"status\":\"CONFIRMED\",\"OMSCustomerID\":\"700665666\",\"CurrentBalance\":\"-2061.93\",\"AvailableAmount\":\"1435.66\"}"));
          return [
            OrderCardsState(existingCards: []),
            OrderCardsState(existingCards: [existingCard]),
            OrderCardsState(coaCreditBalance: creditBalance, existingCards: [existingCard]),
            OrderCardsState(essentialFinance: [], gearFinance: [], coaCreditBalance: creditBalance, existingCards: [existingCard])
          ];
        },
      );

      blocTest(
        'Test add first credit card',
        build: () => orderCardsBloc,
        act: (bloc) => orderCardsBloc.add(AddNewCard(CreditCardModelSave(cardNumber: '1234', cvvCode: '1234'), 1000)),
        expect: () => [
          orderCardsBloc.state.copyWith(orderCardsModel: [
            CreditCardModelSave(cardNumber: '1234', cvvCode: '1234'),
          ], isAddedNewCard: true),
          orderCardsBloc.state.copyWith(orderCardsModel: [CreditCardModelSave(cardNumber: '1234', cvvCode: '1234')], isAddedNewCard: false)
        ],
      );

      blocTest(
        'Test add second credit card',
        setUp: () {
          orderCardsBloc.state.orderCardsModel = [
            CreditCardModelSave(cardNumber: '1234', cvvCode: '1234'),
          ];
        },
        wait: Duration(seconds: 1),
        build: () => orderCardsBloc,
        act: (bloc) => [
          orderCardsBloc.add(AddNewCard(CreditCardModelSave(cardNumber: '12345', cvvCode: '1234'), 1000)),
        ],
        expect: () => [
          orderCardsBloc.state.copyWith(orderCardsModel: [
            CreditCardModelSave(cardNumber: '1234', cvvCode: '1234'),
            CreditCardModelSave(cardNumber: '12345', cvvCode: '1234'),
          ], isAddedNewCard: true),
          orderCardsBloc.state.copyWith(orderCardsModel: [
            CreditCardModelSave(cardNumber: '1234', cvvCode: '1234'),
            CreditCardModelSave(cardNumber: '12345', cvvCode: '1234'),
          ], isAddedNewCard: false),
        ],
      );

      blocTest(
        'Delete card',
        build: () => orderCardsBloc,
        setUp: () {
          orderCardsBloc.state.orderCardsModel = [
            CreditCardModelSave(cardNumber: '1234', cvvCode: '1234'),
          ];
        },
        act: (bloc) => orderCardsBloc.add(DeleteCard(CreditCardModelSave(cardNumber: '1234', cvvCode: '1234'))),
        expect: () => [orderCardsBloc.state.copyWith(orderCardsModel: [])],
      );

      blocTest(
        'Update card',
        build: () => orderCardsBloc,
        setUp: () {
          orderCardsBloc.state.orderCardsModel = [
            CreditCardModelSave(cardNumber: '1234', cvvCode: '1234', availableAmount: '100.00'),
          ];
        },
        act: (bloc) => orderCardsBloc.add(UpdateCard(CreditCardModelSave(cardNumber: '1234', cvvCode: '1234', availableAmount: '101.00'), 0)),
        expect: () => [
          orderCardsBloc.state.copyWith(orderCardsModel: [
            CreditCardModelSave(cardNumber: '1234', cvvCode: '1234', availableAmount: '101.00'),
          ], isUpdatedCard: true),
          orderCardsBloc.state
              .copyWith(orderCardsModel: [CreditCardModelSave(cardNumber: '1234', cvvCode: '1234', availableAmount: '101.00')], isUpdatedCard: false)
        ],
      );
    },
  );
}
