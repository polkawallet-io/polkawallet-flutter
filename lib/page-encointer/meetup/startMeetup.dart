import 'package:encointer_wallet/common/components/passwordInputDialog.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';
import 'package:encointer_wallet/service/substrateApi/codecApi.dart';
import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'claimQrCode.dart';
import 'confirmAttendeesDialog.dart';

Future<void> startMeetup(BuildContext context, AppStore store) async {
  var amount = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ConfirmAttendeesDialog()));
  // amount is `null` if back button pressed in `ConfirmAttendeesDialog`

  if (store.account.cachedPin.isEmpty) {
    await showCupertinoDialog(
      context: context,
      builder: (context) {
        return showPasswordInputDialog(
            context,
            store.account.currentAccount,
            Text(I18n.of(context)
                .home['unlock.account']
                .replaceAll('CURRENT_ACCOUNT_NAME', store.account.currentAccount.name.toString())), (password) {
          store.account.setPin(password);
        });
      },
    );
  }

  if (amount != null && store.account.cachedPin.isNotEmpty) {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => ClaimQrCode(
          store,
          title: I18n.of(context).encointer['claim.qr'],
          claim: webApi.encointer
              .signClaimOfAttendance(amount, store.account.cachedPin)
              .then((claim) => webApi.codec.encodeToBytes(ClaimOfAttendanceJSRegistryName, claim)),
          confirmedParticipantsCount: amount,
        ),
      ),
    );
  }
}
