import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/page/asExtension/walletExtensionSignPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
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
  bool _loading = true;

  Future<void> _msgHandler(Map msg) async {
    switch (msg['msgType']) {
      case 'pub(accounts.list)':
        final List<AccountData> ls = widget.store.account.accountList.toList();
        ls.retainWhere((e) => e.encoding['content'][1] == 'sr25519');
        final List res = ls.map((e) {
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
      appBar: AppBar(
          title: Text(
            url,
            style: TextStyle(fontSize: 16),
          ),
          centerTitle: true),
      body: SafeArea(
        child: Stack(
          children: [
            WebView(
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
              onPageFinished: (String url) {
                print('Page finished loading: $url');
                print('Inject extension js code...');
                _controller.evaluateJavascript(webApi.asExtensionJSCode);
                setState(() {
                  _loading = false;
                });
              },
              gestureNavigationEnabled: true,
            ),
            _loading ? Center(child: CupertinoActivityIndicator()) : Container()
          ],
        ),
      ),
    );
  }
}
