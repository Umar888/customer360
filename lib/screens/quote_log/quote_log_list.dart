import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gc_customer_app/app.dart';
import 'package:gc_customer_app/bloc/cart_bloc/cart_bloc.dart' as cb;
import 'package:gc_customer_app/common_widgets/no_data_found.dart';
import 'package:gc_customer_app/models/cart_model/tax_model.dart';
import 'package:gc_customer_app/models/quotes_history_list_model/quotes_history_list_model.dart';
import 'package:gc_customer_app/utils/constant_functions.dart';
import 'package:gc_customer_app/utils/double_extention.dart';
import 'package:open_file/open_file.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../bloc/quote_log_bloc/quote_log_bloc.dart';
import '../../primitives/color_system.dart';
import '../../primitives/constants.dart';
import '../../primitives/icon_system.dart';
import '../../primitives/padding_system.dart';
import '../../primitives/size_system.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;

typedef LayoutCallbackWithData = Future<Uint8List> Function(
    PdfPageFormat pageFormat);

class QuoteLogList extends StatefulWidget {
  final String orderId;
  final String orderDate;
  final cb.CartState cartState;

  QuoteLogList(
      {required this.orderId,
      required this.orderDate,
      Key? key,
      required this.cartState})
      : super(key: key);

  @override
  State<QuoteLogList> createState() => _QuoteLogListState();
}

class _QuoteLogListState extends State<QuoteLogList> {
  late QuoteLogBloc quoteLogBloc;

  @override
  initState() {
    quoteLogBloc = context.read<QuoteLogBloc>();
    quoteLogBloc.add(PageLoad(orderID: widget.orderId));
    //_futureOrderDetail=getOrders();
    // FirebaseAnalytics.instance
    //     .setCurrentScreen(screenName: 'QuoteOrderHistoryScreen');
    super.initState();
  }

