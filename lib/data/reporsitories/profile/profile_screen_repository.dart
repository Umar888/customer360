import 'package:gc_customer_app/data/data_sources/profile_screen/profile_screen_data_source.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';

class ProfileScreenRepository {
  ProfileScreenDataSource profileScreenDataSource = ProfileScreenDataSource();

  Future<UserProfile> getClientProfile(String userId) async {
    var response = await profileScreenDataSource.getClientProfile(userId);
    String message = response.message.toString();
    if (response.data['records'] != null &&
        response.data['records'].isNotEmpty) {
      return UserProfile.fromJson(response.data['records'][0]);
    }
    throw Exception(message);
  }
}
