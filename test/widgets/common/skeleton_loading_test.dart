import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/widgets/common/skeleton_loading.dart';

void main() {
  group('Shimmer', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Shimmer(
            child: Text('content'),
          ),
        ),
      );

      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('renders ShaderMask when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Shimmer(
            enabled: true,
            child: Text('content'),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('renders child directly when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Shimmer(
            enabled: false,
            child: Text('content'),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsNothing);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('toggles animation when enabled changes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Shimmer(
            enabled: true,
            child: Text('content'),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Shimmer(
            enabled: false,
            child: Text('content'),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('of returns state when found', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Shimmer(
            child: SizedBox.shrink(),
          ),
        ),
      );

      final element = tester.element(find.byType(SizedBox));
      final state = Shimmer.of(element);
      expect(state, isNotNull);
    });

    testWidgets('of returns null when not found', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox.shrink(),
        ),
      );

      final state = Shimmer.of(tester.element(find.byType(SizedBox)));
      expect(state, isNull);
    });

    testWidgets('default duration is 1800ms', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Shimmer(
            child: SizedBox.shrink(),
          ),
        ),
      );

      final shimmer = tester.widget<Shimmer>(find.byType(Shimmer));
      expect(shimmer.duration, const Duration(milliseconds: 1800));
    });
  });

  group('ShimmerBlock', () {
    testWidgets('renders container with correct dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShimmerBlock(height: 50, width: 100),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 100);
      expect(container.constraints?.maxHeight, 50);
    });

    testWidgets('uses default width of infinity', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShimmerBlock(height: 50),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, double.infinity);
    });

    testWidgets('applies border radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShimmerBlock(height: 50, borderRadius: 12),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });
  });

  group('ProductCardSkeleton', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 200,
            height: 300,
            child: ProductCardSkeleton(),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('ProductGridSkeleton', () {
    testWidgets('renders grid with skeletons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductGridSkeleton(),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(ProductCardSkeleton), findsWidgets);
    });

    testWidgets('renders custom item count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductGridSkeleton(itemCount: 3),
          ),
        ),
      );

      expect(find.byType(ProductCardSkeleton), findsWidgets);
    });
  });

  group('ListItemSkeleton', () {
    testWidgets('renders with avatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ListItemSkeleton(),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(CircleAvatar), findsNothing);
      // Avatar is a container with BoxShape.circle
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasCircle = containers.any(
        (c) => (c.decoration as BoxDecoration?)?.shape == BoxShape.circle,
      );
      expect(hasCircle, true);
    });

    testWidgets('renders without avatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ListItemSkeleton(showAvatar: false),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasCircle = containers.any(
        (c) => (c.decoration as BoxDecoration?)?.shape == BoxShape.circle,
      );
      expect(hasCircle, false);
    });

    testWidgets('uses custom height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ListItemSkeleton(height: 80),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, const EdgeInsets.symmetric(vertical: 8, horizontal: 16));
    });
  });

  group('HeroSkeleton', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HeroSkeleton(),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });
  });

  group('CategoriesSkeleton', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CategoriesSkeleton(),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('ProductDetailSkeleton', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SingleChildScrollView(
            child: ProductDetailSkeleton(),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });
  });

  group('CartItemSkeleton', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CartItemSkeleton(),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });
  });

  group('CartListSkeleton', () {
    testWidgets('renders default items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CartListSkeleton(),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsWidgets);
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(CartItemSkeleton), findsWidgets);
    });

    testWidgets('renders custom item count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 2000,
              child: CartListSkeleton(itemCount: 3),
            ),
          ),
        ),
      );

      expect(find.byType(CartItemSkeleton), findsNWidgets(3));
    });
  });

  group('WishlistGridSkeleton', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                WishlistGridSkeleton(itemCount: 2),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SliverGrid), findsOneWidget);
    });
  });

  group('OrderCardSkeleton', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OrderCardSkeleton(),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });
  });

  group('OrderListSkeleton', () {
    testWidgets('renders default 4 items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OrderListSkeleton(),
          ),
        ),
      );

      expect(find.byType(OrderCardSkeleton), findsNWidgets(4));
    });

    testWidgets('renders custom item count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OrderListSkeleton(itemCount: 2),
          ),
        ),
      );

      expect(find.byType(OrderCardSkeleton), findsNWidgets(2));
    });
  });

  group('ProfileSkeleton', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileSkeleton(),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
    });
  });
}
