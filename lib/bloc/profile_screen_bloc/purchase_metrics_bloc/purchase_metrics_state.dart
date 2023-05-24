part of 'purchase_metrics_bloc.dart';

@immutable
abstract class PurchaseMetricsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PurchaseMetricsInitial extends PurchaseMetricsState {}

class PurchaseMetricsProgress extends PurchaseMetricsState {}

class PurchaseMetricsFailure extends PurchaseMetricsState {}

class PurchaseMetricsSuccess extends PurchaseMetricsState {
  final PurchaseMetricsModel? purchaseMetricsModel;

  PurchaseMetricsSuccess({this.purchaseMetricsModel});

  @override
  List<Object?> get props => [purchaseMetricsModel];
}
