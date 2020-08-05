import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/BorderedTitle.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AnnouncePageParams {
  AnnouncePageParams({this.title, this.content});
  final String title;
  final String content;
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
        child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            BorderedTitle(title: params.title ?? ''),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(params.content ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
