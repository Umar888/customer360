import 'package:gc_customer_app/data/data_sources/profile_screen/payment_cards_data_source.dart';
import 'package:gc_customer_app/models/payment_card_model.dart';

class PaymentCardsRepository {
  final PaymentCardsDataSource paymentCardsDataSource;

  PaymentCardsRepository(this.paymentCardsDataSource);

  Future<List<PaymentCardModel>> getProfilePaymentCards(String recordId) async {
    var response =
        await paymentCardsDataSource.getClientProfilePaymentCards(recordId);
    String message = response.message.toString();
    if ((response.data['cardOnFileResponse']['userCards'] ?? '').isNotEmpty) {
      return response.data['cardOnFileResponse']['userCards']
          .map<PaymentCardModel>((c) => PaymentCardModel.fromJson(c))
          .toList();
    }
    return [];
  }
}
