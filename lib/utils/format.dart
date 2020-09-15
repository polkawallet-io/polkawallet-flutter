import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:base58check/base58.dart';
import 'package:base58check/base58check.dart';
import 'package:convert/convert.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/staking/types/validatorData.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class Fmt {
  static String passwordToEncryptKey(String password) {
    String passHex = hex.encode(utf8.encode(password));
    if (passHex.length > 32) {
      return passHex.substring(0, 32);
    }
    return passHex.padRight(32, '0');
  }

  static String address(String addr, {int pad = 6}) {
    if (addr == null || addr.length < pad) {
      return addr;
    }
    return addr.substring(0, pad) + '...' + addr.substring(addr.length - pad);
  }

  static String currencyIdentifier(String cid, {int pad = 8}) {
    List<int> cidBytes = hexToBytes(cid);
    Base58Codec codec = Base58Codec(Base58CheckCodec.BITCOIN_ALPHABET);
    var cidBase58 = codec.encode(cidBytes);
    return address(cidBase58, pad: pad);
  }

  /// number transform 1:
  /// from raw <String> of Api data to <BigInt>
  static BigInt balanceInt(String raw) {
    if (raw == null || raw.length == 0) {
      return BigInt.zero;
    }
    if (raw.contains(',') || raw.contains('.')) {
      return BigInt.from(NumberFormat(",##0.000").parse(raw));
    } else {
      return BigInt.parse(raw);
    }
  }

  /// number transform 2:
  /// from <BigInt> to <double>
  static double bigIntToDouble(BigInt value, {int decimals = 12}) {
    if (value == null) {
      return 0;
    }
    return value / BigInt.from(pow(10, decimals));
  }

  /// number transform 3:
  /// from <double> to <String> in token format of ",##0.000"
  static String doubleFormat(
    double value, {
    int length = 3,
    int round = 0,
  }) {
    if (value == null) {
      return '~';
    }
    value.toStringAsFixed(3);
    NumberFormat f =
        NumberFormat(",##0${length > 0 ? '.' : ''}${'#' * length}", "en_US");
    return f.format(value);
  }

  /// combined number transform 1-3:
  /// from raw <String> to <String> in token format of ",##0.000"
  static String balance(
    String raw, {
    int decimals = 12,
    int length = 3,
  }) {
    if (raw == null || raw.length == 0) {
      return '~';
    }
    return doubleFormat(bigIntToDouble(balanceInt(raw), decimals: decimals),
        length: length);
  }

  /// combined number transform 1-2:
  /// from raw <String> to <double>
  static double balanceDouble(String raw, {int decimals = 12}) {
    return bigIntToDouble(balanceInt(raw), decimals: decimals);
  }

  /// combined number transform 2-3:
  /// from <BigInt> to <String> in token format of ",##0.000"
  static String token(
    BigInt value, {
    int decimals = 12,
    int length = 3,
  }) {
    if (value == null) {
      return '~';
    }
    return doubleFormat(bigIntToDouble(value, decimals: decimals),
        length: length);
  }

  /// number transform 4:
  /// from <String of double> to <BigInt>
  static BigInt tokenInt(String value, {int decimals = 12}) {
    if (value == null) {
      return BigInt.zero;
    }
    double v = 0;
    if (value.contains(',') || value.contains('.')) {
      v = NumberFormat(",##0.${"0" * decimals}").parse(value);
    } else {
      v = double.parse(value);
    }
    return BigInt.from(v * pow(10, decimals));
  }

  /// number transform 5:
  /// from <BigInt> to <String> in price format of ",##0.00"
  /// ceil number of last decimal
  static String priceCeil(
    double value, {
    int decimals = encointer_token_decimals,
    int lengthFixed = 2,
    int lengthMax,
  }) {
    if (value == null) {
      return '~';
    }
    String tailDecimals =
        lengthMax == null ? '' : "#" * (lengthMax - lengthFixed);
    NumberFormat f = NumberFormat(
        ",##0${lengthFixed > 0 ? '.' : ''}${"0" * lengthFixed}$tailDecimals",
        "en_US");
    return f.format(value);
  }

  /// number transform 6:
  /// from <BigInt> to <String> in price format of ",##0.00"
  /// floor number of last decimal
  static String priceFloor(
    double value, {
    int lengthFixed = 2,
    int lengthMax,
  }) {
    if (value == null) {
      return '~';
    }
    String tailDecimals =
        lengthMax == null ? '' : "#" * (lengthMax - lengthFixed);
    NumberFormat f = NumberFormat(
        ",##0${lengthFixed > 0 ? '.' : ''}${"0" * lengthFixed}$tailDecimals",
        "en_US");
    return f.format(value);
  }

  /// number transform 7:
  /// from number to <String> in price format of ",##0.###%"
  static String ratio(dynamic number, {bool needSymbol = true}) {
    NumberFormat f = NumberFormat(",##0.###${needSymbol ? '%' : ''}");
    return f.format(number ?? 0);
  }

  static String priceCeilBigInt(
    BigInt value, {
    int decimals = encointer_token_decimals,
    int lengthFixed = 2,
    int lengthMax,
  }) {
    if (value == null) {
      return '~';
    }
    double price =
        (value / BigInt.from(pow(10, decimals - (lengthMax ?? lengthFixed))))
                .ceil() /
            pow(10, lengthMax ?? lengthFixed);
    return priceCeil(price, lengthFixed: lengthFixed, lengthMax: lengthMax);
  }

  static String priceFloorBigInt(
    BigInt value, {
    int decimals = encointer_token_decimals,
    int lengthFixed = 2,
    int lengthMax,
  }) {
    if (value == null) {
      return '~';
    }
    double price =
        (value / BigInt.from(pow(10, decimals - (lengthMax ?? lengthFixed))))
                .floor() /
            pow(10, lengthMax ?? lengthFixed);
    return priceFloor(price, lengthFixed: lengthFixed, lengthMax: lengthMax);
  }

  static bool isAddress(String txt) {
    var reg = RegExp(r'^[A-z\d]{47,48}$');
    return reg.hasMatch(txt);
  }

  static bool checkPassword(String pass) {
    var reg = RegExp(r'^(?![0-9]+$)(?![a-zA-Z]+$)[\S]{6,20}$');
    return reg.hasMatch(pass);
  }

  static int sortValidatorList(ValidatorData a, ValidatorData b, int sortType) {
    if (a.commission == null || a.commission.isEmpty) {
      return 1;
    }
    double comA = double.parse(a.commission.split('%')[0]);
    double comB = double.parse(b.commission.split('%')[0]);
    var cmpStake = a.total < b.total ? 1 : -1;
    switch (sortType) {
      case 0:
        return a.total != b.total ? cmpStake : comA > comB ? 1 : -1;
      case 1:
        return a.points == b.points ? cmpStake : a.points < b.points ? 1 : -1;
      case 2:
        return comA == comB ? cmpStake : comA > comB ? 1 : -1;
      default:
        return 1;
    }
  }

  static List<ValidatorData> filterValidatorList(
      List<ValidatorData> ls, String filter, Map accIndexMap) {
    ls.retainWhere((i) {
      String value = filter.toLowerCase();
      String accName = '';
      Map accInfo = accIndexMap[i.accountId];
      if (accInfo != null) {
        accName = accInfo['identity']['display'] ?? '';
      }
      return i.accountId.toLowerCase().contains(value) ||
          accName.toLowerCase().contains(value);
    });
    return ls;
  }

  static List<List> filterCandidateList(
      List<List> ls, String filter, Map accIndexMap) {
    ls.retainWhere((i) {
      String value = filter.toLowerCase();
      String accName = '';
      Map accInfo = accIndexMap[i[0]];
      if (accInfo != null) {
        accName = accInfo['identity']['display'] ?? '';
      }
      return i[0].toLowerCase().contains(value) ||
          accName.toLowerCase().contains(value);
    });
    return ls;
  }

  static Map formatRewardsChartData(Map chartData) {
    List<List> formatChart(String chartName, Map data) {
      List<List> values = [];
      List<String> labels = [];
      List chartValues = data[chartName]['chart'];

      chartValues.asMap().forEach((index, ls) {
        if (index == chartValues.length - 1) {
          List average = [];
          List.of(ls).asMap().forEach((i, v) {
            num avg = v - chartValues[chartValues.length - 2][i];
            average.add(avg);
          });
          values.add(average);
        } else {
          values.add(ls);
        }
      });

      List<String>.from(data[chartName]['labels']).asMap().forEach((k, v) {
        if ((k - 2) % 10 == 0) {
          labels.add(v);
        } else {
          labels.add('');
        }
      });
      return [values, labels];
    }

    List<List> rewards = formatChart('rewards', chartData);
    List<List> points = formatChart('points', chartData);
    List<List> stakes = formatChart('stakes', chartData);

    return {
      'rewards': rewards,
      'stakes': stakes,
      'points': points,
    };
  }

  static String blockToTime(int blocks, int blockDuration) {
    int blocksOfMin = 60000 ~/ blockDuration;
    int blocksOfHour = 60 * blocksOfMin;
    int blocksOfDay = 24 * blocksOfHour;

    int day = (blocks / blocksOfDay).floor();
    int hour = (blocks % blocksOfDay / blocksOfHour).floor();
    int min = (blocks % blocksOfHour / blocksOfMin).floor();

    String res = '$min mins';
    if (hour > 0) {
      res = '$hour hrs $res';
    }
    if (day > 0) {
      res = '$day days $res';
    }
    return res;
  }

  static String accountName(BuildContext context, AccountData acc) {
    return '${acc.name ?? ''}${(acc.observation ?? false) ? ' (${I18n.of(context).account['observe']})' : ''}';
  }

  static List<int> hexToBytes(String hex) {
    const String _BYTE_ALPHABET = "0123456789abcdef";

    hex = hex.replaceAll(" ", "");
    hex = hex.replaceAll("0x", "");
    hex = hex.toLowerCase();
    if (hex.length % 2 != 0) hex = "0" + hex;
    Uint8List result = new Uint8List(hex.length ~/ 2);
    for (int i = 0; i < result.length; i++) {
      int value = (_BYTE_ALPHABET.indexOf(hex[i * 2]) << 4) //= byte[0] * 16
          +
          _BYTE_ALPHABET.indexOf(hex[i * 2 + 1]);
      result[i] = value;
    }
    return result;
  }
}
