// 縦書き展開の実レンダリング検証: PNG に書き出して視覚確認できるようにする。
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_cjk_friendly/flutter_svg_cjk_friendly.dart';

void main() {
  testWidgets('vertical text renders vertically', (tester) async {
    await tester.runAsync(() async {
      final fontData =
          File('test/fixtures/BIZUDGothic-Regular.ttf').readAsBytesSync();
      final loader = FontLoader('BIZ UDGothic')
        ..addFont(Future.value(ByteData.view(fontData.buffer)));
      await loader.load();

      const svg = '<svg xmlns="http://www.w3.org/2000/svg" '
          'viewBox="0 0 220 360" width="220" height="360">'
          '<rect width="220" height="360" fill="white"/>'
          '<text x="170" y="20" font-size="24" font-family="BIZ UDGothic" '
          'writing-mode="vertical-rl">「重要」なのは、</text>'
          '<text x="130" y="20" font-size="24" font-family="BIZ UDGothic" '
          'writing-mode="vertical-rl">データ12件ー。</text>'
          '<text x="90" y="20" font-size="24" font-family="BIZ UDGothic" '
          'writing-mode="vertical-rl">ABCも回転!?</text>'
          '</svg>';

      final out = cjkFriendlySvg(svg);
      final info = await vg.loadPicture(SvgStringLoader(out), null);
      final image = await info.picture.toImage(220, 360);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      File('test/render_vertical.png')
          .writeAsBytesSync(png!.buffer.asUint8List());
      expect(png.lengthInBytes, greaterThan(3000));
    });
  });
}
