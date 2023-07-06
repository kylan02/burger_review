import 'dart:async';
import 'package:burger_review_3/constants.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Store extends StatefulWidget {
  const Store({Key? key}) : super(key: key);

  @override
  _StoreState createState() => _StoreState();
}

class _StoreState extends State<Store> {
  Completer<WebViewController> _controller = Completer<WebViewController>();
  var isLoading = true;
  final _key = UniqueKey();
  late WebViewController webViewController;


  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      WebView(
        initialUrl: 'https://shop.in-n-out.com',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController controller) {
          _controller.complete(controller);
          webViewController = controller;
        },
        key: _key,
        onPageFinished: (finish) {
          setState(
            () {
              isLoading = false;
            },
          );
        },
        onWebResourceError: (error){
          print('webview error');
        },
      ),
      isLoading ? Center( child: CircularProgressIndicator(),)
          : Stack(),
    ]);
  }
}
