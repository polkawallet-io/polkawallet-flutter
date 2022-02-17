/// provides functionality and business logic for scanning QR codes in the encointer app
class QrScanService {
  static final String separator = '\n';
  static final int numberOfRowsV1 = 6;

  QrScanData parse(String rawQrString) {
    List<String> data = rawQrString.split(separator);
    String rawContext = 'QrScanContext.${data[0].substring(10)}';
    if (data[1].toLowerCase() == 'v1.0') {
      if (data.length != numberOfRowsV1) {
        throw FormatException('QR scan data illegal number of rows [${data.length}] expected: $numberOfRowsV1');
      }
      return QrScanData(
        context: QrScanContext.values.firstWhere(
          (qrContext) => qrContext.toString() == rawContext,
          orElse: () {
            throw FormatException(
                'QR scan context [${data[0]}] -> [$rawContext] is not supported; supported values are: ${QrScanContext.values}');
          },
        ),
        version: data[1].toLowerCase(),
        account: data[2],
        cid: data[3],
        amount: data[4].trim().isNotEmpty ? double.parse(data[4]) : null,
        label: data[5],
      );
    } else {
      throw FormatException('QR scan data format [${data[1]}] is currently not supported');
    }
  }
}

/// Format of QR-code, (separator: newLine).
/// Values in `[]` are optional and will be empty lines in the QR-code.
///
/// encointer-<context>
/// <QR-version-for-context>
/// <account ss58>
/// [<cid>]
/// [<amount>]
/// [<label>]
///
class QrScanData {
  final QrScanContext context;

  /// version of our format definition
  final String version;

  /// ss58 encoded public key of the account address.
  /// Payment: account of the receiver of the payment;
  /// contact: account to add to contacts;
  final String account;

  /// id of the community as hexadecimal String
  final String cid;

  /// Optional payment amount for the invoice. Will be emp
  final num amount;

  /// name or other identifier for `account`.
  final String label;

  QrScanData({this.context, this.version, this.account, this.cid, this.amount, this.label});
}

/// context identifier e.g. encointer-contact
/// encointer-invoice
/// encointer-claim
enum QrScanContext {
  contact,
  invoice,
  // claim, currently unsupported and might not be merged into this. Let's see.
}
