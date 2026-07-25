// Covers the re-prompt banner shown when a user runs out of time to
// pronounce a word: it should appear/disappear on command, be dismissible
// by an upward swipe, and never require a button tap to go away.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_3_f25_project/widgets/timeout_banner.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('re-prompt banner', () {
    testWidgets('shows the prompt message when visible', (tester) async {
      await tester.pumpWidget(
        wrap(TimeoutBanner(visible: true, onDismiss: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('Please speak louder and try again!'), findsOneWidget);
    });

    testWidgets('does not show an OK/dismiss button', (tester) async {
      await tester.pumpWidget(
        wrap(TimeoutBanner(visible: true, onDismiss: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextButton), findsNothing);
      expect(find.text('OK'), findsNothing);
    });

    testWidgets('is not interactable while hidden', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        wrap(
          TimeoutBanner(visible: false, onDismiss: () => dismissed = true),
        ),
      );
      await tester.pumpAndSettle();

      // hidden banner is slid offscreen, so it can't receive the gesture at all
      await tester.fling(
        find.text('Please speak louder and try again!'),
        const Offset(0, -300),
        800,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(dismissed, isFalse);
    });

    testWidgets('swiping up dismisses the banner', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        wrap(
          TimeoutBanner(visible: true, onDismiss: () => dismissed = true),
        ),
      );
      await tester.pumpAndSettle();

      await tester.fling(find.text('Please speak louder and try again!'), const Offset(0, -300), 800);
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets('swiping down does not dismiss the banner', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        wrap(
          TimeoutBanner(visible: true, onDismiss: () => dismissed = true),
        ),
      );
      await tester.pumpAndSettle();

      await tester.fling(find.text('Please speak louder and try again!'), const Offset(0, 300), 800);
      await tester.pumpAndSettle();

      expect(dismissed, isFalse);
    });

    testWidgets('slides fully offscreen when not visible', (tester) async {
      await tester.pumpWidget(
        wrap(TimeoutBanner(visible: false, onDismiss: () {})),
      );
      await tester.pumpAndSettle();

      final slide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
      expect(slide.offset, const Offset(0, -1.2));
    });
  });
}
