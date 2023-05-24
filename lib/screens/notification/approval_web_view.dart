import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webviewx_plus/webviewx_plus.dart' as wbxp;

class ApprovalWebViewWidget extends StatelessWidget {
  final String url;
  ApprovalWebViewWidget({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton()),
      body: InteractiveViewer(
        minScale: 4,
        maxScale: 10,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: wbxp.WebViewX(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            initialContent: url,
            initialSourceType: wbxp.SourceType.url,
            navigationDelegate: (navigation) {
              if (navigation.content.source.contains('/Reject/') ||
                  navigation.content.source.contains('/Approval/')) {
                Future.delayed(
                  Duration(seconds: 1),
                  () => Navigator.pop(context),
                );
              }
              return wbxp.NavigationDecision.navigate;
            },
          ),
        ),
      ),
    );
  }
}
