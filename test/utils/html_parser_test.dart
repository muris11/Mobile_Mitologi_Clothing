import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/utils/html_parser.dart';

void main() {
  group('parseHtmlSections', () {
    test('returns empty list for null html', () {
      expect(parseHtmlSections(null), isEmpty);
    });

    test('returns empty list for empty html', () {
      expect(parseHtmlSections(''), isEmpty);
      expect(parseHtmlSections('   '), isEmpty);
    });

    test('parses heading tags', () {
      const html = '<h1>Title</h1><h2>Subtitle</h2><h3>Section</h3>';
      final sections = parseHtmlSections(html);

      expect(sections.length, 3);
      expect(sections[0].type, 'h1');
      expect(sections[0].content, 'Title');
      expect(sections[1].type, 'h2');
      expect(sections[1].content, 'Subtitle');
      expect(sections[2].type, 'h3');
      expect(sections[2].content, 'Section');
    });

    test('parses paragraph tags', () {
      const html = '<p>This is a paragraph.</p>';
      final sections = parseHtmlSections(html);

      expect(sections.length, 1);
      expect(sections[0].type, 'p');
      expect(sections[0].content, 'This is a paragraph.');
    });

    test('parses unordered list', () {
      const html = '<ul><li>Item 1</li><li>Item 2</li></ul>';
      final sections = parseHtmlSections(html);

      expect(sections.length, 1);
      expect(sections[0].type, 'list');
      expect(sections[0].ordered, false);
      expect(sections[0].items, ['Item 1', 'Item 2']);
    });

    test('parses ordered list', () {
      const html = '<ol><li>First</li><li>Second</li></ol>';
      final sections = parseHtmlSections(html);

      expect(sections.length, 1);
      expect(sections[0].type, 'list');
      expect(sections[0].ordered, true);
      expect(sections[0].items, ['First', 'Second']);
    });

    test('strips html tags from content', () {
      const html = '<p>Text with <strong>bold</strong> and <em>italic</em></p>';
      final sections = parseHtmlSections(html);

      expect(sections[0].content, 'Text with bold and italic');
    });

    test('decodes html entities', () {
      const html = '<p>Foo&nbsp;&amp;&nbsp;Bar</p>';
      final sections = parseHtmlSections(html);

      expect(sections[0].content, 'Foo & Bar');
    });

    test('skips empty sections', () {
      const html = '<p></p><h2>  </h2><p>Valid</p>';
      final sections = parseHtmlSections(html);

      expect(sections.length, 1);
      expect(sections[0].content, 'Valid');
    });

    test('skips empty list items', () {
      const html = '<ul><li></li><li>Valid</li></ul>';
      final sections = parseHtmlSections(html);

      expect(sections[0].items, ['Valid']);
    });

    test('handles mixed content', () {
      const html = '''
        <h1>Main Title</h1>
        <p>Introduction paragraph</p>
        <ul><li>Point 1</li><li>Point 2</li></ul>
        <h2>Conclusion</h2>
      ''';
      final sections = parseHtmlSections(html);

      expect(sections.length, 4);
      expect(sections[0].type, 'h1');
      expect(sections[1].type, 'p');
      expect(sections[2].type, 'list');
      expect(sections[3].type, 'h2');
    });

    test('handles case insensitive tags', () {
      const html = '<H1>Title</H1><P>Paragraph</P><UL><LI>Item</LI></UL>';
      final sections = parseHtmlSections(html);

      expect(sections.length, 3);
      expect(sections[0].content, 'Title');
      expect(sections[2].items, ['Item']);
    });

    test('HtmlSection has correct default values', () {
      const section = HtmlSection(type: 'p', content: 'test');
      expect(section.items, isEmpty);
      expect(section.ordered, false);
    });
  });
}
