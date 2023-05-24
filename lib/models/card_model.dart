class CardModel {
  CardModel({
    required this.cardNumber,
    required this.name,
    required this.expiredMonth,
  });

  String cardNumber;
  String name;
  String expiredMonth;

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        cardNumber: json["cardNumber"],
        name: json["name"],
        expiredMonth: json["expiredMonth"],
      );

  Map<String, dynamic> toJson() => {
        "cardNumber": cardNumber,
        "name": name,
        "expiredMonth": expiredMonth,
      };
}
