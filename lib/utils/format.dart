import 'dart:math';

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

  static String token(int value, int decimals, int decimalFixed) {
    return (value / pow(10, decimals)).toStringAsFixed(decimalFixed);
  }
}
