import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'appbar/in_session.dart';
import 'appbar/public.dart';
import 'widget/webview.dart';

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
  final GlobalKey<WebViewContainerState> webViewContainerKey =
      GlobalKey<WebViewContainerState>();
  void updateSession(bool value) {
    setState(() {
      inSession = value;
    });
  }

  late WebViewContainer webViewContainer =
      WebViewContainer(updateSession: updateSession);

  void refreshPageCallback() {
    print("refresh button clicked");
    webViewContainerKey.currentState?.refreshWebView();
  }

  @override
  Widget build(BuildContext context) {
    final currentAppBar = inSession
        ? InSessionAppBar(onRefresh: refreshPageCallback) as PreferredSizeWidget
        : PublicAppBar(onRefresh: refreshPageCallback) as PreferredSizeWidget;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: currentAppBar,
        body: Column(children: <Widget>[
          Expanded(child: WebViewContainer(updateSession: updateSession)),
        ]),
      ),
    );
  }
}
