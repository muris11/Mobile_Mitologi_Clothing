import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/utils/html_parser.dart';
import 'package:mitologi_clothing_mobile/widgets/cms/html_section_widget.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: child),
    );

void main() {
  group('HtmlSectionWidget', () {
    testWidgets('renders h1 with content', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HtmlSectionWidget(
            section: HtmlSection(type: 'h1', content: 'Judul Utama'),
          ),
        ),
      );

      expect(find.text('Judul Utama'), findsOneWidget);
    });

    testWidgets('renders h2 and divider marker', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HtmlSectionWidget(
            section: HtmlSection(type: 'h2', content: 'Sub Judul'),
          ),
        ),
      );

      expect(find.text('Sub Judul'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders paragraph text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HtmlSectionWidget(
            section: HtmlSection(type: 'p', content: 'Isi paragraf'),
          ),
        ),
      );

      expect(find.text('Isi paragraf'), findsOneWidget);
    });

    testWidgets('renders ordered list with numeric markers', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HtmlSectionWidget(
            section: HtmlSection(
              type: 'list',
              content: '',
              items: ['Langkah satu', 'Langkah dua'],
              ordered: true,
            ),
          ),
        ),
      );

      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
      expect(find.text('Langkah satu'), findsOneWidget);
      expect(find.text('Langkah dua'), findsOneWidget);
    });

    testWidgets('renders unordered list with bullet markers', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HtmlSectionWidget(
            section: HtmlSection(
              type: 'list',
              content: '',
              items: ['Poin A', 'Poin B'],
              ordered: false,
            ),
          ),
        ),
      );

      expect(find.text('•'), findsNWidgets(2));
      expect(find.text('Poin A'), findsOneWidget);
      expect(find.text('Poin B'), findsOneWidget);
    });
  });
}
