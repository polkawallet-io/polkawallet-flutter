import 'package:mobx/mobx.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/assets/types/transferData.dart';
import 'package:polka_wallet/store/laminar/types/laminarCurrenciesData.dart';
import 'package:polka_wallet/store/laminar/types/laminarMarginData.dart';
import 'package:polka_wallet/store/laminar/types/laminarSyntheticData.dart';
import 'package:polka_wallet/store/laminar/types/laminarTxSwapData.dart';
import 'package:polka_wallet/utils/format.dart';

part 'laminar.g.dart';

class LaminarStore extends _LaminarStore with _$LaminarStore {
  LaminarStore(AppStore store) : super(store);
}

abstract class _LaminarStore with Store {
  _LaminarStore(this.rootStore);

  final AppStore rootStore;

  final String cacheTxsTransferKey = 'laminar_transfer_txs';
  final String cacheTxsSwapKey = 'laminar_swap_txs';

  @observable
  ObservableList<TransferData> txsTransfer = ObservableList<TransferData>();

  @observable
  ObservableList<LaminarTxSwapData> txsSwap =
      ObservableList<LaminarTxSwapData>();

  @observable
  Map<String, LaminarPriceData> tokenPrices = {};

  @observable
  ObservableMap<String, LaminarSyntheticPoolInfoData> syntheticPoolInfo =
      ObservableMap();

  @observable
  ObservableMap<String, LaminarMarginPoolInfoData> marginPoolInfo =
      ObservableMap();

  @observable
  ObservableMap<String, LaminarMarginTraderInfoData> marginTraderInfo =
      ObservableMap();

  @computed
  List<LaminarSyntheticPoolTokenData> get syntheticTokens {
    List<LaminarSyntheticPoolTokenData> res = [];
    syntheticPoolInfo.keys.forEach((key) {
      final List<LaminarSyntheticPoolTokenData> ls =
          syntheticPoolInfo[key].options.toList();
      ls.retainWhere((e) => e.askSpread != null && e.bidSpread != null);
      res.addAll(ls);
    });
    return res;
  }

  @computed
  List<LaminarMarginPairData> get marginTokens {
    List<LaminarMarginPairData> res = [];
    marginPoolInfo.keys.forEach((key) {
      res.addAll(marginPoolInfo[key].options);
    });
    return res;
  }

  @action
  void setTransferTxs(
    List list, {
    bool reset = false,
    needCache = true,
  }) {
    List transfers = list.map((i) {
      return {
        "block_timestamp": int.parse(i['time'].toString().substring(0, 10)),
        "hash": i['hash'],
        "success": true,
        "from": rootStore.account.currentAddress,
        "to": i['params'][0],
        "token": i['params'][1],
        "amount": Fmt.balance(
            i['params'][2], rootStore.settings.networkState.tokenDecimals),
      };
    }).toList();
    if (reset) {
      txsTransfer = ObservableList.of(transfers
          .map((i) => TransferData.fromJson(Map<String, dynamic>.from(i))));
    } else {
      txsTransfer.addAll(transfers
          .map((i) => TransferData.fromJson(Map<String, dynamic>.from(i))));
    }

    if (needCache && txsTransfer.length > 0) {
      _cacheTxs(list, cacheTxsTransferKey);
    }
  }

  @action
  void setTokenPrices(List prices) {
    final Map<String, LaminarPriceData> res = {};
    prices.forEach((e) {
      res[e['tokenId']] = LaminarPriceData.fromJson(e);
    });
    tokenPrices = res;
  }

  @action
  void setSyntheticPoolInfo(Map info) {
    syntheticPoolInfo
        .addAll({info['poolId']: LaminarSyntheticPoolInfoData.fromJson(info)});
  }

  @action
  void setMarginPoolInfo(Map info) {
    marginPoolInfo
        .addAll({info['poolId']: LaminarMarginPoolInfoData.fromJson(info)});
  }

  @action
  void setMarginTraderInfo(Map info) {
    marginTraderInfo
        .addAll({info['poolId']: LaminarMarginTraderInfoData.fromJson(info)});
  }

  @action
  Future<void> setSwapTxs(List list,
      {bool reset = false, needCache = true}) async {
    final int decimals = rootStore.settings.networkState.tokenDecimals;
    if (reset) {
      txsSwap = ObservableList.of(list.map((i) =>
          LaminarTxSwapData.fromJson(Map<String, dynamic>.from(i), decimals)));
    } else {
      txsSwap.addAll(list.map((i) =>
          LaminarTxSwapData.fromJson(Map<String, dynamic>.from(i), decimals)));
    }

    if (needCache && txsSwap.length > 0) {
      _cacheTxs(list, cacheTxsSwapKey);
    }
  }

  Future<void> _cacheTxs(List list, String cacheKey) async {
    String pubKey = rootStore.account.currentAccount.pubKey;
    List cached =
        await rootStore.localStorage.getAccountCache(pubKey, cacheKey);
    if (cached != null) {
      cached.addAll(list);
    } else {
      cached = list;
    }
    rootStore.localStorage.setAccountCache(pubKey, cacheKey, cached);
  }

  @action
  Future<void> loadAccountCache() async {
    // return if currentAccount not exist
    String pubKey = rootStore.account.currentAccountPubKey;
    if (pubKey == null || pubKey.isEmpty) {
      return;
    }

    List cache = await Future.wait([
      rootStore.localStorage.getAccountCache(pubKey, cacheTxsTransferKey),
    ]);
    if (cache[0] != null) {
      setTransferTxs(List.of(cache[0]), reset: true, needCache: false);
    } else {
      setTransferTxs([], reset: true, needCache: false);
    }
  }

  @action
  Future<void> loadCache() async {
    loadAccountCache();
  }
}
