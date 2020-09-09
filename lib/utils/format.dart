import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/account/types/accountData.dart';
import 'package:polka_wallet/store/app.dart';
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
    if (addr == null || addr.length == 0) {
      return addr;
    }
    return addr.substring(0, pad) + '...' + addr.substring(addr.length - pad);
  }

  static String dateTime(DateTime time) {
    if (time == null) {
      return 'date-time';
    }
    return DateFormat('yyyy-MM-dd hh:mm').format(time);
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
  static double bigIntToDouble(BigInt value, int decimals) {
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
    String raw,
    int decimals, {
    int length = 3,
  }) {
    if (raw == null || raw.length == 0) {
      return '~';
    }
    return doubleFormat(bigIntToDouble(balanceInt(raw), decimals),
        length: length);
  }

  /// combined number transform 1-2:
  /// from raw <String> to <double>
  static double balanceDouble(String raw, int decimals) {
    return bigIntToDouble(balanceInt(raw), decimals);
  }

  /// combined number transform 2-3:
  /// from <BigInt> to <String> in token format of ",##0.000"
  static String token(
    BigInt value,
    int decimals, {
    int length = 3,
  }) {
    if (value == null) {
      return '~';
    }
    return doubleFormat(bigIntToDouble(value, decimals), length: length);
  }

  /// number transform 4:
  /// from <String of double> to <BigInt>
  static BigInt tokenInt(String value, int decimals) {
    if (value == null) {
      return BigInt.zero;
    }
    double v = 0;
    try {
      if (value.contains(',') || value.contains('.')) {
        v = NumberFormat(",##0.${"0" * decimals}").parse(value);
      } else {
        v = double.parse(value);
      }
    } catch (err) {
      print('Fmt.tokenInt() error: ${err.toString()}');
    }
    return BigInt.from(v * pow(10, decimals));
  }

  /// number transform 5:
  /// from <BigInt> to <String> in price format of ",##0.00"
  /// ceil number of last decimal
  static String priceCeil(
    double value, {
    int lengthFixed = 2,
    int lengthMax,
  }) {
    if (value == null) {
      return '~';
    }
    final int x = pow(10, lengthMax ?? lengthFixed);
    final double price = (value * x).ceilToDouble() / x;
    final String tailDecimals =
        lengthMax == null ? '' : "#" * (lengthMax - lengthFixed);
    return NumberFormat(
            ",##0${lengthFixed > 0 ? '.' : ''}${"0" * lengthFixed}$tailDecimals",
            "en_US")
        .format(price);
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
    final int x = pow(10, lengthMax ?? lengthFixed);
    final double price = (value * x).floorToDouble() / x;
    final String tailDecimals =
        lengthMax == null ? '' : "#" * (lengthMax - lengthFixed);
    return NumberFormat(
            ",##0${lengthFixed > 0 ? '.' : ''}${"0" * lengthFixed}$tailDecimals",
            "en_US")
        .format(price);
  }

  /// number transform 7:
  /// from number to <String> in price format of ",##0.###%"
  static String ratio(dynamic number, {bool needSymbol = true}) {
    NumberFormat f = NumberFormat(",##0.###${needSymbol ? '%' : ''}");
    return f.format(number ?? 0);
  }

  static String priceCeilBigInt(
    BigInt value,
    int decimals, {
    int lengthFixed = 2,
    int lengthMax,
  }) {
    if (value == null) {
      return '~';
    }
    return priceCeil(Fmt.bigIntToDouble(value, decimals),
        lengthFixed: lengthFixed, lengthMax: lengthMax);
  }

  static String priceFloorBigInt(
    BigInt value,
    int decimals, {
    int lengthFixed = 2,
    int lengthMax,
  }) {
    if (value == null) {
      return '~';
    }
    return priceFloor(Fmt.bigIntToDouble(value, decimals),
        lengthFixed: lengthFixed, lengthMax: lengthMax);
  }

  static bool isAddress(String txt) {
    var reg = RegExp(r'^[A-z\d]{47,48}$');
    return reg.hasMatch(txt);
  }

  static bool isHexString(String hex) {
    var reg = RegExp(r'^[a-f0-9]+$');
    return reg.hasMatch(hex);
  }

  static bool checkPassword(String pass) {
    var reg = RegExp(r'^(?![0-9]+$)(?![a-zA-Z]+$)[\S]{6,20}$');
    return reg.hasMatch(pass);
  }

  static int sortValidatorList(
      Map addressIndexMap, ValidatorData a, ValidatorData b, int sortType) {
    if (a.commission == null || a.commission.isEmpty) {
      return 1;
    }
    if (b.commission == null || b.commission.isEmpty) {
      return -1;
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
      case 3:
        final infoA = addressIndexMap[a.accountId];
        if (infoA != null && infoA['identity'] != null) {
          final List judgements = infoA['identity']['judgements'];
          if (judgements != null && judgements.length > 0) {
            return -1;
          }
        }
        return 1;
      default:
        return -1;
    }
  }

  static List<ValidatorData> filterValidatorList(
      List<ValidatorData> ls, String filter, Map accIndexMap) {
    ls.retainWhere((i) {
      final Map accInfo = accIndexMap[i.accountId];
      final value = filter.trim().toLowerCase();
      return Fmt.accountDisplayNameString(i.accountId, accInfo)
              .toLowerCase()
              .contains(value) ||
          i.accountId.toLowerCase().contains(value);
    });
    return ls;
  }

  static List<List> filterCandidateList(
      List<List> ls, String filter, Map accIndexMap) {
    ls.retainWhere((i) {
      String value = filter.trim().toLowerCase();
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
    if (blocks == null) return '~';

    int blocksOfMin = 60000 ~/ blockDuration;
    int blocksOfHour = 60 * blocksOfMin;
    int blocksOfDay = 24 * blocksOfHour;

    int day = (blocks / blocksOfDay).floor();
    int hour = (blocks % blocksOfDay / blocksOfHour).floor();
    int min = (blocks % blocksOfHour / blocksOfMin).floor();

    String res = '$min mins';

    if (day > 0) {
      res = '$day days $hour hrs';
    } else if (hour > 0) {
      res = '$hour hrs $res';
    }
    return res;
  }

  static String accountName(BuildContext context, AccountData acc) {
    return '${acc.name ?? ''}${(acc.observation ?? false) ? ' (${I18n.of(context).account['observe']})' : ''}';
  }

  static String accountDisplayNameString(String address, Map accInfo) {
    String display = Fmt.address(address, pad: 6);
    if (accInfo != null) {
      if (accInfo['identity']['display'] != null) {
        display = accInfo['identity']['display'];
        if (accInfo['identity']['displayParent'] != null) {
          display = '${accInfo['identity']['displayParent']}/$display';
        }
      } else if (accInfo['accountIndex'] != null) {
        display = accInfo['accountIndex'];
      }
      display = display.toUpperCase();
    }
    return display;
  }

  static String tokenView(String token) {
    String tokenView = token ?? '';
    if (token == acala_stable_coin) {
      tokenView = acala_stable_coin_view;
    }
    if (token == acala_token_ren_btc) {
      tokenView = acala_token_ren_btc_view;
    }
    return tokenView;
  }

  static Widget accountDisplayName(String address, Map accInfo) {
    return Row(
      children: <Widget>[
        accInfo != null && accInfo['identity']['judgements'].length > 0
            ? Container(
                width: 14,
                margin: EdgeInsets.only(right: 4),
                child: Image.asset('assets/images/assets/success.png'),
              )
            : Container(height: 16),
        Expanded(
          child: Text(accountDisplayNameString(address, accInfo)),
        )
      ],
    );
  }

  static String addressOfAccount(AccountData acc, AppStore store) {
    return store.account.pubKeyAddressMap[store.settings.endpoint.ss58]
            [acc.pubKey] ??
        acc.address ??
        '';
  }
}
