class ProCoverageModel {
  List<Warranties>? warranties;
  String? message;

  ProCoverageModel({this.warranties, this.message});

  ProCoverageModel.fromJson(Map<String, dynamic> json) {
    if (json['Warranties'] != null) {
      warranties = <Warranties>[];
      json['Warranties'].forEach((v) {
        warranties!.add(Warranties.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (warranties != null) {
      data['Warranties'] = warranties!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class Warranties {
  String? styleDescription1;
  double? price;
  String? id;
  String? enterpriseSkuId;
  String? enterprisePIMId;
  String? displayName;

     Warranties({
        this.styleDescription1=  "",
        this.price= 0.00,
        this.id= "",
        this.enterpriseSkuId= "",
        this.enterprisePIMId= "",
        this.displayName= ""});

  Warranties.fromJson(Map<String, dynamic> json) {
    styleDescription1 = json['styleDescription1'];
    price = json['price'];
    id = json['id'];
    enterpriseSkuId = json['enterpriseSkuId'];
    enterprisePIMId = json['enterprisePIMId'];
    displayName = json['displayName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['styleDescription1'] = styleDescription1;
    data['price'] = price;
    data['id'] = id;
    data['enterpriseSkuId'] = enterpriseSkuId;
    data['enterprisePIMId'] = enterprisePIMId;
    data['displayName'] = displayName;
    return data;
  }
}