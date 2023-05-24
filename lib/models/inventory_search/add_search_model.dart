import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/models/cart_model/cart_warranties_model.dart';

import '../common_models/facet.dart';
import '../common_models/records_class_model.dart';
import '../common_models/refinement_model.dart';

class AddSearchModel extends Equatable {
  Wrapperinstance? wrapperinstance;
  List<Refinement>? filteredListOfRefinments = [];
  int lengthOfSelectedFilters = 0;
  List<Records>? listOfOfferForFilters;



  AddSearchModel({this.wrapperinstance, this.filteredListOfRefinments});

  AddSearchModel.fromJson(Map<String, dynamic> json) {
    
    wrapperinstance = json['wrapperinstance'] != null
        ? Wrapperinstance.fromJson(json['wrapperinstance'])
        : Wrapperinstance(
        records: [], facet: [], navContent: NavContent(totalERecsNum: 0));
   
    filteredListOfRefinments = [];
    listOfOfferForFilters= [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (wrapperinstance != null) {
      data['wrapperinstance'] = wrapperinstance!.toJson();
    }
    
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [wrapperinstance];
}


class Wrapperinstance extends Equatable {
  List<Records>? records;
  NavContent? navContent;
  List<Facet>?  facet;

  Wrapperinstance({this.records, this.navContent, this.facet});

  Wrapperinstance.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null) {
      records = <Records>[];
      json['records'].forEach((v) {
        records!.add(Records.fromJson(v));
      });
    } else {
      records = <Records>[];
    }
    navContent = json['navContent'] != null
        ? NavContent.fromJson(json['navContent'])
        : NavContent(totalERecsNum: 0);
    if (json['facet'] != null) {
      facet = <Facet>[];
      json['facet'].forEach((v) {
        facet!.add(Facet.fromJson(v));
      });
    } else {
      facet = <Facet>[];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (records != null) {
      data['records'] = records!.map((v) => v.toJson()).toList();
    }
    if (navContent != null) {
      data['navContent'] = navContent!.toJson();
    }
    if (facet != null) {
      data['facet'] = facet!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [records, navContent, facet];
}
class ProCoverages {
  String? styleDescription1;
  double? price;
  String? id;
  String? enterpriseSkuId;
  String? enterprisePIMId;
  String? displayName;

  ProCoverages({
    this.styleDescription1,
    this.price,
    this.id,
    this.enterpriseSkuId,
    this.enterprisePIMId,
    this.displayName});

  ProCoverages.fromJson(Map<String, dynamic> json) {
    styleDescription1 = json['styleDescription1']??"";
    price = json['price']??0.0;
    id = json['id']??"";
    enterpriseSkuId = json['enterpriseSkuId']??"";
    enterprisePIMId = json['enterprisePIMId']??"";
    displayName = json['displayName']??"";
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
}



class NavContent extends Equatable {
  int? totalERecsNum;

  NavContent({this.totalERecsNum});

  NavContent.fromJson(Map<String, dynamic> json) {
    totalERecsNum = json['totalERecsNum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalERecsNum'] = totalERecsNum;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [totalERecsNum];
}



