import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:gc_customer_app/services/networking/request_body.dart';
import 'package:http/http.dart' as http;

import '../storage/shared_preferences_service.dart';
import 'http_response.dart';

class HttpService {
  http.Client? client;

  // BuildContext get _navigator => navigatorKey.currentContext!;
  // get call for http
  Future<HttpResponse> doGet(
      {required String path,
      Map<String, dynamic>? params,
      bool tokenRequired = true,
      bool requiredAuthentication = true,
      Map<String, String>? headers}) async {
    bool validToken = await SharedPreferenceService().getBool(isValidToken);
    if (requiredAuthentication) {
      // if (validToken) {
      String? accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
      String? loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);

      if (accessToken == null) {
        await generateAccessToken();
        accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
      }
      if (Uri.parse(path).queryParameters["loggedinUserId"] == null || (Uri.parse(path).queryParameters["loggedinUserId"] ?? "").isEmpty) {
        if (Uri.parse(path).query.isNotEmpty && !path.contains("q=SELECT") && path.contains("GC_C360")) {
          path = path.trim() + "&loggedinUserId=$loggedInUserId";
        } else if (Uri.parse(path).query.isEmpty && !path.contains("q=SELECT") && path.contains("GC_C360")) {
          path = path.trim() + "?loggedinUserId=$loggedInUserId";
        }
      }
      // log(Uri.parse(path).query);
      // log(Uri.parse(path).queryParameters["loggedinUserId"]??"");
      log("get path $path");
      log('OAuth $accessToken');
      try {
        Map<String, String> localHeaders = {};
        // check if token is required then add bearer token in header
        if (tokenRequired) {
          localHeaders.putIfAbsent('Authorization', () => 'OAuth $accessToken');
        }

        _logFirebaseAnalytics('GET', path);

        // var uri = Ugri.https(kBaseURL, path, params);
        final response = client != null
            ? await client!.get(Uri.parse(path), headers: headers ?? localHeaders)
            : await http.get(Uri.parse(path), headers: headers ?? localHeaders);
        // log(jsonEncode(response.body));
        dynamic data; // set decoded body response
        if (response.body.isNotEmpty) {
          data = json.decode(response.body);
        }
        switch (response.statusCode) {
          case 200: // API success
          case 201:
          case 204:
            return HttpResponse(status: true, message: '', data: data);
          case 401:
            await generateAccessToken();
            accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
            Map<String, String> headers = {};
            if (tokenRequired) {
              headers.putIfAbsent('Content-Type', () => 'application/json');
              headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
            }
            final response = client != null
                ? await client!.get(Uri.parse(path), headers: headers ?? localHeaders)
                : await http.get(Uri.parse(path), headers: headers ?? localHeaders);
            dynamic data; // set decoded body response
            if (response.body.isNotEmpty) {
              data = json.decode(response.body);
            }
            if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
              return HttpResponse(status: true, message: '', data: data);
            } else if (response.statusCode != 200) {
              await loggingRequest(
                  processName: "C360 app request",
                  requestedUrl: path,
                  requestedpayload: "",
                  response: response.body,
                  statusCode: response.statusCode.toString(),
                  statusName: "unauthorized",
                  loggedinUserId: loggedInUserId,
                  isPostRequest: false);
            }
            return HttpResponse(status: false, message: '');
          case 403:
            await generateAccessToken();
            accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
            Map<String, String> headers = {};
            if (tokenRequired) {
              headers.putIfAbsent('Content-Type', () => 'application/json');
              headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
            }
            final response = await http.get(Uri.parse(path), headers: headers);
            dynamic data; // set decoded body response
            if (response.body.isNotEmpty) {
              data = json.decode(response.body);
            }

            if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
              return HttpResponse(status: true, message: '', data: data);
            } else if (response.statusCode != 200) {
              await loggingRequest(
                  processName: "C360 app request",
                  requestedUrl: path,
                  requestedpayload: "",
                  response: response.body,
                  statusCode: response.statusCode.toString(),
                  statusName: "client is forbidden",
                  loggedinUserId: loggedInUserId,
                  isPostRequest: false);
            }

            return HttpResponse(status: false, message: '');
          case 400:
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: "",
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "invalid request",
                loggedinUserId: loggedInUserId,
                isPostRequest: false);
            return HttpResponse(status: false, message: '');
          case 404: // API not found
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: "",
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "cannot find the requested resource",
                loggedinUserId: loggedInUserId,
                isPostRequest: false);
            return HttpResponse(status: false, message: '');
          case 504: // Timeout
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: "",
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "Timeout server error",
                loggedinUserId: loggedInUserId,
                isPostRequest: false);
            return HttpResponse(status: false, message: '');
          default:
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: "",
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "Unexpected Error",
                loggedinUserId: loggedInUserId,
                isPostRequest: false);
            return HttpResponse(status: false, message: '');
        }
      } on SocketException {
        return HttpResponse(status: false, message: '');
      } catch (error) {
        return HttpResponse(status: false, message: error.toString());
      }
      // }
      // else {
      //   print("print not a valid token");
      //   _navigator
      //       .read<AuthenticationBloc>()
      //       .add(AuthenticationLogoutRequested(context: _navigator));
      //   return HttpResponse(status: false, message: '');
      // }
    } else {
      String? accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
      String? loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);

      if (accessToken == null) {
        await generateAccessToken();
        accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
      }
      if (Uri.parse(path).queryParameters["loggedinUserId"] == null || (Uri.parse(path).queryParameters["loggedinUserId"] ?? "").isEmpty) {
        if (Uri.parse(path).query.isNotEmpty && !path.contains("q=SELECT") && path.contains("GC_C360")) {
          path = path.trim() + "&loggedinUserId=$loggedInUserId";
        } else if (Uri.parse(path).query.isEmpty && !path.contains("q=SELECT") && path.contains("GC_C360")) {
          path = path.trim() + "?loggedinUserId=$loggedInUserId";
        }
      }
      // log(Uri.parse(path).query);
      // log(Uri.parse(path).queryParameters["loggedinUserId"]??"");
      log("get path $path");
      log('OAuth $accessToken');
      try {
        Map<String, String> localHeaders = {};
        // check if token is required then add bearer token in header
        if (tokenRequired) {
          localHeaders.putIfAbsent('Authorization', () => 'OAuth $accessToken');
        }

        // var uri = Ugri.https(kBaseURL, path, params);
        final response = client != null
            ? await client!.get(Uri.parse(path), headers: headers ?? localHeaders)
            : await http.get(Uri.parse(path), headers: headers ?? localHeaders);
        // log(jsonEncode(response.body));
        dynamic data; // set decoded body response
        if (response.body.isNotEmpty) {
          data = json.decode(response.body);
        }
        switch (response.statusCode) {
          case 200: // API success
          case 201:
          case 204:
            return HttpResponse(status: true, message: '', data: data);
          case 401:
            await generateAccessToken();
            accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
            Map<String, String> headers = {};
            if (tokenRequired) {
              headers.putIfAbsent('Content-Type', () => 'application/json');
              headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
            }
            final response = client != null
                ? await client!.get(Uri.parse(path), headers: headers ?? localHeaders)
                : await http.get(Uri.parse(path), headers: headers ?? localHeaders);
            dynamic data; // set decoded body response
            if (response.body.isNotEmpty) {
              data = json.decode(response.body);
            }
            if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
              return HttpResponse(status: true, message: '', data: data);
            } else if (response.statusCode != 200) {
              await loggingRequest(
                  processName: "C360 app request",
                  requestedUrl: path,
                  requestedpayload: "",
                  response: response.body,
                  statusCode: response.statusCode.toString(),
                  statusName: "unauthorized",
                  loggedinUserId: loggedInUserId,
                  isPostRequest: false);
            }
            return HttpResponse(status: false, message: '');
          case 403:
            await generateAccessToken();
            accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
            Map<String, String> headers = {};
            if (tokenRequired) {
              headers.putIfAbsent('Content-Type', () => 'application/json');
              headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
            }
            final response = await http.get(Uri.parse(path), headers: headers);
            dynamic data; // set decoded body response
            if (response.body.isNotEmpty) {
              data = json.decode(response.body);
            }

            if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
              return HttpResponse(status: true, message: '', data: data);
            } else if (response.statusCode != 200) {
              await loggingRequest(
                  processName: "C360 app request",
                  requestedUrl: path,
                  requestedpayload: "",
                  response: response.body,
                  statusCode: response.statusCode.toString(),
                  statusName: "client is forbidden",
                  loggedinUserId: loggedInUserId,
                  isPostRequest: false);
            }

            return HttpResponse(status: false, message: '');
          case 400:
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: "",
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "invalid request",
                loggedinUserId: loggedInUserId,
                isPostRequest: false);
            return HttpResponse(status: false, message: '');
          case 404: // API not found
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: "",
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "cannot find the requested resource",
                loggedinUserId: loggedInUserId,
                isPostRequest: false);
            return HttpResponse(status: false, message: '');
          case 504: // Timeout
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: "",
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "Timeout server error",
                loggedinUserId: loggedInUserId,
                isPostRequest: false);
            return HttpResponse(status: false, message: '');
          default:
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: "",
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "Unexpected Error",
                loggedinUserId: loggedInUserId,
                isPostRequest: false);
            return HttpResponse(status: false, message: '');
        }
      } on SocketException {
        return HttpResponse(status: false, message: '');
      } catch (error) {
        return HttpResponse(status: false, message: error.toString());
      }
    }
  }

  // post call on http
  Future<HttpResponse> doPost(
      {required String path,
      required Map<String, dynamic> body,
      dynamic params,
      Map<String, String>? headers,
      bool tokenRequired = true,
      bool requiredAuthentication = true,
      bool addLoggedInUserId = true,
      bool xAPIKey = false}) async {
    bool validToken = await SharedPreferenceService().getBool(isValidToken);
    if (requiredAuthentication) {
      // if (validToken) {
      String? accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
      String? instanceUrl = await SharedPreferenceService().getInstanceUrl(key: kInstanceUrlKey);

      if (accessToken == null || instanceUrl == null) {
        await generateAccessToken();
        accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
      }
      String? loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);

/*
    if(Uri.parse(path).queryParameters["loggedinUserId"] == null || (Uri.parse(path).queryParameters["loggedinUserId"]??"").isEmpty){
      if(Uri.parse(path).query.isNotEmpty){
        path = path.trim() + "&loggedinUserId=$loggedInUserId";
      }
      else if(Uri.parse(path).query.isEmpty){
        path = path.trim() + "?loggedinUserId=$loggedInUserId";
      }
    }
*/

      var bodyMap = <String, dynamic>{};
      bodyMap.addAll(body);
      if (addLoggedInUserId && loggedInUserId.isNotEmpty && path.contains("GC_C360")) {
        bodyMap['loggedinUserId'] = loggedInUserId.toString();
      }
      log("post path $path");
      log("body : ${jsonEncode(bodyMap)}");
      try {
        Map<String, String> headers = {};
        if (tokenRequired) {
          headers.putIfAbsent('Content-Type', () => 'application/json');
          if (xAPIKey) {
            headers.putIfAbsent('x-api-key', () => 'ngKUnTWJNo6IkppdLkZmK4CdxBD5P5lD6tIKdVHp');
          } else {
            headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
          }
        }

        _logFirebaseAnalytics('POST', path, body);

        var response;
        try {
          response = client != null
              ? await client!.post(Uri.parse(path), body: jsonEncode(bodyMap), headers: headers)
              : await http.post(Uri.parse(path), body: jsonEncode(bodyMap), headers: headers);
        } catch (e) {
          print(e);
        }
        log(response.body);
        dynamic data; // set decoded body response
        if (response.body.isNotEmpty) {
          data = json.decode(response.body);
        }
        switch (response.statusCode) {
          case 200: // API success
          case 201:
          case 204:
            return HttpResponse(status: true, message: '', data: data);
          case 205: // Failure for test cases
            return HttpResponse(status: false, message: '', data: data);
          case 401:
            await generateAccessToken();
            accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
            Map<String, String> headers = {};
            if (tokenRequired) {
              headers.putIfAbsent('Content-Type', () => 'application/json');
              headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
            }
            final response = client != null
                ? await client!.post(Uri.parse(path), body: jsonEncode(bodyMap), headers: headers)
                : await http.post(Uri.parse(path), body: jsonEncode(bodyMap), headers: headers);
            dynamic data; // set decoded body response
            if (response.body.isNotEmpty) {
              data = json.decode(response.body);
            }
            log(response.body);
            if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
              return HttpResponse(status: true, message: '', data: data);
            } else if (response.statusCode != 200) {
              await loggingRequest(
                  processName: "C360 app request",
                  requestedUrl: path,
                  requestedpayload: jsonEncode(bodyMap),
                  response: response.body,
                  statusCode: response.statusCode.toString(),
                  statusName: "unauthorized",
                  loggedinUserId: loggedInUserId,
                  isPostRequest: true);
            }
            return HttpResponse(status: true, message: '');
          case 403:
            await generateAccessToken();
            accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
            Map<String, String> headers = {};
            if (tokenRequired) {
              headers.putIfAbsent('Content-Type', () => 'application/json');
              headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
            }
            final response = await http.post(Uri.parse(path), body: body, headers: headers);
            dynamic data; // set decoded body response
            if (response.body.isNotEmpty) {
              data = json.decode(response.body);
            }
            if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
              return HttpResponse(status: true, message: '', data: data);
            } else if (response.statusCode != 200) {
              await loggingRequest(
                  processName: "C360 app request",
                  requestedUrl: path,
                  requestedpayload: jsonEncode(bodyMap),
                  response: response.body,
                  statusCode: response.statusCode.toString(),
                  statusName: "unexpected Error",
                  loggedinUserId: loggedInUserId,
                  isPostRequest: true);
            }
            return HttpResponse(status: false, message: '');
          case 400:
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: jsonEncode(bodyMap),
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "invalid request",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
          case 404: // API not found
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: jsonEncode(bodyMap),
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "cannot find the requested resource",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
          case 504: // Timeout
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: jsonEncode(bodyMap),
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "Timeout server error",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
          default:
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: jsonEncode(bodyMap),
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "Unexpected Error",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
        }
      } on SocketException {
        return HttpResponse(status: false, message: '');
      } catch (error) {
        return HttpResponse(status: false, message: error.toString());
      }
      // }
      // else {
      //   print("print not a valid token");
      //   _navigator
      //       .read<AuthenticationBloc>()
      //       .add(AuthenticationLogoutRequested(context: _navigator));
      //   return HttpResponse(status: false, message: '');
      // }
    } else {
      String? accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
      String? instanceUrl = await SharedPreferenceService().getInstanceUrl(key: kInstanceUrlKey);

      if (accessToken == null || instanceUrl == null) {
        await generateAccessToken();
        accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
      }
      String? loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);

