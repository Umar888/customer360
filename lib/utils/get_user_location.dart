import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<Position?> getUserLocation(BuildContext context) async {
  var didRequest =
      await SharedPreferenceService().getInt(requestLocationPermission);
  didRequest++;
  if (didRequest <= 2) {
    SharedPreferenceService()
        .setInt(key: requestLocationPermission, value: didRequest);
  }
  var status = await Geolocator.requestPermission();
  if (status == LocationPermission.denied ||
      status == LocationPermission.deniedForever) {
    if (didRequest > 2) return null;
    var value = await showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Text(
            'Enable your location services so we can find nearby stores.',
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                fontFamily: kRubik,
                height: 1.4),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Go to Setting'),
              onPressed: () {
                Navigator.pop(context, false);
                openAppSettings();
              },
            ),
            CupertinoDialogAction(
              child: Text('No thanks'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            )
          ],
        );
      },
    );
    return value == true
        ? null
        : Position(
            longitude: 0,
            latitude: 0,
            timestamp: null,
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0);
  }
  var currentLocation = await Geolocator.getCurrentPosition();
  return currentLocation;
}
