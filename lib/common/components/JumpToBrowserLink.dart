import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/utils/UI.dart';

class JumpToBrowserLink extends StatelessWidget {
  JumpToBrowserLink(this.url, {this.text, this.mainAxisAlignment});

  final String text;
  final String url;
  final MainAxisAlignment mainAxisAlignment;

  Future<void> _launchUrl(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Container(),
          content: CupertinoActivityIndicator(),
        );
      },
    );
    await UI.launchURL(url);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 4),
            child: Text(
              text ?? url,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          Icon(Icons.open_in_new,
              size: 16, color: Theme.of(context).primaryColor)
        ],
      ),
      onTap: () => _launchUrl(context),
    );
  }
}
