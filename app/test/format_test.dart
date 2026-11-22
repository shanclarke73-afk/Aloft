import 'package:aloft/util/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a date from another year shows its year', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );
    final now = DateTime(2026, 11, 22, 10);
    expect(formatMonthDay(context, DateTime(2026, 4, 14), now: now), 'Apr 14');
    expect(formatMonthDay(context, DateTime(2025, 4, 14), now: now), 'Apr 14, 2025');
    expect(formatDay(context, DateTime(2026, 11, 22, 8), now: now), 'Today');
    expect(formatDay(context, DateTime(2026, 11, 21, 23), now: now), 'Yesterday');
    expect(formatDay(context, DateTime(2025, 4, 14), now: now), 'Apr 14, 2025');
    expect(formatLongDay(context, DateTime(2026, 11, 20), now: now), 'Fri, Nov 20');
    expect(formatLongDay(context, DateTime(2025, 4, 14), now: now), 'Mon, Apr 14, 2025');
    expect(formatAxisDate(context, DateTime(2026, 4, 14), now: now), 'Apr 14');
    expect(formatAxisDate(context, DateTime(2025, 4, 14), now: now), "Apr '25");
    // New Year: last week is still last year.
    expect(formatDay(context, DateTime(2026, 12, 28), now: DateTime(2027, 1, 3)), 'Dec 28, 2026');
  });
}
