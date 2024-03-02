import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'lib/appbar/in_session.dart';
import 'lib/appbar/public.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool inSession = false; // Initially not in session / logged out
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    javaScriptEnabled: true,
    clearCache: true,
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
    if (defaultTargetPlatform == TargetPlatform.android) {
      webViewController?.reload();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      webViewController?.getUrl().then((url) {
        webViewController?.loadUrl(urlRequest: URLRequest(url: url));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAppBar = inSession
        ? InSessionAppBar(onRefresh: refreshWebView)
            as PreferredSizeWidget
        : PublicAppBar(onRefresh: refreshWebView) as PreferredSizeWidget;
    return MaterialApp(
        home: Scaffold(
      appBar: currentAppBar,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add a button to toggle the inSession state
            ElevatedButton(
              onPressed: () {
                // Toggle inSession and rebuild the widget with the new state
                setState(() {
                  inSession = !inSession;
                });
              },
              child:
                  Text(inSession ? 'Switch to Public' : 'Switch to In Session'),
            ),
          ],
        ),
      ),
    ));
  }
}
