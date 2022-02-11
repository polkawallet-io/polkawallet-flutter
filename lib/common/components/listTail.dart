import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListTail extends StatelessWidget {
  ListTail({this.isEmpty, this.isLoading});
  final bool isLoading;
  final bool isEmpty;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16),
          child: isLoading
              ? CupertinoActivityIndicator()
              : Text(
                  isEmpty
                      ? I18n.of(context).translationsForLocale().home.dataEmpty
                      : I18n.of(context).translationsForLocale().assets.end,
                  style: TextStyle(fontSize: 16, color: Theme.of(context).disabledColor),
                ),
        )
      ],
    );
  }
}
