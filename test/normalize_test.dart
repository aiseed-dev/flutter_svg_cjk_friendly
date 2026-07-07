import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg_cjk_friendly/flutter_svg_cjk_friendly.dart';

void main() {
  group('resolveFontFamily', () {
    test('引用符つきリストの先頭を採用', () {
      expect(resolveFontFamily("'BIZ UDGothic', 'Noto Sans CJK JP', sans-serif"),
          'BIZ UDGothic');
    });
    test('preferred がリスト内にあれば優先 (大文字小文字無視)', () {
      expect(
          resolveFontFamily("'A', 'noto sans cjk jp', serif",
              preferred: ['Noto Sans CJK JP']),
          'noto sans cjk jp');
    });
    test('総称ファミリーだけなら先頭を返す', () {
      expect(resolveFontFamily('sans-serif'), 'sans-serif');
    });
    test('総称を飛ばして実フォントを採用', () {
      expect(resolveFontFamily("serif, 'IPAmj明朝'"), 'IPAmj明朝');
    });
    test('二重引用符とスペース', () {
      expect(resolveFontFamily('  "UD デジタル 教科書体 N-R" , serif '),
          'UD デジタル 教科書体 N-R');
    });
  });

  group('cjkFriendlySvg', () {
    test('style内のfont-familyを正規化', () {
      const svg = '<text style="font-family: \'BIZ UDGothic\', \'DejaVu Sans\', sans-serif; font-size: 10px">あ</text>';
      final out = cjkFriendlySvg(svg);
      expect(out, contains('font-family: BIZ UDGothic;'));
      expect(out, isNot(contains("'")));
    });
    test('属性形式のfont-familyを正規化', () {
      const svg = '<text font-family="\'A B\', serif">あ</text>';
      expect(cjkFriendlySvg(svg), contains('font-family="A B"'));
    });
    test('font-family以外は変更しない', () {
      const svg = '<path d="M0 0L1 1" fill="#fff"/>';
      expect(cjkFriendlySvg(svg), svg);
    });
  });
}
