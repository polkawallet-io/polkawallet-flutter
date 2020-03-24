import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:intl/intl.dart';
import 'package:polka_wallet/store/staking.dart';

class Fmt {
  static String passwordToEncryptKey(String password) {
    String passHex = hex.encode(utf8.encode(password));
    if (passHex.length > 32) {
      return passHex.substring(0, 32);
    }
    return passHex.padRight(32, '0');
  }

  static String address(String addr, {int pad = 8}) {
    if (addr == null || addr.length == 0) {
      return addr;
    }
    return addr.substring(0, pad) + '...' + addr.substring(addr.length - pad);
  }

  static String balance(String raw, {int decimals = 12}) {
    if (raw == null || raw.length == 0) {
      return raw;
    }
    NumberFormat f = NumberFormat(",##0.000");
    var num = f.parse(raw);
    return f.format(num / pow(10, decimals));
  }

  static int balanceInt(String raw) {
    if (raw == null || raw.length == 0) {
      return 0;
    }
    return NumberFormat(",##0.000").parse(raw).toInt();
  }

  static String token(int value, {int decimals = 12, bool fullLength = false}) {
    NumberFormat f = NumberFormat(
        ",##0.${fullLength == true ? '000#########' : '000'}", "en_US");
    return f.format(value / pow(10, decimals));
  }

  static bool isAddress(String txt) {
    var reg = RegExp(r'^[A-z\d]{47,48}$');
    return reg.hasMatch(txt);
  }

  static bool checkPassword(String pass) {
    var reg = RegExp(r'^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$');
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

  static List<List<String>> filterCandidateList(
      List<List<String>> ls, String filter, Map accIndexMap) {
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
            if (chartValues.length == 3) {
              avg = avg - chartValues[chartValues.length - 3][i];
            }
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
}
