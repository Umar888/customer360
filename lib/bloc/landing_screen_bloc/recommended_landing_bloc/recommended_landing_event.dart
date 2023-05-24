part of 'recommended_landing_bloc.dart';

@immutable
abstract class RecommendedLandingEvent extends Equatable {
  RecommendedLandingEvent();
  @override
  List<Object> get props => [];
}

class LoadRecommendedData extends RecommendedLandingEvent {}
