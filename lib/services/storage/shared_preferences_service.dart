import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  String recordId = "";
  final _controller = StreamController<String>();

  Stream<String> get userAgentId async* {
    yield* _controller.stream;
  }

  /// Set value in storage using key
  Future<void> setKey({required String key, required String value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    if (key == agentId) {
      _controller.add(value);
    }
  }

  /// Set user auth token
  void setUserRecord(String userRecordId) {
    setKey(key: kUserRecordId, value: userRecordId);
  }

  Future<List<String>> getKeyList({required String key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  Future<void> setKeyList(
      {required String key, required List<String> value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, value);
  }

  Future<void> setBool({required String key, required bool value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<void> setInt({required String key, required int value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  /// Set user auth token
  void setUserToken({required String authToken}) {
    setKey(key: kAccessTokenKey, value: authToken);
  }

  /// Set instance URL
  void setInstanceUrl({required String url}) {
    setKey(key: kInstanceUrlKey, value: url);
  }

  /// Get user auth token
  Future<String?> getUserToken({required key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Get instance URL
  Future<String?> getInstanceUrl({required key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Clear shared preferences
  void clearStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  /// Get user auth token
  Future<String?> getUserRecord() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(kUserRecordId);
  }

  /// Get user record Id
  void getAgentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getString(agentId) ?? "";
  }

  Future<String> getValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }

  Future<bool> clearVal(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  Future<bool> getBool(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key)??false;
  }

  Future<int> getInt(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }

  void dispose() => _controller.close();
}
