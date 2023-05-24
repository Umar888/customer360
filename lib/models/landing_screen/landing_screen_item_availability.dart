import 'package:equatable/equatable.dart';

class ItemAvailabilityLandingScreenModel extends Equatable{
  bool? outOfStock;
  bool? noInfo;
  bool? inStore;

  ItemAvailabilityLandingScreenModel(
      {this.outOfStock, this.noInfo, this.inStore});

  ItemAvailabilityLandingScreenModel.fromJson(Map<String, dynamic> json) {
    outOfStock = json['outOfStock'];
    noInfo = json['noInfo'];
    inStore = json['inStore'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['outOfStock'] = outOfStock;
    data['noInfo'] = noInfo;
    data['inStore'] = inStore;
    return data;
  }

  @override
  List<Object?> get props => [outOfStock, noInfo, inStore];
}