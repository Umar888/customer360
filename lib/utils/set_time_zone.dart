import 'package:flutter/cupertino.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


extension DateTimeExtension on DateTime {
  static int _estToUtcDifference =0;

  int _getESTtoUTCDifference() {
    if (_estToUtcDifference == 0) {
      tz.initializeTimeZones();
      final locationNY = tz.getLocation('US/Pacific');
      tz.TZDateTime nowNY = tz.TZDateTime.now(locationNY);
      _estToUtcDifference = nowNY.timeZoneOffset.inHours;
    }

    return _estToUtcDifference;
  }

  DateTime toESTZone() {
    DateTime result = toUtc(); // local time to UTC
    result = result.add(Duration(hours: _getESTtoUTCDifference())); // convert UTC to EST
    return result;
  }

  DateTime fromESTZone() {
    DateTime result = subtract(Duration(hours: _getESTtoUTCDifference())); // convert EST to UTC

    String dateTimeAsIso8601String = result.toIso8601String();
//    dateTimeAsIso8601String += dateTimeAsIso8601String.characters.last.e('Z') ? '' : 'Z';
    result = DateTime.parse(dateTimeAsIso8601String); // make isUtc to be true

    result = result.toLocal(); // convert UTC to local time
    return result;
  }
}