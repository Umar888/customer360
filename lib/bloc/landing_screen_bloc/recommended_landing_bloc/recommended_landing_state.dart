part of 'recommended_landing_bloc.dart';

@immutable
abstract class RecommendedLandingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecommendedLandingInitial extends RecommendedLandingState {}

class RecommendedLandingProgress extends RecommendedLandingState {}

class RecommendedLandingFailure extends RecommendedLandingState {}

class RecommendedLandingSuccess extends RecommendedLandingState {
  final LandingScreenRecommendationModelBuyAgain recommendedBuyAgain;

  RecommendedLandingSuccess({required this.recommendedBuyAgain});

  @override
  List<Object?> get props => [recommendedBuyAgain];
}
