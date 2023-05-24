import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/data/reporsitories/order_printer_repository/order_printer_repository.dart';
import 'package:gc_customer_app/models/printer_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

import '../../models/cart_model/tax_model.dart';

part 'order_printer_event.dart';
part 'order_printer_state.dart';

class OrderPrinterBloC extends Bloc<OrderPrinterEvent, OrderPrinterState> {
  MethodChannel platformChannel = MethodChannel('com.guitarcenter.uatcustomer360/iOS');
  final OrderPrinterRepository orderPrinterRepository;

  OrderPrinterBloC(this.orderPrinterRepository) : super(OrderPrinterInitial()) {
    on<LoadOrderPrinters>(
      (event, emit) async {
        emit(OrderPrinterProgress(
            epsonPrinters: [],
            zebraPrinters: [],
            loadingPrinters: LoadingPrinters.loading));

        String loggedId =
            await SharedPreferenceService().getValue(loggedInAgentId);

        const platformChannel =
            MethodChannel('com.guitarcenter.uatcustomer360/iOS');
        List<PrinterModel> searchedPrinters = [];
        try {
          final String jsonSearchedPrinters =
              await platformChannel.invokeMethod('getDevices');
          List<dynamic> jsonList = json.decode(jsonSearchedPrinters);
          searchedPrinters = List<PrinterModel>.from(
            jsonList.map((json) => PrinterModel.fromJson(json)),
          );
        } catch (e) {
          print("search printerr error ${e}");
        }

        if ((loggedId).isNotEmpty) {
          var typeMap = await orderPrinterRepository.getPrinterTypes();
          bool isShowZprinter = typeMap['ZPrinter'] == true;
          bool isShowEpsonPrinter = typeMap['EpsonPrinter'] == true;

          var printers = await orderPrinterRepository
              .getPrinters(loggedId)
              .catchError((_) {
            emit(OrderPrinterFailure(
                epsonPrinters: searchedPrinters,
                zebraPrinters: [],
                loadingPrinters: LoadingPrinters.notLoading));
          });
          List<PrinterModel> zebraPrinters = isShowZprinter
              ? printers.where((p) => p.type?.toLowerCase() == 'zebra').toList()
              : [];
          List<PrinterModel> epsonPrinters = isShowEpsonPrinter
              ? printers.where((p) => p.type?.toLowerCase() == 'epson').toList()
              : [];
          emit(OrderPrinterSuccess(
              zebraPrinters: zebraPrinters,
              epsonPrinters: (epsonPrinters + searchedPrinters),
              loadingPrinters: LoadingPrinters.notLoading));

          return;
        }

        emit(OrderPrinterFailure(loadingPrinters: LoadingPrinters.notLoading));
        return;
      },
    );

    on<PrintOrder>(
      (event, emit) async {
        var zPrinters = (state as OrderPrinterSuccess).zebraPrinters;
        var ePrinters = (state as OrderPrinterSuccess).epsonPrinters;
        emit(OrderPrinterProgress(
            epsonPrinters: ePrinters,
            zebraPrinters: zPrinters,
            loadingPrinters: LoadingPrinters.notLoading));
        await orderPrinterRepository
            .printOrder(event.printerValue, event.orderId)
            .then((value) {
          emit(OrderPrinterSuccess(
              epsonPrinters: ePrinters,
              loadingPrinters: LoadingPrinters.notLoading,
              zebraPrinters: zPrinters,
              message: value));
        }).catchError((onError) {
          print('onerror: ${onError.toString()}');
          emit(OrderPrinterFailure(
              message: onError.toString(),
              loadingPrinters: LoadingPrinters.notLoading));
          emit(OrderPrinterSuccess(
              epsonPrinters: ePrinters,
              zebraPrinters: zPrinters,
              loadingPrinters: LoadingPrinters.notLoading));
        });
        return;
      },
    );

    on<FetchStoreAddress>(
      (event, emit) async {
        var zPrinters = (state as OrderPrinterSuccess).zebraPrinters;
        var ePrinters = (state as OrderPrinterSuccess).epsonPrinters;
        emit(OrderPrinterProgress(
            epsonPrinters: ePrinters,
            zebraPrinters: zPrinters,
            loadingPrinters: LoadingPrinters.notLoading));
        print("order details ${event.orderDetail}");
        print("payment details ${event.paymentInfo}");
        String loggedId =
            await SharedPreferenceService().getValue(loggedInAgentId);
        if (loggedId.isNotEmpty) {
          await orderPrinterRepository
              .fetchStoreAddress(loggedId)
              .then((value) async {
            var paymentData = event.paymentInfo;
            var paymentInfo = jsonDecode(paymentData['paymentInfo']);
            final String printData =
                await platformChannel.invokeMethod('getPrintData', {
              "storeAddress": value,
              "paymentInfo": paymentInfo,
              "orderDetails": event.orderDetail.toJson(),
              "ipAddresss": "TCP:" + event.printerValue.toString().trim()
            });
            var logPrintData = await orderPrinterRepository.loggPrintData(
                event.printerValue, printData);
            final String result =
                await platformChannel.invokeMethod('printOrder', {
              "storeAddress": value,
              "paymentInfo": paymentInfo,
              "orderDetails": event.orderDetail.toJson(),
              "ipAddresss": "TCP:" + event.printerValue.toString().trim()
            });
            //  showMessage(context: event.context,message:result);
            emit(OrderPrinterSuccess(
                epsonPrinters: ePrinters,
                loadingPrinters: LoadingPrinters.notLoading,
                zebraPrinters: zPrinters,
                message: result));
          }).catchError((onError) {
            emit(OrderPrinterFailure(
                message: onError.toString(),
                loadingPrinters: LoadingPrinters.notLoading));
            emit(OrderPrinterSuccess(
                epsonPrinters: ePrinters,
                zebraPrinters: zPrinters,
                loadingPrinters: LoadingPrinters.notLoading));
          });
        } else {
          emit(OrderPrinterFailure(
              message: "Failed", loadingPrinters: LoadingPrinters.notLoading));
          emit(OrderPrinterSuccess(
              epsonPrinters: ePrinters,
              zebraPrinters: zPrinters,
              loadingPrinters: LoadingPrinters.notLoading));
        }
        return;
      },
    );
  }
}
