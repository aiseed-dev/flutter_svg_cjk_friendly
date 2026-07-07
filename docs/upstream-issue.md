# 上流 (flutter/packages) への要望

投稿先: https://github.com/flutter/packages/issues/new (package: flutter_svg / vector_graphics)
投稿はユーザー自身が行う。以下は貼り付け用の英文。

方針: PR は出さない。**何が欲しいかだけを明確に渡す**。実装の証拠
(検証済みの分解アルゴリズム・テスト・実測) は手元にあり、求められれば
共有するが、要件が本体でコードは参考資料。

---

**Title**: [flutter_svg] Support CJK text: font-family lists and vertical writing-mode

## What we want

1. **`font-family` lists are resolved, not treated as a literal name.**
   `font-family: 'BIZ UDGothic', 'Noto Sans CJK JP', sans-serif` (the form
   matplotlib and most tools emit) should pick the first available family —
   today the whole string, quotes and commas included, is used as one
   family name, so it never matches and CJK text renders as tofu.

2. **`writing-mode: vertical-rl` / `tb` on SVG text renders vertically.**
   Today the parser tracks `writing-mode` through the attribute cascade
   (`_heritableProps`) but the renderer never reads it: vertical text is
   silently drawn horizontally. Acceptance: upright glyphs stacked along
   the block axis; rotational punctuation (brackets, long sound mark,
   dashes) rotated 90°; the ideographic full stop/comma placed at the
   top-right of its cell; short alphanumeric runs upright (tate-chū-yoko).
   It must not depend on the font covering the Unicode vertical
   presentation forms (U+FE10..FE4F) — many fonts, including Google Fonts'
   BIZ UD, lack those glyphs.

## Why

Vertical writing is table stakes for Japanese content (novels, official
documents, education), and Chinese/Korean users hit the same gaps. These
are invisible to Latin-only test corpora, which is why they have survived
so long — but they make flutter_svg unusable for CJK documents without
workarounds.

## Feasibility (verified)

Both are implementable without codec or runtime changes. We validated a
compile-time approach — decomposing vertical text in the resolver into
per-cell horizontal text draws using only existing IR primitives — against
the full vector_graphics_compiler test suite (all green, including tspan
cascading and per-tspan absolute positioning) and end-to-end with rendered
Japanese text. We currently ship the same ideas as a preprocessing package
([flutter_svg_cjk_friendly](https://github.com/aiseed-dev/flutter_svg_cjk_friendly)),
but string preprocessing is the wrong layer; this belongs in the library.
Happy to share the algorithm details, the test cases, and real-world CJK
chart corpora — take whatever implementation shape fits the codebase.