/*
    if(Uri.parse(path).queryParameters["loggedinUserId"] == null || (Uri.parse(path).queryParameters["loggedinUserId"]??"").isEmpty){
      if(Uri.parse(path).query.isNotEmpty){
        path = path.trim() + "&loggedinUserId=$loggedInUserId";
      }
      else if(Uri.parse(path).query.isEmpty){
        path = path.trim() + "?loggedinUserId=$loggedInUserId";
      }
    }
*/

      var bodyMap = <String, dynamic>{};
      bodyMap.addAll(body);
      if (addLoggedInUserId && loggedInUserId.isNotEmpty && path.contains("GC_C360")) {
        bodyMap['loggedinUserId'] = loggedInUserId.toString();
      }
      log("post path $path");
      log("body : ${jsonEncode(bodyMap)}");
      try {
        Map<String, String> headers = {};
        if (tokenRequired) {
          headers.putIfAbsent('Content-Type', () => 'application/json');
          if (xAPIKey) {
            headers.putIfAbsent('x-api-key', () => 'ngKUnTWJNo6IkppdLkZmK4CdxBD5P5lD6tIKdVHp');
          } else {
            headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
          }
        }
        var response;
        try {
          response = client != null
              ? await client!.post(Uri.parse(path), body: jsonEncode(bodyMap), headers: headers)
              : await http.post(Uri.parse(path), body: jsonEncode(bodyMap), headers: headers);
        } catch (e) {
          print(e);
        }
        log(response.body);
        dynamic data; // set decoded body response
        if (response.body.isNotEmpty) {
          data = json.decode(response.body);
        }
        switch (response.statusCode) {
          case 200: // API success
          case 201:
          case 204:
            return HttpResponse(status: true, message: '', data: data);
          case 205: // Failure for test cases
            return HttpResponse(status: false, message: '', data: data);
          case 401:
            await generateAccessToken();
            accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
            Map<String, String> headers = {};
            if (tokenRequired) {
              headers.putIfAbsent('Content-Type', () => 'application/json');
              headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
            }
            final response = client != null
                ? await client!.post(Uri.parse(path), body: jsonEncode(bodyMap), headers: headers)
                : await http.post(Uri.parse(path), body: jsonEncode(bodyMap), headers: headers);
            dynamic data; // set decoded body response
            if (response.body.isNotEmpty) {
              data = json.decode(response.body);
            }
            log(response.body);
            if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
              return HttpResponse(status: true, message: '', data: data);
            } else if (response.statusCode != 200) {
              await loggingRequest(
                  processName: "C360 app request",
                  requestedUrl: path,
                  requestedpayload: jsonEncode(bodyMap),
                  response: response.body,
                  statusCode: response.statusCode.toString(),
                  statusName: "unauthorized",
                  loggedinUserId: loggedInUserId,
                  isPostRequest: true);
            }
            return HttpResponse(status: true, message: '');
          case 403:
            await generateAccessToken();
            accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
            Map<String, String> headers = {};
            if (tokenRequired) {
              headers.putIfAbsent('Content-Type', () => 'application/json');
              headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
            }
            final response = await http.post(Uri.parse(path), body: body, headers: headers);
            dynamic data; // set decoded body response
            if (response.body.isNotEmpty) {
              data = json.decode(response.body);
            }
            if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
              return HttpResponse(status: true, message: '', data: data);
            } else if (response.statusCode != 200) {
              await loggingRequest(
                  processName: "C360 app request",
                  requestedUrl: path,
                  requestedpayload: jsonEncode(bodyMap),
                  response: response.body,
                  statusCode: response.statusCode.toString(),
                  statusName: "unexpected Error",
                  loggedinUserId: loggedInUserId,
                  isPostRequest: true);
            }
            return HttpResponse(status: false, message: '');
          case 400:
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: jsonEncode(bodyMap),
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "invalid request",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
          case 404: // API not found
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: jsonEncode(bodyMap),
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "cannot find the requested resource",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
          case 504: // Timeout
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: jsonEncode(bodyMap),
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "Timeout server error",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
          default:
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: jsonEncode(bodyMap),
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "Unexpected Error",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
        }
      } on SocketException {
        return HttpResponse(status: false, message: '');
      } catch (error) {
        return HttpResponse(status: false, message: error.toString());
      }
    }
  }

  Future<HttpResponse> doPatch(
      {required String path,
      dynamic body,
      dynamic params,
      Map<String, String>? headers,
      bool tokenRequired = true,
      bool requiredAuthentication = true}) async {
    if (requiredAuthentication) {
      bool validToken = await SharedPreferenceService().getBool(isValidToken);
      // if (validToken) {
      String? loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);
      String? accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
      String? instanceUrl = await SharedPreferenceService().getInstanceUrl(key: kInstanceUrlKey);

      if (accessToken == null) {
        await generateAccessToken();
        accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
        instanceUrl = await SharedPreferenceService().getInstanceUrl(key: kInstanceUrlKey);
      }

      if (instanceUrl == null) {
        await generateAccessToken();
        accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
        instanceUrl = await SharedPreferenceService().getInstanceUrl(key: kInstanceUrlKey);
      }

      log("patch path $path");
      log(jsonEncode(body));

      try {
        Map<String, String> headers = {};
        if (tokenRequired) {
          // check if token is required then add bearer token in header
          if (tokenRequired) {
            headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
          }
        }

        try {
          _logFirebaseAnalytics('PATCH', path, body);
        } catch(e) {
          log("error analytics: $e");
        }
        var response;
        try {
          response = client != null
              ? await client!.patch(Uri.parse(path), body: body, headers: headers)
              : await http.patch(Uri.parse(path), body: body, headers: headers);
        } catch (e) {
          rethrow;
          print(e);
        }
        log(jsonEncode(response.body));

        dynamic data; // set decoded body response
        if (response.body.isNotEmpty) {
          data = json.decode(response.body);
        }
        switch (response.statusCode) {
          case 200: // API success
          case 201:
          case 204:
            return HttpResponse(status: true, message: '', data: data);
          case 401:
            await generateAccessToken();
            accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
            Map<String, String> headers = {};
            if (tokenRequired) {
              headers.putIfAbsent('Content-Type', () => 'application/json');
              headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
            }
            final response = await http.patch(Uri.parse(path), body: body, headers: headers);
            dynamic data; // set decoded body response
            if (response.body.isNotEmpty) {
              data = json.decode(response.body);
            }
            if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
              return HttpResponse(status: true, message: '', data: data);
            } else if (response.statusCode != 200) {
              await loggingRequest(
                  processName: "C360 app request",
                  requestedUrl: path,
                  requestedpayload: body['requestParams'],
                  response: response.body,
                  statusCode: response.statusCode.toString(),
                  statusName: "unexpected Error",
                  loggedinUserId: loggedInUserId,
                  isPostRequest: true);
            }
            return HttpResponse(status: false, message: '');
          case 403:
            await generateAccessToken();
            accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
            Map<String, String> headers = {};
            if (tokenRequired) {
              headers.putIfAbsent('Content-Type', () => 'application/json');
              headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
            }
            final response = await http.post(Uri.parse(path), body: body, headers: headers);
            dynamic data; // set decoded body response
            if (response.body.isNotEmpty) {
              data = json.decode(response.body);
            }
            if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
              return HttpResponse(status: true, message: '', data: data);
            } else if (response.statusCode != 200) {
              await loggingRequest(
                  processName: "C360 app request",
                  requestedUrl: path,
                  requestedpayload: body['requestParams'],
                  response: response.body,
                  statusCode: response.statusCode.toString(),
                  statusName: "unexpected Error",
                  loggedinUserId: loggedInUserId,
                  isPostRequest: true);
            }
            return HttpResponse(status: false, message: '');
          case 400:
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: body['requestParams'],
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "invalid request",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
          case 404: // API not found
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: body['requestParams'],
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "cannot find the requested resource",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
          case 504: // Timeout
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: body['requestParams'],
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "Timeout server error",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
          default:
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: body['requestParams'],
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "Unexpected Error",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
        }
      } on SocketException {
        return HttpResponse(status: false, message: '');
      } catch (error) {
        return HttpResponse(status: false, message: error.toString());
      }
      // }
      // else {
      //   print("print not a valid token");
      //   _navigator
      //       .read<AuthenticationBloc>()
      //       .add(AuthenticationLogoutRequested(context: _navigator));
      //   return HttpResponse(status: false, message: '');
      // }
    } else {
      String? loggedInUserId = await SharedPreferenceService().getValue(loggedInAgentId);
      String? accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
      String? instanceUrl = await SharedPreferenceService().getInstanceUrl(key: kInstanceUrlKey);

      if (accessToken == null) {
        await generateAccessToken();
        accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
        instanceUrl = await SharedPreferenceService().getInstanceUrl(key: kInstanceUrlKey);
      }

      if (instanceUrl == null) {
        await generateAccessToken();
        accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
        instanceUrl = await SharedPreferenceService().getInstanceUrl(key: kInstanceUrlKey);
      }

      log("patch path $path");
      log(jsonEncode(body));

      try {
        Map<String, String> headers = {};
        if (tokenRequired) {
          // check if token is required then add bearer token in header
          if (tokenRequired) {
            headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
          }
        }
        var response;
        try {
          response = client != null
              ? await client!.patch(Uri.parse(path), body: body, headers: headers)
              : await http.patch(Uri.parse(path), body: body, headers: headers);
        } catch (e) {
          print(e);
        }
        log(jsonEncode(response.body));

        dynamic data; // set decoded body response
        if (response.body.isNotEmpty) {
          data = json.decode(response.body);
        }
        switch (response.statusCode) {
          case 200: // API success
          case 201:
          case 204:
            return HttpResponse(status: true, message: '', data: data);
          case 401:
            await generateAccessToken();
            accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
            Map<String, String> headers = {};
            if (tokenRequired) {
              headers.putIfAbsent('Content-Type', () => 'application/json');
              headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
            }
            final response = await http.patch(Uri.parse(path), body: body, headers: headers);
            dynamic data; // set decoded body response
            if (response.body.isNotEmpty) {
              data = json.decode(response.body);
            }
            if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
              return HttpResponse(status: true, message: '', data: data);
            } else if (response.statusCode != 200) {
              await loggingRequest(
                  processName: "C360 app request",
                  requestedUrl: path,
                  requestedpayload: body['requestParams'],
                  response: response.body,
                  statusCode: response.statusCode.toString(),
                  statusName: "unexpected Error",
                  loggedinUserId: loggedInUserId,
                  isPostRequest: true);
            }
            return HttpResponse(status: false, message: '');
          case 403:
            await generateAccessToken();
            accessToken = await SharedPreferenceService().getUserToken(key: kAccessTokenKey);
            Map<String, String> headers = {};
            if (tokenRequired) {
              headers.putIfAbsent('Content-Type', () => 'application/json');
              headers.putIfAbsent('Authorization', () => 'OAuth $accessToken');
            }
            final response = await http.post(Uri.parse(path), body: body, headers: headers);
            dynamic data; // set decoded body response
            if (response.body.isNotEmpty) {
              data = json.decode(response.body);
            }
            if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
              return HttpResponse(status: true, message: '', data: data);
            } else if (response.statusCode != 200) {
              await loggingRequest(
                  processName: "C360 app request",
                  requestedUrl: path,
                  requestedpayload: body['requestParams'],
                  response: response.body,
                  statusCode: response.statusCode.toString(),
                  statusName: "unexpected Error",
                  loggedinUserId: loggedInUserId,
                  isPostRequest: true);
            }
            return HttpResponse(status: false, message: '');
          case 400:
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: body['requestParams'],
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "invalid request",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
          case 404: // API not found
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: body['requestParams'],
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "cannot find the requested resource",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
          case 504: // Timeout
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: body['requestParams'],
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "Timeout server error",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
          default:
            await loggingRequest(
                processName: "C360 app request",
                requestedUrl: path,
                requestedpayload: body['requestParams'],
                response: response.body,
                statusCode: response.statusCode.toString(),
                statusName: "Unexpected Error",
                loggedinUserId: loggedInUserId,
                isPostRequest: true);
            return HttpResponse(status: false, message: '');
        }
      } on SocketException {
        return HttpResponse(status: false, message: '');
      } catch (error) {
        return HttpResponse(status: false, message: error.toString());
      }
    }
  }

