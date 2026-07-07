# 上流 (flutter/packages) への要望文案

投稿先: https://github.com/flutter/packages/issues/new (package: flutter_svg / vector_graphics)
投稿はユーザー自身が行う。以下は貼り付け用の英文ドラフト。

---

**Title**: [flutter_svg] Feature request: better support for CJK text in SVG
(font fallback, vertical writing-mode)

**Package**: flutter_svg / vector_graphics_compiler

## Use case

We generate statistical charts (population pyramids, time series) as SVG at
build time with matplotlib (`svg.fonttype='none'`, i.e. real `<text>`
elements) and display them in a Flutter app with flutter_svg. Keeping text
as text (rather than outlining to paths) matters: the compiled
vector_graphics binary is ~7x smaller (11KB vs 78KB for a real-world chart)
and the text stays consistent with the app's UI font.

This works well for Latin text, but Japanese/Chinese/Korean documents hit
CJK-specific gaps that Western content never exercises:

1. **Font fallback for CJK glyphs** — when the `font-family` in the SVG is
   not bundled (or covers only Latin), CJK glyphs render as tofu. A
   documented way to provide a fallback chain (like Flutter's own
   `TextStyle.fontFamilyFallback`) for SVG text would solve most real cases.
2. **Vertical writing (`writing-mode: vertical-rl` / `tb`)** — a standard
   SVG 1.1/2 text feature that is essential for Japanese typography
   (tategaki) and currently ignored.
3. **font-family lists are not parsed (confirmed, minimal repro available)**
   — `font-family: 'BIZ UDGothic', 'Noto Sans CJK JP', sans-serif` (the
   standard CSS form emitted by matplotlib and many tools) is treated as a
   single literal family name including quotes and commas, so it never
   matches a registered font and every glyph falls back (tofu for CJK).
   Rewriting to a single unquoted name renders perfectly. This affects all
   languages but CJK users cannot fall back to a Latin-only default.

## Proposal

Even partial support would help greatly, in this order of value:
fallback chain for SVG text (1) > vertical writing-mode (2) > metrics (3).

## Context

We understand CJK text is unlikely to be a priority for most users; we are
meanwhile building a small companion package that pre-processes SVGs on the
Flutter side (in the spirit of markdown-cjk-friendly). Happy to share test
corpora (real-world Japanese statistical charts) if useful.
