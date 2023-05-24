import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:gc_customer_app/primitives/color_system.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScannerView extends StatefulWidget {
  final bool fromSearchInv;
  const ScannerView({Key? key, this.fromSearchInv = true}) : super(key: key);

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  StreamSubscription? streamSubscription;

  @override
  void reassemble() {
    super.reassemble();
    controller!.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Barcode Scanner',
            style: TextStyle(
                fontFamily: kRubik,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                fontSize: 15)),
        centerTitle: true,
      ),
      body: QRView(
        key: qrKey,
        onPermissionSet: (p0, p1) {
          print(p0.hasPermissions);
        },
        onQRViewCreated: (controllerC) {
          streamSubscription = controllerC.scannedDataStream.listen((scanData) {
            if (scanData.code != null) {
              // controllerC.pauseCamera();
              controllerC.dispose();
              Navigator.pop(context, scanData.code);
              // showDialog(
              //   context: context,
              //   builder: (context) => CupertinoAlertDialog(
              //     content: Text(widget.fromSearchInv
              //         ? 'Do you want to search \'${scanData.code}\'?'
              //         : 'Do you want to use coupon \'${scanData.code}\'?'),
              //     actions: [
              //       CupertinoDialogAction(
              //         child: Text('Yes'),
              //         isDefaultAction: true,
              //         onPressed: () => Navigator.pop(context, scanData.code),
              //       ),
              //       CupertinoDialogAction(
              //         child: Text('No'),
              //         textStyle: TextStyle(color: ColorSystem.pureRed),
              //         onPressed: () => Navigator.pop(context),
              //       ),
              //     ],
              //   ),
              // ).then((value) {
              //   if (value != null) {

              //   } else {
              //     controllerC.resumeCamera();
              //   }
              // });
            }
          });
        },
      ),
    );
  }
}
