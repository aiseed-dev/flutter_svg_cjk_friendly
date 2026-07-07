// 実チャートSVGのレンダリング回帰: 正規化なし=豆腐(小さいPNG)、
// 正規化あり=日本語描画(PNGが大きくなる) を境界値で固定する。
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_cjk_friendly/flutter_svg_cjk_friendly.dart';

Future<int> renderSize(String svg) async {
  final info = await vg.loadPicture(SvgStringLoader(svg), null);
  final image = await info.picture.toImage(760, 640);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  return png!.lengthInBytes;
}

void main() {
  testWidgets('normalization makes CJK text render', (tester) async {
    await tester.runAsync(() async {
      final fontData =
          File('test/fixtures/BIZUDGothic-Regular.ttf').readAsBytesSync();
      final loader = FontLoader('BIZ UDGothic')
        ..addFont(Future.value(ByteData.view(fontData.buffer)));
      await loader.load();
      final svg = File('test/fixtures/pyramid_none.svg').readAsStringSync();

      final broken = await renderSize(svg);            // 豆腐 (実測 ~9.5KB)
      final fixed = await renderSize(cjkFriendlySvg(svg)); // 正常 (~27KB)
      expect(fixed, greaterThan(broken * 2),
          reason: '正規化後は字形が描かれPNGが大きくなるはず');
    });
  });
}
