import 'package:equatable/equatable.dart';

class WarrantiesModel extends Equatable{
  List<Warranties>? warranties;
  String? message;

  WarrantiesModel({this.warranties, this.message});

  WarrantiesModel.fromJson(Map<String, dynamic> json) {
    if (json['Warranties'] != null) {
      warranties = <Warranties>[];
      json['Warranties'].forEach((v) {
        warranties!.add(new Warranties.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.warranties != null) {
      data['Warranties'] = this.warranties!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }

  @override
  List<Object?> get props => [warranties, message];
}

class Warranties extends Equatable{
  String? styleDescription1;
  double? price;
  String? id;
  String? enterpriseSkuId;
  String? enterprisePIMId;
  String? displayName;
  bool? isLoading;

  Warranties({
        this.styleDescription1,
        this.price,
        this.id,
        this.enterpriseSkuId,
        this.enterprisePIMId,
        this.displayName,
        this.isLoading,
  });

  Warranties.fromJson(Map<String, dynamic> json) {
    styleDescription1 = json['styleDescription1']??"";
    price = json['price']??0.0;
    id = json['id']??"";
    enterpriseSkuId = json['enterpriseSkuId']??"";
    enterprisePIMId = json['enterprisePIMId']??"";
    displayName = json['displayName']??"";
    isLoading = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['styleDescription1'] = this.styleDescription1;
    data['price'] = this.price;
    data['id'] = this.id;
    data['enterpriseSkuId'] = this.enterpriseSkuId;
    data['enterprisePIMId'] = this.enterprisePIMId;
    data['displayName'] = this.displayName;
    return data;
  }

  @override
  List<Object?> get props => [
    styleDescription1,
    price,
    id,
    enterpriseSkuId,
    enterprisePIMId,
    displayName,isLoading];
}
