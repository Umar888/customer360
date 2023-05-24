part of 'order_printer_bloc.dart';


enum LoadingPrinters {loading, notLoading}
@immutable
abstract class OrderPrinterState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderPrinterInitial extends OrderPrinterState {}

class OrderPrinterProgress extends OrderPrinterState {
  final List<PrinterModel>? zebraPrinters;
  final List<PrinterModel>? epsonPrinters;
  LoadingPrinters loadingPrinters;

  OrderPrinterProgress({this.zebraPrinters, this.epsonPrinters, required this. loadingPrinters});
  @override
  List<Object?> get props => [zebraPrinters, epsonPrinters,loadingPrinters];
}

class OrderPrinterFailure extends OrderPrinterState {
  final List<PrinterModel>? zebraPrinters;
  final List<PrinterModel>? epsonPrinters;
  final String? message;
  LoadingPrinters loadingPrinters;

  OrderPrinterFailure({this.message, this.zebraPrinters, this.epsonPrinters, required this. loadingPrinters});

  @override
  List<Object?> get props => [message, zebraPrinters, epsonPrinters,loadingPrinters];
}

class OrderPrinterSuccess extends OrderPrinterState {
  final List<PrinterModel> zebraPrinters;
  final List<PrinterModel> epsonPrinters;
  final String? message;
  LoadingPrinters loadingPrinters;
  OrderPrinterSuccess(
      {required this.zebraPrinters, required this.epsonPrinters, this.message, required this. loadingPrinters});

  @override
  List<Object?> get props => [zebraPrinters, epsonPrinters,loadingPrinters];
}
