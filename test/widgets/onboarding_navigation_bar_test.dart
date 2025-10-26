import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree/src/view/widgets/libraries/on_boarding_slider/onboarding_navigation_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnBoardingNavigationBar Widget Tests', () {
    testWidgets(
      'should display navigation bar with no buttons when skipTextButton is null',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: OnBoardingNavigationBar(
                currentPage: 0,
                onSkip: () {},
                headerBackgroundColor: Colors.blue,
                totalPage: 3,
              ),
            ),
          ),
        );

        expect(find.byType(OnBoardingNavigationBar), findsOneWidget);
        expect(find.byType(CupertinoNavigationBar), findsNothing);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'should display navigation bar with skip button when skipTextButton is provided',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: OnBoardingNavigationBar(
                currentPage: 0,
                onSkip: () {},
                headerBackgroundColor: Colors.blue,
                totalPage: 3,
                skipTextButton: const Text('Skip'),
              ),
            ),
          ),
        );

        expect(find.byType(OnBoardingNavigationBar), findsOneWidget);
        expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'should handle skip callback',
      (WidgetTester tester) async {
        bool skipCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: OnBoardingNavigationBar(
                currentPage: 0,
                onSkip: () {
                  skipCalled = true;
                },
                headerBackgroundColor: Colors.blue,
                totalPage: 3,
                skipTextButton: const Text('Skip'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Skip'));
        await tester.pump();
        expect(skipCalled, true);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'should handle skipFunctionOverride when provided',
      (WidgetTester tester) async {
        bool overrideCalled = false;
        bool skipCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: OnBoardingNavigationBar(
                currentPage: 0,
                onSkip: () {
                  skipCalled = true;
                },
                headerBackgroundColor: Colors.blue,
                totalPage: 3,
                skipTextButton: const Text('Skip'),
                skipFunctionOverride: () {
                  overrideCalled = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Skip'));
        await tester.pump();
        expect(overrideCalled, true);
        expect(skipCalled, false);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'should display custom skip button when provided',
      (WidgetTester tester) async {
        const customSkipButton = Text('Custom Skip');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: OnBoardingNavigationBar(
                currentPage: 0,
                onSkip: () {},
                headerBackgroundColor: Colors.blue,
                totalPage: 3,
                skipTextButton: customSkipButton,
              ),
            ),
          ),
        );

        expect(find.text('Custom Skip'), findsOneWidget);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'should display finish button when on last page',
      (WidgetTester tester) async {
        const finishButton = Text('Finish');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: OnBoardingNavigationBar(
                currentPage: 2,
                onSkip: () {},
                headerBackgroundColor: Colors.blue,
                totalPage: 3,
                finishButton: finishButton,
                onFinish: () {},
              ),
            ),
          ),
        );

        expect(find.text('Finish'), findsOneWidget);
        expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'should handle finish callback',
      (WidgetTester tester) async {
        bool finishCalled = false;
        const finishButton = Text('Finish');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: OnBoardingNavigationBar(
                currentPage: 2,
                onSkip: () {},
                headerBackgroundColor: Colors.blue,
                totalPage: 3,
                finishButton: finishButton,
                onFinish: () {
                  finishCalled = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Finish'));
        await tester.pump();
        expect(finishCalled, true);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'should hide navigation bar when on last page without finish button',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: OnBoardingNavigationBar(
                currentPage: 2,
                onSkip: () {},
                headerBackgroundColor: Colors.blue,
                totalPage: 3,
              ),
            ),
          ),
        );

        expect(find.byType(CupertinoNavigationBar), findsNothing);
      },
    );

    testWidgets('should have correct preferred size', (
      WidgetTester tester,
    ) async {
      final navigationBar = OnBoardingNavigationBar(
        currentPage: 0,
        onSkip: () {},
        headerBackgroundColor: Colors.blue,
        totalPage: 3,
      );

      expect(navigationBar.preferredSize, const Size.fromHeight(44));
    });

    testWidgets('should handle shouldFullyObstruct correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: OnBoardingNavigationBar(
              currentPage: 0,
              onSkip: () {},
              headerBackgroundColor: Colors.blue,
              totalPage: 3,
            ),
          ),
        ),
      );

      final navigationBar = tester.widget<OnBoardingNavigationBar>(
        find.byType(OnBoardingNavigationBar),
      );

      expect(
        navigationBar.shouldFullyObstruct(
          tester.element(find.byType(Scaffold)),
        ),
        false,
      );
    });

    testWidgets(
      'should display leading and middle widgets when provided',
      (WidgetTester tester) async {
        const leadingWidget = Text('Leading');
        const middleWidget = Text('Middle');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: OnBoardingNavigationBar(
                currentPage: 0,
                onSkip: () {},
                headerBackgroundColor: Colors.blue,
                totalPage: 3,
                skipTextButton: const Text('Skip'),
                leading: leadingWidget,
                middle: middleWidget,
              ),
            ),
          ),
        );

        expect(find.text('Leading'), findsOneWidget);
        expect(find.text('Middle'), findsOneWidget);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'should not display skip button on middle pages when skipTextButton is null',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: OnBoardingNavigationBar(
                currentPage: 1,
                onSkip: () {},
                headerBackgroundColor: Colors.blue,
                totalPage: 3,
              ),
            ),
          ),
        );

        expect(find.byType(CupertinoNavigationBar), findsNothing);
        expect(find.byType(TextButton), findsNothing);
      },
    );

    testWidgets(
      'should display skip button on all non-last pages when provided',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: OnBoardingNavigationBar(
                currentPage: 1,
                onSkip: () {},
                headerBackgroundColor: Colors.blue,
                totalPage: 3,
                skipTextButton: const Text('Skip'),
              ),
            ),
          ),
        );

        expect(find.byType(CupertinoNavigationBar), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  });
}
