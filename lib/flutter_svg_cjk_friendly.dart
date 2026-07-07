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
/// flutter_svg が解決できる単一ファミリー名に正規化し、
/// writing-mode 付きテキストを縦書きに展開する ([verticalTextSvg])。
String cjkFriendlySvg(String svg, {List<String> preferred = const []}) {
  svg = svg.replaceAllMapped(_familyAttr, (m) {
    final v = m.group(2) ?? m.group(3) ?? '';
    return 'font-family="${resolveFontFamily(v, preferred: preferred)}"';
  });
  svg = svg.replaceAllMapped(_familyStyle, (m) {
    final v = m.group(1) ?? '';
    return 'font-family: ${resolveFontFamily(v.trim(), preferred: preferred)}';
  });
  return verticalTextSvg(svg);
}

// ---------------------------------------------------------------------------
// 縦書き (writing-mode) — flutter_svg は writing-mode を無視して横書きに
// してしまうので、描画前に「1文字ずつ縦に積んだ通常の <text> 群」へ展開する。
// ---------------------------------------------------------------------------

// 90°回転で縦書きの形になる文字 (長音・括弧類・ダッシュ等)。
// Unicode の縦書き用字形 (︑﹁ 等) への置換はフォントにグリフが
// 無いと豆腐になるため使わず、フォント非依存の回転で組む。
const _rotatedChars = {
  'ー', '〜', '～', '−', '－', '＝', '…', '‥', '—', '–',
  '「', '」', '『', '』', '(', ')', '（', '）',
  '{', '}', '｛', '｝', '〔', '〕', '【', '】',
  '《', '》', '〈', '〉', '[', ']', '［', '］',
  '：', '；',
};

// マスの右上に寄せる句読点 (縦書きの読点・句点の位置)
const _cornerChars = {'、', '。', '，'};

final _plainText = RegExp(r'<text\b([^>]*)>([^<]*)</text>');
final _wmAttr = RegExp(r'''\s*writing-mode\s*=\s*["']([\w-]+)["']''');
final _wmStyle = RegExp(r'''writing-mode\s*:\s*([\w-]+)\s*;?''');
final _glyphOrient = RegExp(r'''glyph-orientation-vertical\s*:\s*[\w.]+\s*;?''');

bool _isVerticalMode(String? v) =>
    v != null && (v.startsWith('vertical') || v.startsWith('tb'));

double? _attrNum(String attrs, String name) {
  final m = RegExp('$name\\s*=\\s*["\']([-\\d.]+)').firstMatch(attrs);
  return m == null ? null : double.tryParse(m.group(1)!);
}

String _fmt(double v) {
  final s = v.toStringAsFixed(2);
  return s.contains('.')
      ? s.replaceFirst(RegExp(r'\.?0+$'), '')
      : s;
}

String _unescape(String s) => s
    .replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'),
        (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)))
    .replaceAllMapped(RegExp(r'&#(\d+);'),
        (m) => String.fromCharCode(int.parse(m.group(1)!)))
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'")
    .replaceAll('&amp;', '&');

