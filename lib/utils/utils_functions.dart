import 'package:url_launcher/url_launcher_string.dart';

Future<void> makephoneCall(String phoneNumber) async {
  try {
    var phone = phoneNumber
        .replaceAll(' ', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('-', '')
        .replaceAll('+1', '');
    print('---launch zoomphonecall:+1$phone');
    var resp = await launchUrlString('zoomphonecall:+1$phone');
    print('resp: $resp');
  } catch (e) {
    print('loi: ${e.toString()}');
    print(e);
  }
}
