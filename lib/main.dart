import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'adjust_event_manager.dart';

void main() {
  PlatformInAppWebViewController.debugLoggingSettings.enabled = false;  
  runApp(const MyApp());

  // Config and initialize the Adjust SDK
  AdjustConfig config = new AdjustConfig('YOUR_APP_TOKEN', AdjustEnvironment.sandbox);
  config.logLevel = AdjustLogLevel.verbose;
  Adjust.initSdk(config);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Adjust Flutter – Webview';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        // #docregion add-widget
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                      url: WebUri.uri(Uri.parse(
                          "https://pnetto.neocities.org/web_flutter"))),
                  //initialSettings: settings,

                  onWebViewCreated: (controller) {
                    // this is our Javascript handler that will handle the communication
                    controller.addJavaScriptHandler(
                        handlerName: 'adj_Handler',
                        // read the parameter received from Javascript (args) to determine which Adjust Event to call
                        callback: (args) {
                          AdjustEventManager manager = AdjustEventManager();
                          manager.handleAdjustEvents(args);
                        });
                  },
                ),
              ),
            ],
          ),
        ),
        // #enddocregion add-widget
      ),
    );
  }
}
