import 'package:encointer_wallet/service/qrScanService.dart';
import 'package:encointer_wallet/store/encointer/types/communities.dart';
import 'package:flutter_test/flutter_test.dart';

class QrScanParseTestCase {
  final String input;
  final QrScanData expectedOutput;
  final String testDescription;

  QrScanParseTestCase(this.input, this.expectedOutput, this.testDescription);
}

void main() {
  QrScanService service = QrScanService();
  List<QrScanParseTestCase> testCases = [
    QrScanParseTestCase(
      "encointer-invoice\nV1.0\nHgTtJusFEn2gmMmB5wmJDnMRXKD6dzqCpNR7a99kkQ7BNvX"
          "\nsqm1v79dF6b\n0.2343\nAubrey",
      QrScanData(
        context: QrScanContext.invoice,
        version: 'v1.0',
        account: 'HgTtJusFEn2gmMmB5wmJDnMRXKD6dzqCpNR7a99kkQ7BNvX',
        cid: CommunityIdentifier.fromFmtString('sqm1v79dF6b'),
        label: 'Aubrey',
        amount: .2343,
      ),
      "Valid invoice data v1.0",
    ),
    QrScanParseTestCase(
      "encointer-contact\nV1.0\nHgTtJusFEn2gmMmB5wmJDnMRXKD6dzqCpNR7a99kkQ7BNvX\nsqm1v79dF6b\n\nAlice",
      QrScanData(
        context: QrScanContext.contact,
        version: 'v1.0',
        account: 'HgTtJusFEn2gmMmB5wmJDnMRXKD6dzqCpNR7a99kkQ7BNvX',
        cid: CommunityIdentifier.fromFmtString('sqm1v79dF6b'),
        label: 'Alice',
        amount: null,
      ),
      "Valid contact data v1.0",
    ),
  ];
  testCases.forEach((testCase) {
    test('Parse QR Data: ${testCase.testDescription}', () {
      final QrScanData actualData = service.parse(testCase.input);

      expect(actualData.context, testCase.expectedOutput.context);
      expect(actualData.account, testCase.expectedOutput.account);
      expect(actualData.amount, testCase.expectedOutput.amount);
      expect(actualData.cid, testCase.expectedOutput.cid);
      expect(actualData.label, testCase.expectedOutput.label);
      expect(actualData.version, testCase.expectedOutput.version);
    });
  });
}
