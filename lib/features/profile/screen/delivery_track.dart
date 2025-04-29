import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyWebView extends StatefulWidget {
  final String url;

  const MyWebView({super.key, required this.url});

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) => print("Loading: $url"),
              onPageFinished: (String url) => print("Loaded: $url"),
              onWebResourceError:
                  (WebResourceError error) =>
                      print("Error: ${error.errorCode} - ${error.description}"),
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Tracking Order'),
        border: Border(bottom: BorderSide(color: Colors.transparent)),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _controller.reload(),
        ),
      ),
      child: WebViewWidget(controller: _controller),
    );
  }
}
