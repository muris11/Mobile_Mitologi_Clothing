import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/utils/animations.dart';

void main() {
  group('AppAnimations', () {
    test('has correct duration constants', () {
      expect(AppAnimations.instant, const Duration(milliseconds: 100));
      expect(AppAnimations.fast, const Duration(milliseconds: 150));
      expect(AppAnimations.quick, const Duration(milliseconds: 200));
      expect(AppAnimations.normal, const Duration(milliseconds: 300));
      expect(AppAnimations.slow, const Duration(milliseconds: 500));
      expect(AppAnimations.entrance, const Duration(milliseconds: 600));
    });

    test('has correct curve constants', () {
      expect(AppAnimations.defaultCurve, Curves.easeOutQuart);
      expect(AppAnimations.bounceCurve, Curves.elasticOut);
      expect(AppAnimations.sharpCurve, Curves.easeOutExpo);
      expect(AppAnimations.entranceCurve, Curves.easeOutQuint);
      expect(AppAnimations.exitCurve, Curves.easeInQuad);
      expect(AppAnimations.microInteractionCurve, Curves.easeOutCubic);
    });
  });

  group('AnimatedPressable', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedPressable(
            child: Container(key: const ValueKey('child')),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('child')), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedPressable(
                onTap: () => tapped = true,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AnimatedPressable));
      await tester.pumpAndSettle();
      expect(tapped, true);
    });

    testWidgets('calls onLongPress when long pressed', (tester) async {
      var longPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedPressable(
                onLongPress: () => longPressed = true,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(AnimatedPressable));
      await tester.pumpAndSettle();
      expect(longPressed, true);
    });

    testWidgets('uses default scaleDown and duration', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedPressable(
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final widget = tester.widget<AnimatedPressable>(find.byType(AnimatedPressable));
      expect(widget.scaleDown, 0.95);
      expect(widget.duration, const Duration(milliseconds: 100));
    });
  });

  group('FadeSlideTransition', () {
    testWidgets('renders child with animation', (tester) async {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 100),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FadeSlideTransition(
            animation: controller,
            child: const Text('hello'),
          ),
        ),
      );

      expect(find.text('hello'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('uses default beginOffset', (tester) async {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 100),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FadeSlideTransition(
            animation: controller,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      final widget = tester.widget<FadeSlideTransition>(find.byType(FadeSlideTransition));
      expect(widget.beginOffset, const Offset(0, 0.1));
      controller.dispose();
    });
  });

  group('ScaleFadeTransition', () {
    testWidgets('renders child with animation', (tester) async {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 100),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ScaleFadeTransition(
            animation: controller,
            child: const Text('hello'),
          ),
        ),
      );

      expect(find.text('hello'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('uses default beginScale', (tester) async {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 100),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ScaleFadeTransition(
            animation: controller,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      final widget = tester.widget<ScaleFadeTransition>(find.byType(ScaleFadeTransition));
      expect(widget.beginScale, 0.8);
      controller.dispose();
    });
  });

  group('StaggeredListBuilder', () {
    testWidgets('renders items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StaggeredListBuilder(
            itemCount: 3,
            itemBuilder: (context, index, animation) => Text('item $index'),
          ),
        ),
      );

      expect(find.text('item 0'), findsOneWidget);
      expect(find.text('item 1'), findsOneWidget);
      expect(find.text('item 2'), findsOneWidget);
      // Wait for all AnimatedItem Future.delayed timers
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('uses default durations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StaggeredListBuilder(
            itemCount: 1,
            itemBuilder: (context, index, animation) => const SizedBox.shrink(),
          ),
        ),
      );

      final widget = tester.widget<StaggeredListBuilder>(find.byType(StaggeredListBuilder));
      expect(widget.staggerDelay, const Duration(milliseconds: 50));
      expect(widget.itemDuration, const Duration(milliseconds: 400));
      // Wait for AnimatedItem Future.delayed timer
      await tester.pump(const Duration(milliseconds: 500));
    });
  });

  group('AnimatedItem', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedItem(
            index: 0,
            staggerDelay: const Duration(milliseconds: 10),
            duration: const Duration(milliseconds: 50),
            child: const Text('animated'),
          ),
        ),
      );

      expect(find.text('animated'), findsOneWidget);
      // Wait for Future.delayed timer to complete
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('ShimmerLoading', () {
    testWidgets('renders child when not loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShimmerLoading(
            isLoading: false,
            child: Text('content'),
          ),
        ),
      );

      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('renders shimmer effect when loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShimmerLoading(
            isLoading: true,
            child: Text('content'),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsOneWidget);
    });
  });

  group('AnimatedPriceTag', () {
    testWidgets('renders price without discount', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedPriceTag(price: 'Rp 100.000'),
        ),
      );

      expect(find.text('Rp 100.000'), findsOneWidget);
    });

    testWidgets('renders discounted price', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnimatedPriceTag(
            price: 'Rp 100.000',
            hasDiscount: true,
            discountPrice: 'Rp 80.000',
          ),
        ),
      );

      expect(find.text('Rp 100.000'), findsOneWidget);
      expect(find.text('Rp 80.000'), findsOneWidget);
    });
  });

  group('AddToCartAnimation', () {
    testWidgets('renders child and calls onComplete', (tester) async {
      var completed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: AddToCartAnimation(
            onComplete: () => completed = true,
            child: const Text('added'),
          ),
        ),
      );

      expect(find.text('added'), findsOneWidget);
      // Animation completes after 600ms
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(completed, true);
    });
  });
}
