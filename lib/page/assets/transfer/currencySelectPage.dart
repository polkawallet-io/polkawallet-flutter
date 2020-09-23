import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polka_wallet/common/components/currencyWithIcon.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class CurrencySelectPage extends StatelessWidget {
  static const String route = '/assets/currency';

  @override
  Widget build(BuildContext context) {
    final List currencyIds = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).assets['currency.select']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: currencyIds.map((i) {
            return ListTile(
              title: CurrencyWithIcon(i,
                  textStyle: Theme.of(context).textTheme.headline4),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
              onTap: () {
                Navigator.of(context).pop(i);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
