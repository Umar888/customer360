import 'package:gc_customer_app/data/data_sources/offers_screen_data_repository/offers_screen_data_repository.dart';
import 'package:gc_customer_app/models/landing_screen/landing_scree_offers_model.dart';

class OffersScreenRepository {
  OffersScreenDataSource offersScreenDataSource = OffersScreenDataSource();
  Future<dynamic> getCompanyOffers() async {
    var response = await offersScreenDataSource.getCompanyOffersList();
    return LandingScreenOffersModel.fromJson(response.data);
  }
}