  AppBar getAppBar(QuoteLogState state) {
    return AppBar(
      backgroundColor: Colors.grey.shade50,
      leading: CloseButton(
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "QUOTE HISTORY",
        style: TextStyle(
            fontSize: SizeSystem.size17,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: Color(0xFF222222),
            fontFamily: kRubik),
      ),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.orderId);
    return BlocConsumer<QuoteLogBloc, QuoteLogState>(
        listener: (context, state) {
      if (state.quoteLogStatus == QuoteLogStatus.successState &&
          state.message.isNotEmpty &&
          state.message != "done" &&
          state.message != "zebon") {
        Future.delayed(Duration.zero, () {
          setState(() {});
          showMessage(context: context, message: state.message);
        });
      }
      quoteLogBloc.add(EmptyMessage());
    }, builder: (context, state) {
      // today text display
      String todayText(String date, int index) {
        final difference = DateTime.parse(state.quoteList[index].expiryDate)
            .difference(DateTime.now());
        print(difference.inDays);
        if (difference.inDays == 0) {
          return 'Today, ';
        }
        return '';
      }

      if (state.quoteLogStatus == QuoteLogStatus.successState) {
        return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: getAppBar(state),
            body: ListView.builder(
              itemCount: state.quoteList.length,
              itemBuilder: (context, index) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      quoteLogBloc.add(OnPressQuote(index: index));
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "QUOTE ID: ",
                                        style: TextStyle(
                                            fontSize: SizeSystem.size13,
                                            fontWeight: FontWeight.w500,
                                            color: ColorSystem.greyDark,
                                            fontFamily: kRubik),
                                      ),
                                      Text(
                                        state.quoteList[index].quoteNumber,
                                        style: TextStyle(
                                            fontSize: SizeSystem.size13,
                                            fontWeight: FontWeight.w500,
                                            color: ColorSystem.greyDark,
                                            fontFamily: kRubik),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                            state.quoteList[index].firstName +
                                                ' ' +
                                                state.quoteList[index].lastName,
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontSize: SizeSystem.size17,
                                                overflow: TextOverflow.ellipsis,
                                                color: Color(0xff222222),
                                                fontFamily: kRubik)),
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                  '\$ ${amountFormatting(double.parse(state.quoteList[index].subtotal))}',
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      fontSize:
                                                          SizeSystem.size17,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      color: Color(0xff222222),
                                                      fontFamily: kRubik)),
                                              SizedBox(height: 5),
                                              Text(
                                                  state.quoteList[index]
                                                          .itemCount
                                                          .toString() +
                                                      ' Items',
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontSize:
                                                          SizeSystem.size14,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xff222222),
                                                      fontFamily: kRubik)),
                                            ],
                                          ),
                                          SizedBox(width: 15),
                                          state.quoteList[index].isPressed!
                                              ? SvgPicture.asset(
                                                  IconSystem
                                                      .checkboxRoundFilled,
                                                  package: 'gc_customer_app',
                                                )
                                              : SvgPicture.asset(
                                                  IconSystem.checkboxRoundEmpty,
                                                  package: 'gc_customer_app',
                                                )
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Created on: ",
                                        style: TextStyle(
                                            fontSize: SizeSystem.size15,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontFamily: kRubik),
                                      ),
                                      Text(
                                        intl.DateFormat('dd-MMM-yyyy').format(
                                            DateTime.parse(state
                                                .quoteList[index].createDate)),
                                        style: TextStyle(
                                            fontSize: SizeSystem.size15,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontFamily: kRubik),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Expiry on: ",
                                        style: TextStyle(
                                            fontSize: SizeSystem.size15,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontFamily: kRubik),
                                      ),
                                      Text(
                                        intl.DateFormat('dd-MMM-yyyy').format(
                                            DateTime.parse(state
                                                .quoteList[index].expiryDate)),
                                        style: TextStyle(
                                            fontSize: SizeSystem.size15,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontFamily: kRubik),
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Sent to: ",
                                              style: TextStyle(
                                                  fontSize: SizeSystem.size14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontFamily: kRubik),
                                            ),
                                            Flexible(
                                              child: Text(
                                                state.quoteList[index].email,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontSize: SizeSystem.size14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontFamily: kRubik),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            downloadPDF(false, state,
                                                state.quoteList[index], index);
                                          },
                                          icon: Icon(Icons.print))
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        todayText(
                                            state.quoteList[index].createDate,
                                            index),
                                        style: TextStyle(
                                            fontSize: SizeSystem.size15,
                                            fontWeight: FontWeight.w400,
                                            color: ColorSystem.greyDark,
                                            fontFamily: kRubik),
                                      ),
                                      Text(
                                        state.quoteList[index].createTime,
                                        style: TextStyle(
                                            fontSize: SizeSystem.size15,
                                            fontWeight: FontWeight.w400,
                                            color: ColorSystem.greyDark,
                                            fontFamily: kRubik),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Divider(
                      color: ColorSystem.greyDark,
                    ),
                  )
                ],
              ),
            ));
      } else if (state.quoteLogStatus == QuoteLogStatus.failedState) {
        return Scaffold(
          appBar: getAppBar(state),
          body: Center(child: NoDataFound(fontSize: 20)),
          // body: Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     SizedBox(
          //       height: SizeSystem.size50,
          //     ),
          //     SvgPicture.asset(IconSystem.noDataFound),
          //     SizedBox(
          //       height: SizeSystem.size24,
          //     ),
          //     Text(
          //       'NO DATA FOUND!',
          //       style: TextStyle(
          //         color: Theme.of(context).primaryColor,
          //         fontWeight: FontWeight.bold,
          //         fontFamily: kRubik,
          //         fontSize: SizeSystem.size20,
          //       ),
          //     )
          //   ],
          // ),
        );
      } else {
        return Scaffold(
            appBar: getAppBar(state),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: SizeSystem.size50,
                ),
                Center(
                    child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                )),
                SizedBox(
                  height: SizeSystem.size50,
                ),
              ],
            ));
      }
    });
  }

  Future<void> downloadPDF(bool isView, QuoteLogState state,
      QuoteHistoryList quote, int index) async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      getPdf(isView, state, quote, index);
    } else if (status.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.phone,
        Permission.storage,
      ].request();
      if (await Permission.storage.request().isGranted) {
        getPdf(isView, state, quote, index);
      }
    } else if (status.isRestricted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.phone,
        Permission.storage,
      ].request();
      if (await Permission.storage.request().isGranted) {
        getPdf(isView, state, quote, index);
      }
    } else if (status.isLimited) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.phone,
        Permission.storage,
      ].request();
      if (await Permission.storage.request().isGranted) {
        getPdf(isView, state, quote, index);
      }
    }
  }

  Future getPdf(bool isView, QuoteLogState state, QuoteHistoryList quote,
      int index) async {
    pw.Document pdf = pw.Document(
      theme: pw.ThemeData(
        iconTheme: pw.IconThemeData(color: PdfColors.black),
      ),
    );
//     if (isView) {}
//     final imageHeadingFilled = pw.MemoryImage(
//       (await rootBundle.load(IconSystem.checkboxRoundFilledFile))
//           .buffer
//           .asUint8List(),
//     );

//     final imageHeadingEmpty = pw.MemoryImage(
// //      File(IconSystem.checkboxRoundEmptyFile).readAsBytesSync(),
//       (await rootBundle.load(IconSystem.checkboxRoundEmptyFile))
//           .buffer
//           .asUint8List(),
//     );
//     String todayText(String date, int index) {
//       final difference = DateTime.parse(state.quoteList[index].expiryDate)
//           .difference(DateTime.now());
//       print(difference.inDays);
//       if (difference.inDays == 0) {
//         return 'Today, ${state.quoteList[index].createTime}';
//       }
//       return '';
//     }

    // print(await http.read(Uri(path: state.quoteList[0].contentUrl)));
    print(state.quoteList[0].contentUrl.runes);

    var images = [];
    var imagesBundle = [];

    for (var item in widget.cartState.orderDetailModel[0].items ?? []) {
      images.add(await networkImage(item.imageUrl ?? ''));
    }
    imagesBundle.add(await imageFromAssetBundle(
        'packages/gc_customer_app/' + IconSystem.warrantyImage));

    // var netImage = await pw.SvgImage(svg: state.quoteList[0].contentUrl);

    //Each page can have 5 product maximum.
    int pageLength =
        ((widget.cartState.orderDetailModel[0].items?.length ?? 0) / 5).ceil();
    int currentItem = 0;

    for (var i = 0; i < pageLength; i++) {
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
              padding: pw.EdgeInsets.symmetric(horizontal: 0),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (i == 0)
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text(
                              'Quote #: ${quote.quoteNumber}',
                              style: pw.TextStyle(fontSize: 18),
                            )
                          ]),
                    pw.SizedBox(height: 15),
                    ...widget.cartState.orderDetailModel[0].items
                            ?.asMap()
                            .entries
                            .map<pw.Widget>((e) {
                          if (e.key == (i * 5 + (e.key % 5))) {
                            return _pdfProductItem(
                                images[e.key], e.value, imagesBundle[0]);
                          }
                          return pw.SizedBox.shrink();
                        }).toList() ??
                        [],
                    if (i == pageLength - 1)
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Total: \$${(state.quoteList[index].subtotal)}',
                              style: pw.TextStyle(fontSize: 18),
                            ),
                          ]),
                  ]));
        },
      ));
    }

    var pdfFile = await pdf.save();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              leading: CloseButton(onPressed: () => Navigator.pop(context)),
              title: Text(
                "GC QUOTE",
                style: TextStyle(
                    fontSize: SizeSystem.size17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: Color(0xFF222222),
                    fontFamily: kRubik),
              ),
            ),
            body: PdfPreview(
              build: (format) {
                return pdfFile;
              },
              pdfFileName: widget.cartState.orderDetailModel[0].orderNumber,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              allowPrinting: false,
              allowSharing: false,
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.download, color: ColorSystem.black),
              backgroundColor: ColorSystem.white,
              onPressed: () {
                _saveAsFile(pdfFile);
              },
            ),
          ),
        ));

    // Directory appDocDirectory = await getApplicationDocumentsDirectory();
    // Directory('${appDocDirectory.path}/pdfs')
    //     .create(recursive: true)
    //     .then((Directory directory) async {
    //   if (kDebugMode) {
    //     print('Path of New Dir: ${directory.path}');
    //   }
    //   String filename =
    //       "${directory.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.pdf";
    //   File pdfFile = File(filename);
    //   await pdfFile.writeAsBytes(await pdf.save()).then((value) {
    //     OpenFile.open(filename);
    //     showMessage(context: context,message:"PDF saved in ${directory.path}!");
    //   });
    // });
  }

  Future<void> _saveAsFile(
    // BuildContext context,
    // LayoutCallback build,
    // PdfPageFormat pageFormat,
    Uint8List fileBytes,
  ) async {
    // final bytes = await build(pageFormat);

    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    final file = File(appDocPath + '/' + '${widget.orderId}.pdf');
    print('Save as file ${file.path} ...');
    await file.writeAsBytes(fileBytes);
    await OpenFile.open(file.path);
  }

  _pdfProductItem(dynamic image, Items value, dynamic assetImage) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                  width: 110,
                  height: 110,
                  child: pw.Image(image, fit: pw.BoxFit.cover)),
              pw.SizedBox(width: 14),
              pw.Expanded(
                  child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "SKU #: ${value.itemNumber}",
                    style: pw.TextStyle(
                      fontSize: SizeSystem.size13,
                      color: PdfColors.grey,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    value.itemDesc!,
                    maxLines: 2,
                    overflow: pw.TextOverflow.visible,
                    style: pw.TextStyle(
                      fontSize: SizeSystem.size17,
                      fontWeight: pw.FontWeight.bold,
                      // color: PdfColor(34, 34, 34, 1),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Quantity: ${(value.quantity ?? 0.0).toInt()}',
                    style: pw.TextStyle(
                      fontSize: SizeSystem.size16,
                      // color: PdfColor(155, 158, 185, 1)
                    ),
                  ),
                  pw.Row(children: [
                    pw.Text(
                      'Price: ${value.overridePriceApproval == 'Approved' ? '\$${(value.overridePrice ?? 0).toStringAsFixed(2)}' : '\$${(value.unitPrice ?? 0).toStringAsFixed(2)}'} ',
                      style: pw.TextStyle(
                        fontSize: SizeSystem.size16,
                        // color: PdfColor(155, 158, 185, 1),
                      ),
                    ),
                    if (value.overridePriceApproval == 'Approved')
                      pw.Text(
                        ' \$${value.unitPrice ?? 0}',
                        style: pw.TextStyle(
                          fontSize: SizeSystem.size16,
                          color: PdfColors.red,
                          decoration: pw.TextDecoration.lineThrough,
                        ),
                      ),
                    if (value.overridePriceApproval == 'Approved')
                      pw.Text(
                        ' (${(100 - value.overridePrice! / value.unitPrice! * 100).toShortPercent()}%)',
                        style: pw.TextStyle(
                          fontSize: SizeSystem.size16,
                          color: PdfColors.red,
                        ),
                      ),
                  ])
                ],
              )),
            ],
          ),
          pw.Divider(height: 20, color: PdfColors.grey300),
          if (value.warrantyDisplayName != null &&
              value.warrantyDisplayName!.isNotEmpty &&
              value.warrantyDisplayName!.toString().toLowerCase() !=
                  "no pro coverage")
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                    width: 110,
                    height: 110,
                    child: pw.Image(assetImage, fit: pw.BoxFit.cover)),
                pw.SizedBox(width: 14),
                pw.Expanded(
                    child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "SKU #: ${value.warrantySkuId}",
                      style: pw.TextStyle(
                        fontSize: SizeSystem.size13,
                        color: PdfColors.grey,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      value.warrantyDisplayName!,
                      maxLines: 2,
                      overflow: pw.TextOverflow.visible,
                      style: pw.TextStyle(
                        fontSize: SizeSystem.size17,
                        fontWeight: pw.FontWeight.bold,
                        // color: PdfColor(34, 34, 34, 1),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Quantity: ${(value.quantity ?? 0.0).toInt()}',
                      style: pw.TextStyle(
                        fontSize: SizeSystem.size16,
                        // color: PdfColor(155, 158, 185, 1)
                      ),
                    ),
                    pw.Row(children: [
                      pw.Text(
                        'Price: \$${value.warrantyPrice!.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: SizeSystem.size16,
                          // color: PdfColor(155, 158, 185, 1),
                        ),
                      ),
                    ])
                  ],
                )),
              ],
            ),
          if (value.warrantyDisplayName != null &&
              value.warrantyDisplayName!.isNotEmpty &&
              value.warrantyDisplayName!.toString().toLowerCase() !=
                  "no pro coverage")
            pw.Divider(height: 20, color: PdfColors.grey300),
          if (value.warrantyDisplayName != null &&
              value.warrantyDisplayName!.isNotEmpty &&
              value.warrantyDisplayName!.toString().toLowerCase() !=
                  "no pro coverage")
            pw.SizedBox(height: 5),
        ]);
  }
}
