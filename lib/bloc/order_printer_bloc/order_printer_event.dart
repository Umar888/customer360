part of 'order_printer_bloc.dart';

abstract class OrderPrinterEvent extends Equatable {
  OrderPrinterEvent();
}

class LoadOrderPrinters extends OrderPrinterEvent {
  LoadOrderPrinters();

  @override
  List<Object?> get props => [];
}

class PrintOrder extends OrderPrinterEvent {
  final String printerValue;
  final String orderId;
  PrintOrder(this.printerValue, this.orderId);

  @override
  List<Object?> get props => [printerValue];
}

class FetchStoreAddress extends OrderPrinterEvent {
  final String printerValue;
  final String orderId;
  final Map<String, dynamic> paymentInfo;
  final OrderDetail orderDetail;
  FetchStoreAddress(this.printerValue, this.orderId, this.paymentInfo, this.orderDetail);

  @override
  List<Object?> get props => [printerValue,orderId,paymentInfo,orderDetail];
}

class SelectOrderPrinter extends OrderPrinterEvent {
  final PrinterModel printer;
  SelectOrderPrinter(this.printer);

  @override
  List<Object?> get props => [printer];
}
