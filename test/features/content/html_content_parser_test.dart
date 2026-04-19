import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/utils/html_parser.dart';

void main() {
  group('parseHtmlSections', () {
    test('extracts h1 h2 h3 and paragraph sections', () {
      final sections = parseHtmlSections(
        '<h1>Judul Utama</h1><h2>Sub Judul</h2><h3>Bagian</h3><p>Isi paragraf</p>',
      );

      expect(sections.length, 4);
      expect(sections[0].type, 'h1');
      expect(sections[0].content, 'Judul Utama');
      expect(sections[1].type, 'h2');
      expect(sections[1].content, 'Sub Judul');
      expect(sections[2].type, 'h3');
      expect(sections[2].content, 'Bagian');
      expect(sections[3].type, 'p');
      expect(sections[3].content, 'Isi paragraf');
    });

    test('extracts ordered list as list section', () {
      final sections = parseHtmlSections(
        '<ol><li>Langkah 1</li><li>Langkah 2</li></ol>',
      );

      expect(sections.length, 1);
      expect(sections.first.type, 'list');
      expect(sections.first.ordered, isTrue);
      expect(sections.first.items, ['Langkah 1', 'Langkah 2']);
    });

    test('extracts unordered list as list section', () {
      final sections = parseHtmlSections(
        '<ul><li>Poin A</li><li>Poin B</li></ul>',
      );

      expect(sections.length, 1);
      expect(sections.first.type, 'list');
      expect(sections.first.ordered, isFalse);
      expect(sections.first.items, ['Poin A', 'Poin B']);
    });

    test('handles null and empty content safely', () {
      expect(parseHtmlSections(null), isEmpty);
      expect(parseHtmlSections(''), isEmpty);
      expect(parseHtmlSections('   '), isEmpty);
      expect(parseHtmlSections('<p>   </p>'), isEmpty);
    });

    test('handles nested tags and nested list text', () {
      final sections = parseHtmlSections(
        '<p><strong>Tebal</strong> normal</p><ul><li>Item <ul><li>Nested</li></ul></li></ul>',
      );

      expect(sections.length, 2);
      expect(sections[0].type, 'p');
      expect(sections[0].content, 'Tebal normal');
      expect(sections[1].type, 'list');
      expect(sections[1].items.first, contains('Item'));
    });
  });
}
