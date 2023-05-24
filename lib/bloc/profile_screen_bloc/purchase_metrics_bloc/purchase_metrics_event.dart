part of 'purchase_metrics_bloc.dart';

@immutable
abstract class PurchaseMetricsEvent extends Equatable {
  PurchaseMetricsEvent();
  @override
  List<Object> get props => [];
}

class LoadMetricsData extends PurchaseMetricsEvent {
  LoadMetricsData();

  @override
  List<Object> get props => [];
}
