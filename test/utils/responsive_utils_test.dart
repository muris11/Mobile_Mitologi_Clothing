import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/utils/responsive_utils.dart';

void main() {
  group('ResponsiveConfig', () {
    testWidgets('getDeviceType returns mobile for narrow screen',
        (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      late DeviceType type;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              type = ResponsiveConfig.getDeviceType(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(type, DeviceType.mobile);
    });

    testWidgets('getDeviceType returns tablet for medium screen',
        (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      late DeviceType type;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              type = ResponsiveConfig.getDeviceType(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(type, DeviceType.tablet);
    });

    testWidgets('getDeviceType returns desktop for wide screen',
        (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1400, 900);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      late DeviceType type;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              type = ResponsiveConfig.getDeviceType(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(type, DeviceType.desktop);
    });

    testWidgets('isMobile returns true for narrow screen', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      late bool isMobile;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isMobile = ResponsiveConfig.isMobile(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(isMobile, true);
    });

    testWidgets('getResponsiveValue returns correct values', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      late String value;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              value = ResponsiveConfig.getResponsiveValue(
                context: context,
                mobile: 'mobile',
                tablet: 'tablet',
                desktop: 'desktop',
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(value, 'mobile');
    });

    testWidgets('getResponsiveValue falls back to tablet for desktop',
        (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1400, 900);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      late String value;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              value = ResponsiveConfig.getResponsiveValue(
                context: context,
                mobile: 'mobile',
                tablet: 'tablet',
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(value, 'tablet');
    });

    testWidgets('getResponsivePadding returns mobile padding', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      late EdgeInsets padding;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              padding = ResponsiveConfig.getResponsivePadding(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(padding, const EdgeInsets.symmetric(horizontal: 16));
    });

    testWidgets('getGridColumnCount returns 2 for mobile', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      late int columns;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              columns = ResponsiveConfig.getGridColumnCount(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(columns, 2);
    });

    testWidgets('getFontSizeMultiplier returns 1.0 for mobile', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      late double multiplier;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              multiplier = ResponsiveConfig.getFontSizeMultiplier(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(multiplier, 1.0);
    });
  });

  group('ResponsiveBuilder', () {
    testWidgets('renders mobile widget for narrow screen', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            mobile: const Text('mobile'),
            tablet: const Text('tablet'),
            desktop: const Text('desktop'),
          ),
        ),
      );

      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('renders tablet widget for medium width', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            mobile: const Text('mobile'),
            tablet: const Text('tablet'),
            desktop: const Text('desktop'),
          ),
        ),
      );

      expect(find.text('tablet'), findsOneWidget);
    });

    testWidgets('falls back to tablet when desktop is null', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1400, 900);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            mobile: const Text('mobile'),
            tablet: const Text('tablet'),
          ),
        ),
      );

      expect(find.text('tablet'), findsOneWidget);
    });
  });

  group('ResponsiveProductGrid', () {
    testWidgets('renders grid with products', (tester) async {
      final products = [
        {'name': 'Product 1'},
        {'name': 'Product 2'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveProductGrid(
              products: products,
              onProductTap: (p) {},
              itemBuilder: (product) => Text(product['name']!),
            ),
          ),
        ),
      );

      expect(find.text('Product 1'), findsOneWidget);
      expect(find.text('Product 2'), findsOneWidget);
    });

    testWidgets('renders empty grid when no products', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveProductGrid(
              products: const [],
              onProductTap: (p) {},
              itemBuilder: (product) => const SizedBox.shrink(),
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
