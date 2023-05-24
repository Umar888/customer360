import 'dart:async';

import 'package:flutter/services.dart';

class DeepLinks {
  // Event Channel creation
  static const _stream = const EventChannel('guitarcenter/events');

  // Method channel creation
  static const _platform = const MethodChannel('guitarcenter/channel');

  StreamController<String> _stateController = StreamController();

  Stream<String> get stream => _stateController.stream;

  Sink<String> get stateSink => _stateController.sink;

  // Adding the listener into constructor
  DeepLinks() {
    // Checking application start by deep link
    startUri().then(_onRedirected);
    // Checking broadcast stream, if deep link was clicked in opened application
    _stream.receiveBroadcastStream().listen((d) => _onRedirected(d));
  }

  void _onRedirected(String? uri) {
    // Here can be any uri analysis, checking tokens etc, if it’s necessary
    // Throw deep link URI into the BloC's stream
    if (uri != null) {
      print("Received deeplink: $uri");
      uri = uri.replaceAll("guitarcenter://", "").replaceAll("%20", " ");
      stateSink.add(uri);
    }
  }

  void dispose() => _stateController.close();

  Future<String?> startUri() async {
    try {
      return _platform.invokeMethod('initialLink');
    } on PlatformException catch (e) {
      return "Failed to Invoke: '${e.message}'.";
    }
  }
}
