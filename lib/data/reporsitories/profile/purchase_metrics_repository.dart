import 'package:gc_customer_app/data/data_sources/profile_screen/purchase_metrics_data_source.dart';
import 'package:gc_customer_app/models/purchase_metrics_model.dart';

class PurchaseMetricsRepository {
  PurchaseMetricsDataSource purchaseMetricsDataSource =
      PurchaseMetricsDataSource();

  Future<PurchaseMetricsModel> getProfilePurchaseMetrics(
      String recordId) async {
    var response = await purchaseMetricsDataSource
        .getClientProfilePurchaseMetrics(recordId);
    String message = response.message.toString();
    if (response.data != null && response.data.isNotEmpty) {
      return PurchaseMetricsModel.fromJson(response.data);
    }
    throw Exception(message);
  }
}
