import 'dart:convert';

import 'package:encointer_wallet/store/encointer/types/communities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommunityIdentifier', () {
    test('toFmtString works', () {
      var cid = CommunityIdentifier([103, 98, 115, 117, 118], [255, 255, 255, 255]);

      expect('gbsuv7YXq9G', cid.toFmtString());
    });

    test('fromFmtString works', () {
      var cid = CommunityIdentifier([103, 98, 115, 117, 118], [255, 255, 255, 255]);

      var cid2 = CommunityIdentifier.fromFmtString("gbsuv7YXq9G");

      expect(cid, cid2);
    });

    test('Object equality works', () {
      // test that we correctly overwrite `==`.

      var cid = CommunityIdentifier([103, 98, 115, 117, 118], [255, 255, 255, 255]);
      var cid2 = CommunityIdentifier([103, 98, 115, 117, 118], [255, 255, 255, 255]);

      expect(cid, cid2);
    });

    test('Object hashCode equality works', () {
      // test that we correctly overwrite `==` and `hashCode` in compatible manner
      // Failed before: #384

      var cid = CommunityIdentifier([103, 98, 115, 117, 118], [255, 255, 255, 255]);
      var cid2 = CommunityIdentifier([103, 98, 115, 117, 118], [255, 255, 255, 255]);

      Map<CommunityIdentifier, String> cidMap = new Map();
      cidMap[cid] = "Hello";

      expect(cidMap[cid2], "Hello");
    });

    test('Json encode returns same value as received by JS', () {
      Map<String, dynamic> orig = {"geohash": "0x73716d3176", "digest": "0xf08c911c"};

      var parsed = CommunityIdentifier.fromJson(orig);

      expect(jsonEncode(parsed), jsonEncode(orig));
    });
  });
}
