import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/utils/i18n/index.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AnnouncePageParams {
  AnnouncePageParams({this.title, this.link});
  final String title;
  final String link;
}

class AnnouncementPage extends StatelessWidget {
  static final String route = '/announce';

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).home;
    final AnnouncePageParams params = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(title: Text(dic['announce']), centerTitle: true),
      body: SafeArea(
        child: WebView(
          initialUrl: params.link,
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true,
        ),
      ),
    );
  }
}
