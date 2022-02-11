import 'package:encointer_wallet/common/components/passwordInputDialog.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/service/substrateApi/codecApi.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/translations/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'claimQrCode.dart';
import 'confirmAttendeesDialog.dart';

import 'package:encointer_wallet/utils/translations/translations.dart';

Future<void> startMeetup(BuildContext context, AppStore store) async {
  var amount = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ConfirmAttendeesDialog()));
  // amount is `null` if back button pressed in `ConfirmAttendeesDialog`

  if (store.settings.cachedPin.isEmpty) {
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        final Translations dic = I18n.of(context).translationsForLocale();
        return showPasswordInputDialog(
            context,
            store.account.currentAccount,
            Text(dic.home.unlockAccount
                .replaceAll('CURRENT_ACCOUNT_NAME', store.account.currentAccount.name.toString())), (password) {
          store.settings.setPin(password);
        });
      },
    );
  }

  if (amount != null && store.settings.cachedPin.isNotEmpty) {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => ClaimQrCode(
          store,
          title: I18n.of(context).translationsForLocale().encointer.claimQr,
          claim: webApi.encointer
              .signClaimOfAttendance(amount, store.settings.cachedPin)
              .then((claim) => webApi.codec.encodeToBytes(ClaimOfAttendanceJSRegistryName, claim)),
          confirmedParticipantsCount: amount,
        ),
      ),
    );
  }
}
