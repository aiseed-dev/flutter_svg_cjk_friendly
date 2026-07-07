/// flutter_svg を CJK テキストにフレンドリーにする。
///
/// flutter_svg (vector_graphics_compiler) は CSS の font-family リスト
/// (`font-family: 'BIZ UDGothic', 'Noto Sans CJK JP', sans-serif` —
/// matplotlib 等の標準出力形式) をパースせず、引用符・カンマ込みの全体を
/// 1つのファミリー名として扱う。その結果どのフォントにもマッチせず、
/// CJK テキストは豆腐になる (実測: 2026-07, flutter_svg 2.x)。
///
/// 本パッケージは SVG 文字列の font-family を描画前に正規化する:
///
/// ```dart
/// import 'package:flutter_svg_cjk_friendly/flutter_svg_cjk_friendly.dart';
///
/// SvgPicture.string(cjkFriendlySvg(svg));
/// // または登録済みフォントを優先させる:
/// SvgPicture.string(cjkFriendlySvg(svg, preferred: ['BIZ UDGothic']));
/// ```
library;

// CSS の総称ファミリー (単独では実フォントに解決されないので後回しにする)
const _generic = {
  'serif', 'sans-serif', 'monospace', 'cursive', 'fantasy',
  'system-ui', 'ui-serif', 'ui-sans-serif', 'ui-monospace',
};

/// font-family のCSSリストをパースして採用する1ファミリー名を返す。
///
/// [preferred] にあるファミリーがリスト中に存在すればそれを最優先
/// (大文字小文字は無視)。無ければリスト先頭の非総称ファミリー。
String resolveFontFamily(String cssList, {List<String> preferred = const []}) {
  final names = cssList
      .split(',')
      .map((s) => s.trim())
      .map((s) => (s.length >= 2 &&
              (s.startsWith("'") && s.endsWith("'") ||
                  s.startsWith('"') && s.endsWith('"')))
          ? s.substring(1, s.length - 1)
          : s)
      .where((s) => s.isNotEmpty)
      .toList();
  if (names.isEmpty) return cssList;
  final lower = {for (final n in names) n.toLowerCase(): n};
  for (final p in preferred) {
    final hit = lower[p.toLowerCase()];
    if (hit != null) return hit;
  }
  return names.firstWhere((n) => !_generic.contains(n.toLowerCase()),
      orElse: () => names.first);
}

final _familyAttr = RegExp(r'''font-family\s*=\s*("([^"]*)"|'([^']*)')''');
final _familyStyle = RegExp(r'''font-family\s*:\s*([^;"'<>]*(?:'[^']*'|"[^"]*")?[^;"<>]*)''');

/// SVG 文字列中のすべての font-family (属性・style 内とも) を
/// flutter_svg が解決できる単一ファミリー名に正規化する。
String cjkFriendlySvg(String svg, {List<String> preferred = const []}) {
  svg = svg.replaceAllMapped(_familyAttr, (m) {
    final v = m.group(2) ?? m.group(3) ?? '';
    return 'font-family="${resolveFontFamily(v, preferred: preferred)}"';
  });
  svg = svg.replaceAllMapped(_familyStyle, (m) {
    final v = m.group(1) ?? '';
    return 'font-family: ${resolveFontFamily(v.trim(), preferred: preferred)}';
  });
  return svg;
}
