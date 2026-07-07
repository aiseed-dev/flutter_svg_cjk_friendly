# flutter_svg_cjk_friendly

[日本語](README.md) | English | [简体中文](README.zh.md) | [한국어](README.ko.md)

Make [flutter_svg](https://pub.dev/packages/flutter_svg) friendly to
Japanese / Chinese / Korean text.

## The problem

flutter_svg treats a CSS font-family **list** —
`font-family: 'BIZ UDGothic', 'Noto Sans CJK JP', sans-serif`
(the standard form emitted by matplotlib and most tools) — as a **single
literal family name**, quotes and commas included. It never matches a real
font, so every glyph falls back; CJK text renders as tofu.

## The fix

```yaml
# pubspec.yaml (git reference until the pub.dev release)
dependencies:
  flutter_svg_cjk_friendly:
    git: https://github.com/aiseed-dev/flutter_svg_cjk_friendly.git
```

```dart
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_cjk_friendly/flutter_svg_cjk_friendly.dart';

SvgPicture.string(cjkFriendlySvg(svg));
// prefer a font you bundled in pubspec:
SvgPicture.string(cjkFriendlySvg(svg, preferred: ['BIZ UDGothic']));
```

`cjkFriendlySvg` parses every `font-family` (attribute and `style:` form),
unquotes it, skips generic families, and picks your preferred family when
present. Nothing else in the SVG is touched.

Verified with real-world Japanese statistical charts (population pyramids
from ecitizen.jp): before = tofu, after = perfect BIZ UD rendering. The
regression test in `test/render_test.dart` locks this in.

CJK gaps that upstream maintainers can't prioritize, solved as small
derived packages — the same idea as
[markdown-cjk-friendly](https://github.com/tats-u/markdown-cjk-friendly).
An upstream feature request draft lives in `docs/upstream-issue.md`.

## License

MIT (test fixture fonts: BIZ UD, SIL OFL — see test/fixtures/OFL.txt)
