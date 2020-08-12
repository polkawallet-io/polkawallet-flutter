import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/page/asExtension/walletExtensionSignPage.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DAppWrapperPage extends StatefulWidget {
  DAppWrapperPage(this.store);

  static const String route = '/extension/app';

  final AppStore store;

  @override
  _DAppWrapperPageState createState() => _DAppWrapperPageState();
}

class _DAppWrapperPageState extends State<DAppWrapperPage> {
  WebViewController _controller;

  Future<void> _msgHandler(Map msg) async {
    print('api called: $msg');
    switch (msg['msgType']) {
      case 'pub(accounts.list)':
        final List res = widget.store.account.accountList.map((e) {
          return {
            'address': widget.store.account
                        .pubKeyAddressMap[widget.store.settings.endpoint.ss58]
                    [e.pubKey] ??
                e.address,
            'name': e.name,
            'genesisHash': '',
          };
        }).toList();
        return _controller.evaluateJavascript(
            'walletExtension.onAppResponse("${msg['msgType']}", ${jsonEncode(res)})');
      case 'pub(bytes.sign)':
      case 'pub(extrinsic.sign)':
        final signed = await Navigator.of(context)
            .pushNamed(WalletExtensionSignPage.route, arguments: msg);
        if (signed == null) {
          // cancelled
          return _controller.evaluateJavascript(
              'walletExtension.onAppResponse("${msg['msgType']}", null, new Error("Rejected"))');
        }
        return _controller.evaluateJavascript(
            'walletExtension.onAppResponse("${msg['msgType']}", ${jsonEncode(signed)})');
      default:
        print('Unknown message from dapp: ${msg['msgType']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String url = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(title: Text(url), centerTitle: true),
      body: SafeArea(
        child: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            setState(() {
              _controller = webViewController;
            });
          },
          // TODO(iskakaushik): Remove this when collection literals makes it to stable.
          // ignore: prefer_collection_literals
          javascriptChannels: <JavascriptChannel>[
            JavascriptChannel(
              name: 'Extension',
              onMessageReceived: (JavascriptMessage message) {
                print('msg from dapp: ${message.message}');
                compute(jsonDecode, message.message).then((msg) {
                  if (msg['path'] != 'extensionRequest') return;
                  _msgHandler(msg['data']);
                });
              },
            ),
          ].toSet(),
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              print('blocking navigation to $request}');
              return NavigationDecision.prevent;
            }
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
            DefaultAssetBundle.of(context)
                .loadString('lib/js_as_extension/dist/main.js')
                .then((String js) {
              print('js file loaded');
              _controller.evaluateJavascript(js);
            });
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          gestureNavigationEnabled: true,
        ),
      ),
    );
  }
}
