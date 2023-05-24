import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gc_customer_app/data/reporsitories/profile/purchase_metrics_repository.dart';
import 'package:gc_customer_app/models/purchase_metrics_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'purchase_metrics_event.dart';
part 'purchase_metrics_state.dart';

class PurchaseMetricsBloc
    extends Bloc<PurchaseMetricsEvent, PurchaseMetricsState> {
  final PurchaseMetricsRepository purchaseMetricsRepository;

  PurchaseMetricsBloc(this.purchaseMetricsRepository)
      : super(PurchaseMetricsFailure()) {
    on<LoadMetricsData>((event, emit) async {
      String userRecordId = await SharedPreferenceService().getValue(agentId);
      if ((userRecordId).isNotEmpty) {
        emit(PurchaseMetricsProgress());
        var purchaseMetrics = await purchaseMetricsRepository
            .getProfilePurchaseMetrics(userRecordId)
            .catchError((e) {
          print("this is error in purchase metrics $e");
          emit(PurchaseMetricsFailure());
        });
        emit(PurchaseMetricsSuccess(purchaseMetricsModel: purchaseMetrics));

        return;
      }

      emit(PurchaseMetricsFailure());
      return;
    });
  }
}
