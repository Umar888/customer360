class CreditCardModel {
  CreditCardModel(
      this.cardNumber,
      this.expiryDate,
      this.cardHolderName,
      this.cvvCode,
      this.cardAmount,
      this.isCvvFocused,
      this.address,
      this.address2,
      this.heading,
      this.city,
      this.state,
      this.zipCode,
      this.firstName,
      this.lastName);

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String heading = '';
  String address = '';
  String address2 = '';
  String city = '';
  String state = '';
  String zipCode = '';

  String cvvCode = '';
  String cardAmount = '';
  bool isCvvFocused = false;
  String firstName = '';
  String lastName = '';
}
