import 'package:azure_ad_authentication/azure_ad_authentication.dart';
import 'package:azure_ad_authentication/exeption.dart';
import 'package:azure_ad_authentication/model/user_ad.dart';

class AuthenticationHelper {
  Future<String> acquireToken() async {
    String result = await getResult();
    return result;
  }

  String _authority =
      "https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize";
  String _clientId = "dadc00aa-8ba5-4df0-8882-e0b0ff9dd9fc";

  String _output = 'NONE';
  List<String> kScopes = [
    "https://graph.microsoft.com/user.read",
    "https://graph.microsoft.com/Calendars.ReadWrite",
  ];

  Future<String> getResult({bool isAcquireToken = true}) async {
    UserAdModel? userAdModel;

    print("getting result");
    AzureAdAuthentication pca = await intPca();
    String? res;
    try {
      if (isAcquireToken) {
        userAdModel = await pca.acquireToken(scopes: kScopes);
        if (userAdModel != null) {
          return userAdModel.mail ?? "";
          // isLoggedIn = true;
          // print("userAdModel.mail ${userAdModel.mail}");
          // SharedPreferenceService().setKey(key: loggedInUserEmail, value: '${userAdModel.mail}');
        }

        // userAdModel.
      } else {
        userAdModel = await pca.acquireTokenSilent(scopes: kScopes);
      }
    } on MsalUserCancelledException {
      res = "User cancelled";
    } on MsalNoAccountException {
      res = "no account";
    } on MsalInvalidConfigurationException {
      res = "invalid config";
    } on MsalInvalidScopeException {
      res = "Invalid scope";
    } on MsalException {
      res = "Error getting token. Unspecified reason";
    }
    print(res);
    return "";
  }

  Future<AzureAdAuthentication> intPca() async {
    return await AzureAdAuthentication.createPublicClientApplication(
        clientId: _clientId, authority: _authority);
  }
}
