import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:polka_wallet/store/app.dart';

class AddressIcon extends StatelessWidget {
  AddressIcon(this.address, {this.size, this.pubKey});
  final String address;
  final String pubKey;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        String rawSvg;
        if (pubKey != null) {
          rawSvg = globalAppStore.account.pubKeyIconsMap[pubKey];
        } else {
          rawSvg = globalAppStore.account.addressIconsMap[address];
        }
        return Container(
          width: size ?? 40,
          height: size ?? 40,
          child: rawSvg == null
              ? Image.asset('assets/images/assets/Assets_nav_0.png')
              : SvgPicture.string(rawSvg),
        );
      },
    );
  }
}
