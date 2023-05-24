// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/order_printer_bloc/order_printer_bloc.dart';
import 'package:gc_customer_app/data/reporsitories/order_printer_repository/order_printer_repository.dart';
import 'package:gc_customer_app/models/cart_model/tax_model.dart';
import 'package:gc_customer_app/models/printer_model.dart';
import 'package:gc_customer_app/services/networking/endpoints.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late OrderPrinterBloC? orderPrinterBloc;
  const MethodChannel channel = MethodChannel('com.guitarcenter.uatcustomer360/iOS');
  SharedPreferences.setMockInitialValues({
    'agent_email': 'ankit.kumar@guitarcenter.com',
    'agent_id': '0014M00001nv3BwQAI',
    'agent_id_c360': '0014M00001nv3BwQAI',
    'logged_agent_id': '0054M000004UMmEQAW',
    'access_token': '12345',
    'instance_url': '12345',
  });

  late bool successScenario;
  OrderPrinterBloC setUpBloc() {
    var mock = MockClient((request) async {
      if (successScenario) {
        if (request.matches(Endpoints.kClientPrinterType.escape)) {
          print("Success: ${request.url}");
          return Response(json.encode({"ZPrinter": true, "EpsonPrinter": true}), 200);
        } else if (request.matches(Endpoints.kClientLocation.escape)) {
          print("Success: ${request.url}");
          return Response(json.encode({"printers":[], "responses":[{"status": "success"}]}), 200);
        } else if (request.matches(Endpoints.kStoreZipAddress.escape)) {
          print("Success: ${request.url}");
          return Response(json.encode({"storeUser":{}}), 200);
        } else if (request.matches(Endpoints.kPrintLoggingAPI.escape)) {
          print("Success: ${request.url}");
          return Response(json.encode({"storeUser":{}}), 200);
        } else {
          print("API call not mocked: ${request.url}");
          return Response(json.encode({}), 205);
        }
      } else {
        print("Failed: ${request.url}");
        return Response("", 205);
      }
    });
    return OrderPrinterBloC(OrderPrinterRepository()..orderPrinterDataSource.httpService.client = mock);
  }

  group(
    'Success Scenarios',
    () {
      setUp(() => successScenario = true);

      blocTest<OrderPrinterBloC, OrderPrinterState>(
        'Load Order Printers',
        setUp: () => channel.setMockMethodCallHandler((MethodCall methodCall) async => json.encode([PrinterModel().toJson()])),
        build: () => orderPrinterBloc = setUpBloc()..platformChannel = channel,
        tearDown: () => {orderPrinterBloc = null,channel.setMockMethodCallHandler(null)},
        act: (bloc) => bloc.add(LoadOrderPrinters()),
        expect: () => [
          OrderPrinterProgress(epsonPrinters: [], zebraPrinters: [], loadingPrinters: LoadingPrinters.loading),
          OrderPrinterSuccess(
            zebraPrinters: [],
            epsonPrinters: [PrinterModel()],
            loadingPrinters: LoadingPrinters.notLoading,
          ),
        ],
      );

      blocTest<OrderPrinterBloC, OrderPrinterState>(
        'Print Order',
        build: () => orderPrinterBloc = setUpBloc(),
        tearDown: () => orderPrinterBloc = null,
        seed: () => OrderPrinterSuccess(epsonPrinters: [], zebraPrinters: [], loadingPrinters: LoadingPrinters.notLoading),
        act: (bloc) => bloc.add(PrintOrder("Wow", "123")),
        expect: () => [
          OrderPrinterProgress(epsonPrinters: [], zebraPrinters: [], loadingPrinters: LoadingPrinters.notLoading),
          OrderPrinterSuccess(epsonPrinters: [], loadingPrinters: LoadingPrinters.notLoading, zebraPrinters: [], message: "success"),
        ],
      );

      blocTest<OrderPrinterBloC, OrderPrinterState>(
        'Fetch Store Address',
        setUp: () => channel.setMockMethodCallHandler((MethodCall methodCall) async => json.encode([PrinterModel().toJson()])),
        build: () => orderPrinterBloc = setUpBloc()..platformChannel = channel,
        tearDown: () => {orderPrinterBloc = null,channel.setMockMethodCallHandler(null)},
        seed: () => OrderPrinterSuccess(epsonPrinters: [], zebraPrinters: [], loadingPrinters: LoadingPrinters.notLoading),
        act: (bloc) => bloc.add(FetchStoreAddress(
          "Wow",
          "123",
          {"paymentInfo": json.encode({})},
          OrderDetail(paymentMethods: [PaymentMethods(attributes: Attributes())]),
        )),
        expect: () => [
          OrderPrinterProgress(epsonPrinters: [], zebraPrinters: [], loadingPrinters: LoadingPrinters.notLoading),
          OrderPrinterSuccess(epsonPrinters: [], loadingPrinters: LoadingPrinters.notLoading, zebraPrinters: [], message: "success"),
        ],
      );
    },
  );

  group(
    'Failure Scenarios',
    () {
      setUp(() => successScenario = false);
    },
  );
}
