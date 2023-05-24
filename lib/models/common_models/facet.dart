import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/models/common_models/refinement_model.dart';

class Facet extends Equatable {
  List<Refinement>? refinement;
  List<Refinement>? selectedRefinement;
  String? rank;
  String? multiSelect;
  String? displayName;
  String? dimensionName;
  String? dimensionId;
  bool? isExpand;

  Facet(
      {this.refinement,
        this.rank,
        this.multiSelect,
        this.selectedRefinement,
        this.isExpand,
        this.displayName,
        this.dimensionName,
        this.dimensionId});

  Facet.fromJson(Map<String, dynamic> json) {
    if (json['refinement'] != null) {
      refinement = <Refinement>[];
      json['refinement'].forEach((v) {
        refinement!.add(Refinement.fromJson(v));
      });
    } else {
      refinement = [];
    }
    selectedRefinement = [];
    rank = json['rank'].toString();
    multiSelect = json['multiSelect'].toString();
    displayName = json['displayName'];
    dimensionName = json['dimensionName'];
    dimensionId = json['dimensionId'];
    isExpand = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (refinement != null) {
      data['refinement'] = refinement!.map((v) => v.toJson()).toList();
    }
    data['rank'] = rank;
    data['multiSelect'] = multiSelect;
    data['displayName'] = displayName;
    data['dimensionName'] = dimensionName;
    data['dimensionId'] = dimensionId;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    refinement,
    selectedRefinement,
    rank,
    multiSelect,
    displayName,
    dimensionName,
    dimensionId,
    isExpand,
  ];
}
