import 'package:encointer_wallet/store/app.dart';
import 'package:encointer_wallet/store/chain/types/header.dart';
import 'package:encointer_wallet/service/substrateApi/api.dart';

class ChainApi {
  ChainApi(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  final String _timeStampSubscribeChannel = 'timestamp';
  final String _newHeadsSubscribeChannel = 'latestHeader';


  Future<void> startSubscriptions() async {
    print("api: starting encointer subscriptions");
    this.subscribeNewHeads();
  }

  Future<void> stopSubscriptions() async {
    print("api: stopping encointer subscriptions");
    apiRoot.unsubscribeMessage(_newHeadsSubscribeChannel);
  }


  /// Subscribes to the timestamp of the last block. This is only used as a debug method to see if the dart-js interface
  /// is still communicating.
  Future<void> subscribeTimestamp() async {
    apiRoot.subscribeMessage('chain.subscribeTimestamp("$_timeStampSubscribeChannel")', _timeStampSubscribeChannel,
            (data) => {print("timestamp: $data")});
  }

  /// Subscribes to the latest headers
  Future<void> subscribeNewHeads() async {
    apiRoot.subscribeMessage('chain.subscribeNewHeads("$_newHeadsSubscribeChannel")', _newHeadsSubscribeChannel,
            (header) {
          store.chain.setLatestHeader(Header.fromJson(header));
        });
  }
}