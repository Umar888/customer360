import 'package:equatable/equatable.dart';

class RecommendedListItems extends Equatable{
  String? imageUrl;
  bool? recommendedStatus;
  RecommendedListItems({
    this.imageUrl,
    this.recommendedStatus,
  });

  @override
  List<Object?> get props => [imageUrl,recommendedStatus];
}
