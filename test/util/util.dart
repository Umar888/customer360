import 'package:http/http.dart';

extension String2 on String {
  String get escape => RegExp.escape(this);
}

extension Request2 on Request {
  bool matches(String pattern) => RegExp(pattern.replaceAll(" ", "%20")).hasMatch(url.toString());
}