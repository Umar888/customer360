import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gc_customer_app/data/reporsitories/cart_reporsitory/cart_repository.dart';
import 'package:gc_customer_app/data/reporsitories/profile/payment_cards_repository.dart';
import 'package:gc_customer_app/intermediate_widgets/credit_card_widget/model/credit_card_model_save.dart';
import 'package:gc_customer_app/models/address_models/address_model.dart';
import 'package:gc_customer_app/models/cart_model/financial_type_model.dart';
import 'package:gc_customer_app/models/landing_screen/credit_balance.dart';
import 'package:gc_customer_app/models/payment_card_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'order_cards_event.dart';
part 'order_cards_state.dart';

class OrderCardsBloc extends Bloc<OrderCardsEvent, OrderCardsState> {
  final CartRepository cartRepository;

  String firstName = '';
  String lastName = '';
  String orderId = '';

  Future<String> getGiftBalance(String giftCardNumber, String pin) async {
    var jsonData = await cartRepository.getGiftCardsBalance(
        giftCardNumber.replaceAll(' ', ''), pin);
    if (jsonData['giftCardBalance'] != null) {
      var amount = json.decode(jsonData['giftCardBalance'])["amountAvailable"];
      return amount;
    }
    return '0';
  }

  Future<CreditBalance?> getCOABalance() async {
    var email = await SharedPreferenceService().getValue(agentEmail);
    if (email.isNotEmpty) {
      var jsonData = await cartRepository.getCOABalance(email);
      if (jsonData['COAStatus'] != null) {
        var values = json.decode(jsonData['COAStatus']);

        return CreditBalance.fromJson(values);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> getEssentialFinanceMessage(
      String orderId, CreditCardModelSave card) async {
    var loggedUserId =
        await SharedPreferenceService().getValue(loggedInAgentId);
    var jsonData = await cartRepository.getEssentialFinanceMessage(
        orderId,
        loggedUserId,
        card.cardNumber.replaceAll(' ', ''),
        card.financialTypeModel?.planCode ?? '0',
        card.availableAmount ?? '0.0');
    if (jsonData['essentialCardInfo'] != null) {
      var values = json.decode(jsonData['essentialCardInfo']);
      return values;
    }
    throw Exception("Server Error");
  }

  Future<Map<String, dynamic>> getGearFinanceMessage(
    String orderId,
    CreditCardModelSave card,
  ) async {
    var jsonData = await cartRepository.getGearFinanceMessage(
        orderId,
        card.cardNumber.replaceAll(' ', ''),
        card.financialTypeModel?.planCode ?? '0',
        card.availableAmount ?? '0.0');
    if (jsonData['gearCardInfo'] != null) {
      var values = json.decode(jsonData['gearCardInfo']);
      return values;
    }
    throw Exception("Server Error");
  }

  Future<List<PaymentCardModel>> getExistingCards() async {
    var email = await SharedPreferenceService().getValue(agentEmail);
    var jsonData = await cartRepository.getExistingCards(email);
    if (jsonData['cardOnFileResponse'] != null &&
        jsonData['cardOnFileResponse']['userCards'] != null &&
        jsonData['cardOnFileResponse']['userCards'].isNotEmpty) {
      List<PaymentCardModel> cards = jsonData['cardOnFileResponse']['userCards']
          .map<PaymentCardModel>((e) => PaymentCardModel.fromJson(e))
          .toList();
      cards.removeWhere((c) => c.paymentType?.toLowerCase() != 'creditcard');
      return cards;
    }
    return [];
    // throw Exception('Have no exiting card.');
  }

  OrderCardsBloc(this.cartRepository) : super(OrderCardsState()) {
    on<LoadCardsData>((event, emit) async {
      String userRecordId = await SharedPreferenceService().getValue(agentId);
      if (orderId != event.orderId) {
        // var cards = state.orderCardsModel ?? [];
        // if (cards.isNotEmpty) {
        //   cards.first.availableAmount = event.totalCartValue.toString();
        //   emit(state.copyWith(orderCardsModel: cards, isAddedNewCard: true));
        //   emit(state.copyWith(orderCardsModel: cards, isAddedNewCard: false));
        // }
        emit(state.copyWith(orderCardsModel: []));
      }
      orderId = event.orderId;
      emit(state.copyWith(existingCards: []));
      getExistingCards().then((existingCards) {
        print(existingCards.first.toJson());
        emit(state.copyWith(existingCards: existingCards));
      }).catchError((error) {
        print(error.toString());
        return error;
      });

      if (event.isNeedToLoadCOA)
        await getCOABalance().then((coaCreditBalance) {
          emit(state.copyWith(coaCreditBalance: coaCreditBalance));
        }).catchError((error) {
          print(error.toString());
          return error;
        });

      if ((userRecordId).isNotEmpty) {
        var financialJson =
            await cartRepository.getCardsFinancial(event.orderId, userRecordId);

        List<FinancialTypeModel> essentialFinance = [];
        List<FinancialTypeModel> gearFinance = [];
        try {
          if ((financialJson["promoCode"] ?? []).isNotEmpty) {
            var indexEssentialFinancial = financialJson["promoCode"]
                .indexWhere((e) => e["PromoName"] == "Fortiva promos");
            if (indexEssentialFinancial >= 0 &&
                (financialJson["promoCode"][indexEssentialFinancial]
                            ["promoDesc"] ??
                        [])
                    .isNotEmpty) {
              //Get Essential Financial types
              essentialFinance = financialJson["promoCode"]
                      [indexEssentialFinancial]["promoDesc"]
                  .map<FinancialTypeModel>(
                      (e) => FinancialTypeModel.fromJson(e))
                  .toList();
            }
            var indexGearFinancial = financialJson["promoCode"]
                .indexWhere((e) => e["PromoName"] == "PLC promos");
            if (indexGearFinancial >= 0 &&
                (financialJson["promoCode"][indexGearFinancial]["promoDesc"] ??
                        [])
                    .isNotEmpty) {
              //Get Gear Financial types
              gearFinance = financialJson["promoCode"][indexGearFinancial]
                      ["promoDesc"]
                  .map<FinancialTypeModel>(
                      (e) => FinancialTypeModel.fromJson(e))
                  .toList();
            }
          }
        } catch (e) {}
        emit(state.copyWith(
            essentialFinance: essentialFinance, gearFinance: gearFinance));
        return;
      }

      emit(state.copyWith(orderCardsStatus: OrderCardsStatus.failedState));
      return;
    });

    on<AddNewCard>((event, emit) async {
      String userRecordId = await SharedPreferenceService().getValue(agentId);
      if ((userRecordId).isNotEmpty) {
        var cards = state.orderCardsModel ?? [];

        if (cards.any((e) => e.cardNumber == event.card.cardNumber)) {
          emit(state.copyWith(isAddedNewCardFail: true));
          emit(state.copyWith(isAddedNewCardFail: false));
          return;
        }

        firstName = event.card.firstName;
        lastName = event.card.lastName;

        if (event.card.cardType == PaymentMethodType.gcGift) {
          var remainValue = event.totalCartValue;
          cards.forEach((c) {
            remainValue -= double.parse(c.availableAmount ?? '0.0');
          });
          if (double.parse(event.card.availableAmount ?? '0.0') > remainValue) {
            event.card.availableAmount =
                remainValue < 0 ? '0.0' : remainValue.toString();
            event.card.paymentMethod?.amount =
                event.card.availableAmount ?? '0.0';
          }
          ;
        }
        if (event.card.availableAmount == null ||
            event.card.availableAmount!.isEmpty) {
          event.card.availableAmount = '0.0';
        }

        cards.add(event.card);
        emit(state.copyWith(orderCardsModel: cards, isAddedNewCard: true));
        emit(state.copyWith(isAddedNewCard: false));

        return;
      }

      emit(state.copyWith(orderCardsStatus: OrderCardsStatus.failedState));
      return;
    });

    on<DeleteCard>((event, emit) async {
      var cards = state.orderCardsModel?.toList() ?? [];
      firstName = event.card.firstName;
      lastName = event.card.lastName;
      cards.removeWhere((e) => e.cardNumber == event.card.cardNumber);

      emit(state.copyWith(orderCardsModel: cards));

      return;
    });

    on<UpdateCard>((event, emit) async {
      String userRecordId = await SharedPreferenceService().getValue(agentId);
      if ((userRecordId).isNotEmpty) {
        var cards = state.orderCardsModel ?? [];
        var editCardIndex = event.index;
        if (editCardIndex >= 0) {
          cards[editCardIndex].cardNumber = event.card.cardNumber;
          cards[editCardIndex].isSameAsShippingAddress =
              event.card.isSameAsShippingAddress;
          cards[editCardIndex].expiryMonth = event.card.expiryMonth;
          cards[editCardIndex].expiryYear = event.card.expiryYear;
          cards[editCardIndex].availableAmount =
              event.card.availableAmount?.replaceAll('\$', '');
          cards[editCardIndex].cvvCode = event.card.cvvCode;
          cards[editCardIndex].financialTypeModel =
              event.card.financialTypeModel;
          cards[editCardIndex].paymentMethod = event.card.paymentMethod;

          emit(state.copyWith(orderCardsModel: cards, isUpdatedCard: true));
          emit(state.copyWith(isUpdatedCard: false));

          return;
        }
      }

      emit(state.copyWith(orderCardsStatus: OrderCardsStatus.failedState));
      return;
    });

    on<GetGiftCardBalance>((event, emit) async {
      var amount = await getGiftBalance(event.cardNumber, event.pin);

      emit(state.copyWith(giftCardAvailableBalance: amount));

      return;
    });

    on<RemoveGiftCardBalance>((event, emit) async {
      emit(state.copyWith(giftCardAvailableBalance: '0'));

      return;
    });

    on<UpdateCardAddress>((event, emit) async {
      var cards = state.orderCardsModel ?? [];
      cards.forEach((c) {
        if (c.paymentMethod == null) {
          c.paymentMethod = PaymentMethod(
            address: event.address.address1 ?? '',
            address2: event.address.address2 ?? '',
            city: event.address.city ?? '',
            state: event.address.state ?? '',
            zipCode: event.address.postalCode ?? '',
          );
        } else if (c.paymentMethod!.address.isEmpty) {
          c.paymentMethod!.address = event.address.address1 ?? '';
          c.paymentMethod!.address2 = event.address.address2 ?? '';
          c.paymentMethod!.city = event.address.city ?? '';
          c.paymentMethod!.state = event.address.state ?? '';
          c.paymentMethod!.zipCode = event.address.postalCode ?? '';
        }
      });
      if (cards.isNotEmpty) {
        emit(state.copyWith(orderCardsModel: cards, isUpdatedCard: true));
        emit(state.copyWith(isUpdatedCard: false));
      }
      return;
    });
  }
}
