import 'package:gc_customer_app/data/data_sources/order_printer_data_source/order_printer_data_source.dart';
import 'package:gc_customer_app/models/printer_model.dart';
import 'package:gc_customer_app/models/product_detail_model/other_store_model.dart';

class OrderPrinterRepository {
  OrderPrinterDataSource orderPrinterDataSource = OrderPrinterDataSource();

  Future getPrinterTypes() async {
    var response = await orderPrinterDataSource.getPrinterTypes();
    return response.data;
  }

  Future<List<PrinterModel>> getPrinters(String loggedIdId) async {
    var response = await orderPrinterDataSource.getOrderPrinters(loggedIdId);

    if (response.data['printers'] != null) {
      List<PrinterModel> printers = response.data['printers']
              ?.map<PrinterModel>((pr) => PrinterModel.fromJson(pr))
              .toList() ??
          <PrinterModel>[];
      return printers;
    } else {
      throw (Exception(response.message ?? ''));
    }
  }

  Future<String> printOrder(String printerValue, String recordId) async {
    var response =
        await orderPrinterDataSource.printOrder(recordId, printerValue);
    if (response.data['responses'] != null &&
        response.data['responses'].isNotEmpty) {
      return response.data['responses'][0]['status'];
    } else if (response.data['errorResponse'] != null) {
      throw (Exception(response.data['errorResponse']['message']));
    } else {
      throw (Exception(response.message ?? ''));
    }
  }

  Future<Map<String, dynamic>> fetchStoreAddress(String loggedInId) async {
    var response =
        await orderPrinterDataSource.fetchStoreAddress(loggedInId);
    if (response.data['storeUser'] != null) {
      return response.data['storeUser'];
    } else {
      throw (Exception(response.message ?? ''));
    }
  }

   Future<String> loggPrintData(String printerName, String printData) async {
    var response =
        await orderPrinterDataSource.printLoggingCall(printerName, printData);
        return response.data.toString();
    }
}
