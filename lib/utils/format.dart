class Fmt {
  static String address(String addr) {
    if (addr == null || addr.length == 0) {
      return addr;
    }
    return addr.substring(0, 8) + '...' + addr.substring(addr.length - 8);
  }
}
