// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'recommendation_browse_history_bloc.dart';

abstract class RecommendationBrowseHistoryState extends Equatable {
  RecommendationBrowseHistoryState();

  @override
  List<Object?> get props => [];
}

class BrowseHistoryInitial extends RecommendationBrowseHistoryState {}

class BrowseHistoryProgress extends RecommendationBrowseHistoryState {}

class BrowseHistoryFailure extends RecommendationBrowseHistoryState {}

class BrowseHistorySuccess extends RecommendationBrowseHistoryState {
  final RecommendationScreenModel? recommendationScreenModel;
  final Records? product;
  final String? message;

  BrowseHistorySuccess({required this.recommendationScreenModel, this.message = "", this.product});

  @override
  List<Object?> get props => [recommendationScreenModel, message, product];
}
