import 'package:encointer_wallet/common/theme.dart';
import 'package:encointer_wallet/page/account/create/createAccountPage.dart';
import 'package:encointer_wallet/page/account/import/importAccountPage.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:encointer_wallet/utils/translations/translations.dart';

class CreateAccountEntryPage extends StatelessWidget {
  static final String route = '/account/entry';

  @override
  Widget build(BuildContext context) {
    final String nctrLogo = 'assets/nctr_logo.svg';
    final String mosaicBackground = 'assets/nctr_mosaic_background.svg';
    final Translations dic = I18n.of(context).translationsForLocale();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SvgPicture.asset(
              mosaicBackground,
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
            ),
            Center(
              child: SvgPicture.asset(
                nctrLogo,
                color: Colors.white,
                width: 210,
                height: 210,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                      key: Key('create-account'),
                      child: Text(I18n.of(context).translationsForLocale().home.create,
                          style: Theme.of(context).textTheme.headline3),
                      onPressed: () {
                        Navigator.pushNamed(context, CreateAccountPage.route);
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${dic.profile.accountHave} ',
                        style: TextStyle(
                          color: encointerLightBlue,
                        ),
                      ),
                      GestureDetector(
                          key: Key('import-account'),
                          child: Text(
                            I18n.of(context).translationsForLocale().profile.import,
                            style: TextStyle(
                              color: encointerLightBlue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          onTap: () => Navigator.pushNamed(context, ImportAccountPage.route)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