/*  Future<void> generateAccessToken() async {
    var tokenResponse = await http.post(Uri.parse(tokenURL),
        body: jsonEncode(authJsonAccessToken),
        headers: authJsonAccessHeader);

    if (tokenResponse.statusCode == 200) {
      AccessTokenModel accessTokenModel = AccessTokenModel.fromJson(json.decode(tokenResponse.body));
      if(accessTokenModel.success! && accessTokenModel.data != null  && accessTokenModel.data!.tokenData != null ){
        try {
          String accessToken = accessTokenModel.data!.tokenData!.accessToken??"";
          SharedPreferenceService().setUserToken(authToken: accessToken);
          print(accessToken);
        } catch (e) {
        }
      }
    }
  }*/
  Future<void> generateAccessToken() async {
    log(jsonEncode(authJson));
    var tokenResponse = await http.post(Uri.parse('${Endpoints.kBaseURL}$authURL'), body: authJson);

    if (tokenResponse.statusCode == 200) {
      try {
        var accessTokenBody = jsonDecode(tokenResponse.body);
        var accessToken = accessTokenBody['access_token'];
        var instanceUrl = accessTokenBody['instance_url'];
        SharedPreferenceService().setUserToken(authToken: accessToken);
        SharedPreferenceService().setInstanceUrl(url: instanceUrl);
        print(accessToken);
      } catch (e) {}
    }
  }

  Future<void> loggingRequest(
      {required String processName,
      required String requestedUrl,
      required String requestedpayload,
      response,
      required String statusCode,
      required String statusName,
      required String loggedinUserId,
      required bool isPostRequest}) async {
    this.doPost(
        path: Endpoints.loggingAPI(),
        body: RequestBody.loggedinAPIMapp(
            processName: processName,
            requestedUrl: requestedUrl,
            requestedpayload: requestedpayload,
            response: response,
            statusCode: statusCode,
            statusName: statusName,
            loggedinUserId: loggedinUserId,
            isPostRequest: isPostRequest));
  }

  void _logFirebaseAnalytics(String method, String path, [Map<String, dynamic>? body]) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    var pathName = path;
    if (path.contains('/')) {
      var paths = path.split('/');
      if (paths.last.isEmpty) {
        pathName = paths[paths.length - 2];
      } else {
        pathName = paths.last;
      }
    }
    if (pathName.contains('?') && !path.contains('query/?')) {
      pathName = pathName.split('?').first;
    }
    pathName = pathName.replaceAll('?q=', '');
    Map<String, String> param = {'method': method, 'path': path};
    if (body != null) {
      param.addAll({'body': body.toString()});
    }
    FirebaseAnalytics.instance.logEvent(name: pathName, parameters: param);
  }
}
