// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class AllocatedAssociate extends Equatable{
  String? associateName;
  String? associateImageUrl;
  String? dateOfAllocation;
  AllocatedAssociate({
    this.associateName,
    this.associateImageUrl,
    this.dateOfAllocation,
  });

  @override
  List<Object?> get props => [associateName,associateImageUrl,dateOfAllocation];

}
