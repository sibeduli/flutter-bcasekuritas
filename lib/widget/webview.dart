import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebViewContainer extends StatefulWidget {
  final Function(bool) updateSession;
  const WebViewContainer({
    Key? key,
    required this.updateSession,
  }) : super(key: key);
  @override
  WebViewContainerState createState() => WebViewContainerState();
}

class WebViewContainerState extends State<WebViewContainer> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    javaScriptEnabled: true,
    clearCache: true,
    incognito: false,
  );
  PullToRefreshController? pullToRefreshController;
  PullToRefreshSettings pullToRefreshSettings = PullToRefreshSettings(
    color: Colors.blue,
  );
  bool pullToRefreshEnabled = true;

  @override
  void initState() {
    super.initState();
    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: pullToRefreshSettings,
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  void refreshWebView() {
    print("refresh web view called");
    if (defaultTargetPlatform == TargetPlatform.android) {
      webViewController?.reload();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      webViewController?.getUrl().then((url) {
        webViewController?.loadUrl(urlRequest: URLRequest(url: url));
      });
    }
  }

  void loginInjection(String username, String password) async {
    final String jsScript = """
    document.querySelector('#username').value = '$username';
    document.querySelector('#password').value = '$password';
  """;

    await webViewController?.evaluateJavascript(source: jsScript);
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      key: webViewKey,
      initialUrlRequest:
          URLRequest(url: WebUri("https://mobileweb.bcasekuritas.co.id/login")),
      initialSettings: settings,
      pullToRefreshController: pullToRefreshController,
      onWebViewCreated: (InAppWebViewController controller) {
        webViewController = controller;
        String jsSourceCode = '''
              console.log("hello from flutter!");
              ''';
        webViewController
            ?.evaluateJavascript(source: jsSourceCode)
            .then((value) => print("js returned with value: $value"));
      },
      onLoadStop: (controller, url) {
        pullToRefreshController?.endRefreshing();
        if (url != null) {
          print("Loaded URL: ${url.toString()}");
          if (url == WebUri("https://mobileweb.bcasekuritas.co.id/login")) {
            loginInjection(dotenv.get('TEMPORARY_LOGIN_ID'), dotenv.get('TEMPORARY_LOGIN_PASSWORD'));
            setState(() {
              widget.updateSession(false);
            });
          } else {
            setState(() {
              widget.updateSession(true);
            });
          }
        }
      },
      onReceivedError: (controller, request, error) {
        pullToRefreshController?.endRefreshing();
      },
      onProgressChanged: (controller, progress) {
        // print(progress.toString() + " current progress");
        if (progress == 100) {
          pullToRefreshController?.endRefreshing();
        }
      },
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED);
      },
      onConsoleMessage: (controller, consoleMessage) {
        print("Console message: >>${consoleMessage.message}<<");
      },
    );
  }

  // Add other methods like loginInjection if needed
}
