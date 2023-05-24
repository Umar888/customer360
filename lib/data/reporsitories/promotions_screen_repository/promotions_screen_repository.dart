import 'package:gc_customer_app/data/data_sources/promotion_screen_data_source/promotion_screen_data_source.dart';
import 'package:gc_customer_app/models/promotion_model.dart';

class PromotionsScreenRepository {
  PromotionsScreenDataSource promotionsScreenDataSource =
      PromotionsScreenDataSource();

  Future<List<dynamic>> getPromotions(String recordId) async {
    var response = await promotionsScreenDataSource.getPromotions(recordId);

    if (response.data['topPromotion'] != null) {
      var topPros = PromotionModel.fromJson(response.data['topPromotion']);
      List<PromotionModel> activePros = response.data['activePromotions']
              ?.map<PromotionModel>((pr) => PromotionModel.fromJson(pr))
              .toList() ??
          <PromotionModel>[];
      return [topPros, activePros];
    } else {
      throw (Exception(response.message ?? ''));
    }
  }

  Future<PromotionModel> getPromotionDetail(String promotionId) async {
    var response =
        await promotionsScreenDataSource.getPromotionDetail(promotionId);
    if (response.data['promotionDetail'] != null) {
      return PromotionModel.fromJson(response.data['promotionDetail']);
    } else {
      throw (Exception(response.message ?? ''));
    }
  }

  Future<String> getPromotionDetailService(
      String serviceCommunicationId) async {
    var response = await promotionsScreenDataSource
        .getPromotionDetailService(serviceCommunicationId);
    if (response.data['response'] != null) {
      return response.data['response'];
    } else {
      throw (Exception(response.message ?? ''));
    }
  }
}
