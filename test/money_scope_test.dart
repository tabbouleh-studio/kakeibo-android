import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/models/currency.dart';
import 'package:kakeibo/widgets/money_scope.dart';
import 'package:kakeibo/widgets/money_text.dart';

Widget app({required bool hidden, Currency currency = Currency.kwd}) => MaterialApp(
  home: MoneyScope(
    currency: currency,
    hidden: hidden,
    child: Builder(
      builder: (context) => Column(
        children: [
          const MoneyText(12750),
          Text(context.money(12750)),
          Text('typing ${context.money(12750, mask: false)}'),
        ],
      ),
    ),
  ),
);

void main() {
  testWidgets('amounts show normally', (tester) async {
    await tester.pumpWidget(app(hidden: false));
    // The MoneyText and the plain formatted text.
    expect(find.text('KD 12.750'), findsNWidgets(2));
  });

  testWidgets('privacy mask hides amounts except ones being typed', (tester) async {
    await tester.pumpWidget(app(hidden: true));
    expect(find.text('KD ••••'), findsNWidgets(2));
    expect(find.text('typing KD 12.750'), findsOneWidget);
    expect(find.textContaining('12.750'), findsOneWidget);
  });

  testWidgets('follows the currency', (tester) async {
    await tester.pumpWidget(app(hidden: false, currency: Currency.byCode('USD')));
    expect(find.text('\$ 12.75'), findsNWidgets(2));
  });
}
