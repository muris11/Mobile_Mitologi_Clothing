class HtmlSection {
  final String type;
  final String content;
  final List<String> items;
  final bool ordered;

  const HtmlSection({
    required this.type,
    required this.content,
    this.items = const [],
    this.ordered = false,
  });
}

String _stripTags(String input) {
  return input
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

List<String> _extractListItems(String listHtml) {
  final liRegex = RegExp(r'<li[^>]*>([\s\S]*?)</li>', caseSensitive: false);
  final items = <String>[];

  for (final match in liRegex.allMatches(listHtml)) {
    final value = _stripTags(match.group(1) ?? '');
    if (value.isNotEmpty) {
      items.add(value);
    }
  }

  return items;
}

List<HtmlSection> parseHtmlSections(String? html) {
  if (html == null || html.trim().isEmpty) return const [];

  final sections = <HtmlSection>[];
  final sectionRegex = RegExp(
    r'<(h1|h2|h3|p|ol|ul)[^>]*>([\s\S]*?)</\1>',
    caseSensitive: false,
  );

  for (final match in sectionRegex.allMatches(html)) {
    final rawType = (match.group(1) ?? '').toLowerCase();
    final rawContent = match.group(2) ?? '';

    if (rawType == 'ol' || rawType == 'ul') {
      final items = _extractListItems(rawContent);
      if (items.isEmpty) continue;
      sections.add(
        HtmlSection(
          type: 'list',
          content: '',
          items: items,
          ordered: rawType == 'ol',
        ),
      );
      continue;
    }

    final text = _stripTags(rawContent);
    if (text.isEmpty) continue;

    sections.add(
      HtmlSection(
        type: rawType,
        content: text,
      ),
    );
  }

  return sections;
}