String _escape(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

bool _isAsciiAlnum(String c) {
  final u = c.codeUnitAt(0);
  return (u >= 0x30 && u <= 0x39) ||
      (u >= 0x41 && u <= 0x5A) ||
      (u >= 0x61 && u <= 0x7A);
}

// 縦積みの1セル。[text] が null なら空き (スペース)。
class _Cell {
  _Cell(this.text, this.advance, {this.rotate = false, this.corner = false});
  final String? text;
  final double advance; // em
  final bool rotate;
  final bool corner; // 句読点をマス右上に寄せる
}

List<_Cell> _cells(String content) {
  final cells = <_Cell>[];
  final chars = content.split('');
  var i = 0;
  while (i < chars.length) {
    final c = chars[i];
    if (c == ' ' || c == '\t') {
      cells.add(_Cell(null, 0.5));
      i++;
    } else if (c == '　') {
      cells.add(_Cell(null, 1));
      i++;
    } else if (_isAsciiAlnum(c)) {
      var j = i;
      while (j < chars.length && _isAsciiAlnum(chars[j])) {
        j++;
      }
      final run = content.substring(i, j);
      if (run.length <= 2) {
        cells.add(_Cell(run, 1)); // 縦中横 (正立で1マス)
      } else {
        cells.add(_Cell(run, 0.6 * run.length, rotate: true));
      }
      i = j;
    } else if (_rotatedChars.contains(c)) {
      cells.add(_Cell(c, 1, rotate: true));
      i++;
    } else if (_cornerChars.contains(c)) {
      cells.add(_Cell(c, 1, corner: true));
      i++;
    } else {
      cells.add(_Cell(c, 1));
      i++;
    }
  }
  return cells;
}

/// writing-mode が縦の `<text>` (子要素なし) を、1文字ずつ縦に積んだ
/// `<text>` 群へ展開する。約物は縦書き用字形に置換、長音や3文字以上の
/// 英数字は90°回転、1〜2文字の英数字は縦中横として正立させる。
///
/// 制限: `<tspan>` を含むテキストと、親要素から継承された
/// writing-mode には対応しない (テキスト要素自身への指定のみ)。
String verticalTextSvg(String svg) {
  return svg.replaceAllMapped(_plainText, (m) {
    var attrs = m.group(1)!;
    final wm = _wmAttr.firstMatch(attrs)?.group(1) ??
        _wmStyle.firstMatch(attrs)?.group(1);
    if (!_isVerticalMode(wm)) return m.group(0)!;

    final x = _attrNum(attrs, 'x');
    final y = _attrNum(attrs, 'y');
    if (x == null || y == null) return m.group(0)!;
    final fs = _attrNum(attrs, 'font-size') ??
        (() {
          final s = RegExp(r'font-size\s*:\s*([-\d.]+)').firstMatch(attrs);
          return s == null ? null : double.tryParse(s.group(1)!);
        })() ??
        16;
    final anchorM =
        RegExp(r'''text-anchor\s*[:=]\s*["']?(\w+)''').firstMatch(attrs);
    final anchor = anchorM?.group(1) ?? 'start';

    // 位置・縦書き関連の指定を除いた属性を各セルへ引き継ぐ
    attrs = attrs
        .replaceAll(_wmAttr, '')
        .replaceAllMapped(RegExp(r'''\s*(x|y)\s*=\s*["'][-\d. ]*["']'''),
            (_) => '')
        .replaceAllMapped(
            RegExp(r'''\s*text-anchor\s*=\s*["']\w+["']'''), (_) => '')
        .replaceAllMapped(RegExp(r'style\s*=\s*"([^"]*)"'), (sm) {
      final cleaned = sm
          .group(1)!
          .replaceAll(_wmStyle, '')
          .replaceAll(_glyphOrient, '')
          .replaceAll(RegExp(r'text-anchor\s*:\s*\w+\s*;?'), '')
          .trim();
      return cleaned.isEmpty ? '' : 'style="$cleaned"';
    }).trim();
    final rest = attrs.isEmpty ? '' : ' $attrs';

    final cells = _cells(_unescape(m.group(2)!));
    final total = cells.fold<double>(0, (a, c) => a + c.advance) * fs;
    var top = y;
    if (anchor == 'middle') top = y - total / 2;
    if (anchor == 'end') top = y - total;

    final out = StringBuffer('<g>');
    for (final cell in cells) {
      final h = cell.advance * fs;
      if (cell.text != null) {
        final t = _escape(cell.text!);
        if (cell.rotate) {
          final yc = top + h / 2;
          // 回転後にグリフ中心が (x, yc) に来るようベースラインを補正
          final yb = yc + 0.36 * fs;
          out.write('<text x="${_fmt(x)}" y="${_fmt(yb)}" '
              'text-anchor="middle" '
              'transform="rotate(90 ${_fmt(x)} ${_fmt(yc)})"$rest>$t</text>');
        } else if (cell.corner) {
          // 句読点はマスの右上へ (横書きグリフは左下にインクがあるため)
          out.write('<text x="${_fmt(x + 0.55 * fs)}" '
              'y="${_fmt(top + 0.38 * fs)}" '
              'text-anchor="middle"$rest>$t</text>');
        } else {
          final yb = top + 0.88 * fs; // CJK の標準的なベースライン位置
          out.write('<text x="${_fmt(x)}" y="${_fmt(yb)}" '
              'text-anchor="middle"$rest>$t</text>');
        }
      }
      top += h;
    }
    out.write('</g>');
    return out.toString();
  });
}
