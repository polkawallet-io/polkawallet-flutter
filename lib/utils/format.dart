import 'dart:math';

import 'package:intl/intl.dart';

class Fmt {
  static String address(String addr) {
    if (addr == null || addr.length == 0) {
      return addr;
    }
    return addr.substring(0, 8) + '...' + addr.substring(addr.length - 8);
  }

  static String balance(String raw) {
    if (raw == null || raw.length == 0) {
      return raw;
    }
    return raw.split('T')[0];
  }

  static String token(int value, int decimals, {fullLength: bool}) {
    NumberFormat f = NumberFormat(
        ",##0.${fullLength == true ? '000#########' : '000'}", "en_US");
    return f.format(value / pow(10, decimals));
  }

  static bool isAddress(String txt) {
    var reg = RegExp(r'^[A-z\d]{47}$');
    return reg.hasMatch(txt);
  }
}
