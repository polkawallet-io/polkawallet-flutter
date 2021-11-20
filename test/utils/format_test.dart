import 'package:flutter_test/flutter_test.dart';
import 'package:encointer_wallet/utils/format.dart';

void main() {
  group('Fmt', () {
    test('formats cid properly', () {
      expect('HKKAHQhLbLy8b84u1UjnHX9Pqk4FXebzKgtqSt8EKsES',
          Fmt.communityIdentifier('0xf26bfaa0feee0968ec0637e1933e64cd1947294d3b667d43b76b3915fc330b53', pad: 46));
    });
  });
}
