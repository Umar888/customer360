class FinancialTypeModel {
  FinancialTypeModel({
    this.rank,
    this.promoTitle,
    this.promoDescription,
    this.planCode,
    this.isSpecialFinancing = false,
  });

  String? rank;
  String? promoTitle;
  String? promoDescription;
  String? planCode;
  bool isSpecialFinancing;

  factory FinancialTypeModel.fromJson(Map<String, dynamic> json) =>
      FinancialTypeModel(
        rank: json["rank"],
        promoTitle: json["promoTitle"],
        promoDescription: json["promoDescription"],
        planCode: json["planCode"],
        isSpecialFinancing: json["isSpecialFinancing"],
      );

  Map<String, dynamic> toJson() => {
        "rank": rank,
        "promoTitle": promoTitle,
        "promoDescription": promoDescription,
        "planCode": planCode,
        "isSpecialFinancing": isSpecialFinancing,
      };
}
