///this is for Access Token Body
Map<String, dynamic> authJsonAccessToken = {
  "clientId": "0oa4jm1cefsinuyYq697",
  "returnUrl": "com.okta.guitarcenter:/callback",
  "deviceId": "827364-2342-2323"
};

///this is for Access Token Header
Map<String, String> authJsonAccessHeader = {
  'x-api-key': 'ngKUnTWJNo6IkppdLkZmK4CdxBD5P5lD6tIKdVHp',
  'Content-Type': 'application/json'
};

///this is for UAT
Map<String, dynamic> authJson = {
  'grant_type': 'password',
  'client_id':
      '3MVG9QBLg8QGkFeo1WCfSyKAD0j71Umehp1aMtq2VxvPYez7qeN_nFLzNbRXe1h8lgxVkmHEaeFauNWgETWPX',
  'client_secret':
      '2159263A794A3F467C53D9CD88FBC62C94D8EA2FE1BE4580E2D34F6A4ADDB6F6',
  'username': 'customerconnect@guitarcenter.com.tracuat',
  'password': 'm0bileus3r2462YeTkhijiK2V4Tphw1B79mRo',
};

///this is for production
// Map<String, dynamic> authJson = {
//   'grant_type': 'password',
//   'client_id':
//       '3MVG9KI2HHAq33RxCZsmOszHULYFbzfZ5N3n.ZbXHHObojG0a1tIEz7c5k749ZRW5n2xGcGxqy2OYw8zI0VGj',
//   'client_secret':
//       'E062FCA77D3FE219F8E4AE7A09B74ADEDC45032D2107FC1360DB24EFB693E502',
//   'username': 'customerconnect@guitarcenter.com',
//   'password': 'm0bileccus3r321gMZ2O6TntlzcQSb4ZTPjlLUkP',
// };

Map<String, String> authHeaders = {
  "Content-Type": "application/x-www-form-urlencoded"
};

const String kOktaClientId = '0oa3dhg4kq90gtRPH697';

///This for UAT
const String kOktaRedirectUri =
    'https://gccust360-uat.guitarcenter.com/static.html';

///This for production
// const String kOktaRedirectUri =
//     'https://gccust360.guitarcenter.com/static.html';
const String kwebOktaNonce = 'CST360PRD';
const String kwebOktaState = 'sttcst-91cc12-6f68-43y0-b8f7-6c095179e7';

const String kClientId = "0oa4jm1cefsinuyYq697";
const String kReturnUrl = "com.okta.guitarcenter:/callback";
const String kCallBackUrl = "com.okta.guitarcenter";
const String kDeviceId = "827364-2342-2323";

const String authURL = '/services/oauth2/token';

const String tokenURL =
    'https://mp4gqy2upf.execute-api.us-west-2.amazonaws.com/dev/api/authorization/token';

const String kRubik = 'Rubik';
const String kUserRecordId = 'user_record_id';
const String kAccessTokenKey = 'access_token';
const String fcmToken = 'fcm_token';
const String kInstanceUrlKey = 'instance_url';

Map<String, String> kPurchaseChannelHeaders = {
  'x-api-key': 'AZmg6PFTuWg2rYKCssblLBBhM62Ae0Vu',
};

const String loggedInUserEmail = 'logged_in_user_email';
const String cronTimeRefresh = 'cron_time_refresh';
const String cronTimeValidate = 'cron_time_validate';
const String isValidToken = 'isValidToken';
const String agentEmail = 'agent_email';
const String agentPhone = 'agent_phone';
const String savedAgentName = 'agent_name';
const String agentId = 'agent_id_c360';
const String agentIndex = 'agent_index';
const String agentAddress = 'agent_address';
const String loggedInAgentId = 'logged_agent_id';
const String firebaseIds = 'firebase_id';
const String savedAgentFirstName = 'agent_first_name';
const String savedAgentLastName = 'agent_last_name';
const String mode = 'mode';
const String storeId = 'store_id';
const String requestLocationPermission = 'request_location_permission1';
const String myNewStore = 'MyNewStore';
const String myNewTask = 'MyNewTask';
const String myNewTeam = 'MyNewTeam';
const String isManager = 'is_manager';
const String accessories = 'Accessories';
const String retail = 'Retail';
const String oktaAccessToken = 'oktaAccessToken';
const String oktaIdToken = 'oktaIdToken';
String searchNameInfield = '';
String sortByText = 'Sort By';
String searchNameInFavouriteBrandScreen = '';
String searchNameInOffersScreen = '';
var facetList;

/// okta test
// const String oktaTestClientId = "0oa8wfhmekVnsyWgL5d7";
// const String oktaOrgUrl = "dev-51371106.okta.com";

const String oktaTestClientId = "0oa4oyd6nlUnH14LS697";
const String oktaOrgUrl = "guitarcenter.okta.com";
