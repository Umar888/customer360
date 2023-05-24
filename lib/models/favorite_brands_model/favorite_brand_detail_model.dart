import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/models/inventory_search/add_search_model.dart' as asm;

import '../common_models/facet.dart';
import '../common_models/records_class_model.dart';
import '../common_models/refinement_model.dart';

class FavoriteBrandDetailModel extends Equatable{
  Wrapperinstance? wrapperinstance;
  List<FaceLst>? faceLst;

  FavoriteBrandDetailModel({this.wrapperinstance, this.faceLst});

  FavoriteBrandDetailModel.fromJson(Map<String, dynamic> json) {
    wrapperinstance = json['wrapperinstance'] != null
        ? new Wrapperinstance.fromJson(json['wrapperinstance'])
        : null;
    if (json['faceLst'] != null) {
      faceLst = <FaceLst>[];
      json['faceLst'].forEach((v) {
        faceLst!.add(new FaceLst.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.wrapperinstance != null) {
      data['wrapperinstance'] = this.wrapperinstance!.toJson();
    }
    if (this.faceLst != null) {
      data['faceLst'] = this.faceLst!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [faceLst,wrapperinstance];
}
class FaceLst extends Equatable{
  List<Refinement>? refinement;
  String? rank;
  String? multiSelect;
  String? displayName;
  String? dimensionName;
  String? dimensionId;

  FaceLst(
      {this.refinement,
        this.rank,
        this.multiSelect,
        this.displayName,
        this.dimensionName,
        this.dimensionId});

  FaceLst.fromJson(Map<String, dynamic> json) {
    if (json['refinement'] != null) {
      refinement = <Refinement>[];
      json['refinement'].forEach((v) {
        refinement!.add(new Refinement.fromJson(v));
      });
    }
    rank = json['rank'];
    multiSelect = json['multiSelect'];
    displayName = json['displayName'];
    dimensionName = json['dimensionName'];
    dimensionId = json['dimensionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.refinement != null) {
      data['refinement'] = this.refinement!.map((v) => v.toJson()).toList();
    }
    data['rank'] = this.rank;
    data['multiSelect'] = this.multiSelect;
    data['displayName'] = this.displayName;
    data['dimensionName'] = this.dimensionName;
    data['dimensionId'] = this.dimensionId;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [refinement,
    rank,
    multiSelect,
    displayName,
    dimensionName,
    dimensionId];
}
class Wrapperinstance extends Equatable{
  List<Records>? records;
  NavContent? navContent;
  List<Facet>? facet;

  Wrapperinstance({this.records, this.navContent, this.facet});

  Wrapperinstance.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null) {
      records = <Records>[];
      json['records'].forEach((v) {
        records!.add(new Records.fromJson(v));
      });
    }
    navContent = json['navContent'] != null
        ? new NavContent.fromJson(json['navContent'])
        : null;
    if (json['facet'] != null) {
      facet = <Facet>[];
      json['facet'].forEach((v) {
        facet!.add(new Facet.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.records != null) {
      data['records'] = this.records!.map((v) => v.toJson()).toList();
    }
    if (this.navContent != null) {
      data['navContent'] = this.navContent!.toJson();
    }
    if (this.facet != null) {
      data['facet'] = this.facet!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    records,navContent,facet
  ];
}




class NavContent extends Equatable{
  int? totalERecsNum;

  NavContent({this.totalERecsNum});

  NavContent.fromJson(Map<String, dynamic> json) {
    totalERecsNum = json['totalERecsNum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalERecsNum'] = this.totalERecsNum;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
   totalERecsNum
  ];
}



