import 'package:flutter_svg_cjk_friendly/flutter_svg_cjk_friendly.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('縦書きテキストが1文字ずつ縦に展開される', () {
    const svg = '<svg><text x="100" y="20" font-size="10" '
        'writing-mode="vertical-rl">日本語</text></svg>';
    final out = verticalTextSvg(svg);
    expect(out, contains('<g>'));
    expect('<text'.allMatches(out).length, 3);
    expect(out, contains('y="28.8"')); // 20 + 0.88*10
    expect(out, contains('y="38.8"')); // 2文字目
    expect(out, contains('y="48.8"')); // 3文字目
    expect(out, contains('x="100"'));
    expect(out, contains('text-anchor="middle"'));
    expect(out, isNot(contains('writing-mode')));
  });

  test('括弧は回転、句読点はマス右上に寄る (フォント非依存)', () {
    const svg = '<svg><text x="0" y="0" font-size="10" '
        'style="writing-mode: tb;">「重要」。</text></svg>';
    final out = verticalTextSvg(svg);
    final open = RegExp(r'<text[^>]*>「</text>').firstMatch(out)!.group(0)!;
    expect(open, contains('rotate(90'));
    final maru = RegExp(r'<text[^>]*>。</text>').firstMatch(out)!.group(0)!;
    expect(maru, isNot(contains('rotate')));
    expect(maru, contains('x="5.5"')); // 0 + 0.55*10 (右上へ)
  });

  test('長音は回転、2桁数字は縦中横で正立', () {
    const svg = '<svg><text x="0" y="0" font-size="10" '
        'writing-mode="vertical-rl">データ12件ー</text></svg>';
    final out = verticalTextSvg(svg);
    expect(out, contains('rotate(90')); // ー が回転
    expect(out, contains('>12<')); // 12 は1セルにまとまり回転しない
    final twelve = RegExp(r'<text[^>]*>12</text>').firstMatch(out)!.group(0)!;
    expect(twelve, isNot(contains('rotate')));
  });

  test('3文字以上の英数字は回転して組む', () {
    const svg = '<svg><text x="0" y="0" font-size="10" '
        'writing-mode="vertical-rl">ABC</text></svg>';
    final out = verticalTextSvg(svg);
    expect(out, contains('rotate(90'));
    expect(out, contains('>ABC<'));
  });

  test('text-anchor=middle は列の中心を y に合わせる', () {
    const svg = '<svg><text x="0" y="50" font-size="10" text-anchor="middle" '
        'writing-mode="vertical-rl">あい</text></svg>';
    final out = verticalTextSvg(svg);
    // 全高20、top=40 → 1文字目ベースライン 48.8
    expect(out, contains('y="48.8"'));
    expect(out, contains('y="58.8"'));
  });

  test('横書きテキストと tspan 入りは触らない', () {
    const plain = '<svg><text x="0" y="0">横のまま</text></svg>';
    expect(verticalTextSvg(plain), plain);
    const tspan = '<svg><text x="0" y="0" writing-mode="tb">'
        '<tspan>子要素</tspan></text></svg>';
    expect(verticalTextSvg(tspan), tspan);
  });

  test('cjkFriendlySvg がフォント正規化と縦書き展開を両方行う', () {
    const svg = '<svg><text x="0" y="0" font-size="10" '
        "style=\"font-family: 'BIZ UDGothic', sans-serif; writing-mode: vertical-rl;\">"
        '縦</text></svg>';
    final out = cjkFriendlySvg(svg);
    expect(out, contains('font-family: BIZ UDGothic'));
    expect(out, contains('text-anchor="middle"'));
    expect(out, isNot(contains('writing-mode')));
  });
}
