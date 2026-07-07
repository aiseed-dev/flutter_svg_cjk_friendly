# flutter_svg_cjk_friendly

[日本語](README.md) | English | [繁體中文](README.zh-TW.md) | [한국어](README.ko.md)

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

## Vertical writing

flutter_svg ignores `writing-mode` and renders vertical text
horizontally. This package expands vertical `<text>` elements into a
stack of per-character plain `<text>` elements before rendering:

- Brackets, long vowel marks and dashes are rotated 90°; full stops and
  commas move to the top-right of their cell — a **font-independent**
  approach that doesn't rely on vertical presentation form glyphs
- Runs of 1–2 alphanumerics stay upright (tate-chū-yoko); longer runs
  are rotated
- Built into `cjkFriendlySvg` (standalone: `verticalTextSvg`)
- Limitations: `<text>` with `<tspan>` children and writing-mode
  inherited from a parent element are not handled

This package is **self-sufficient** — it does not depend on upstream
flutter_svg support. If flutter_svg gains native writing-mode support
in the future, the two won't conflict (preprocessed SVG carries no
writing-mode left to handle).

## End of life

When flutter_svg adopts both font-family list resolution and vertical
writing, this package will be retired. A derived package is a bridge
until upstream catches up — a bridge is not needed once crossed. Until
then it works standalone; after retirement the final version keeps
working as-is.

## License

MIT (test fixture fonts: BIZ UD, SIL OFL — see test/fixtures/OFL.txt)
