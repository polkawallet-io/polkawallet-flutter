import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:polka_wallet/common/components/accountAdvanceOption.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

Widget makeTestableWidget({Widget child}) {
  return MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(const Locale('en', '')),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  testWidgets('account advanced option widget test',
      (WidgetTester tester) async {
    AccountAdvanceOptionParams params;
    Widget myWidget = AccountAdvanceOption(
      seed: '',
      onChange: (value) {
        params = value;
      },
    );
    await tester.pumpWidget(makeTestableWidget(child: myWidget));

    /// initial state not expanded
    expect(find.text(AccountAdvanceOptionParams.encryptTypeSR), findsNothing);
    expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);

    /// tap to expand it
    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pump();

    /// expanded state
    expect(find.text(AccountAdvanceOptionParams.encryptTypeSR), findsOneWidget);
    expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);

    /// popup picker
    await tester.tap(find.text(AccountAdvanceOptionParams.encryptTypeSR));
    await tester.pumpAndSettle();
    expect(find.text(AccountAdvanceOptionParams.encryptTypeED), findsOneWidget);

    /// select ed25519 and close picker
    await tester.drag(find.byType(CupertinoPicker), Offset(0, -60));
    await tester.pumpAndSettle();
    await tester.tapAt(Offset(120, 120));
    await tester.pumpAndSettle();
    expect(find.text(AccountAdvanceOptionParams.encryptTypeED), findsOneWidget);
    expect(params.type, equals(AccountAdvanceOptionParams.encryptTypeED));
  });
}
