import 'package:encointer_wallet/common/components/currencyWithIcon.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommunitySelectPage extends StatelessWidget {
  static const String route = '/assets/community';

  @override
  Widget build(BuildContext context) {
    final List communityIds = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).translationsForLocale().assets.communitySelect),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: communityIds.map((i) {
            return ListTile(
              title: CurrencyWithIcon(i, textStyle: Theme.of(context).textTheme.headline4),
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
