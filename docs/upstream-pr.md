# flutter/packages への PR 手順 (縦書き対応の実装済みブランチ)

実装は完了し、ローカルの `~/dev/flutter-packages` の
ブランチ **`vector_graphics_vertical_writing`** にコミット済み
(全339テスト通過、うち10件が新規の縦書きテスト)。

## ユーザーがやること

```bash
# 1. GitHub で flutter/packages を自分のアカウントに fork
# 2. fork を remote に追加して push
cd ~/dev/flutter-packages
git remote add fork git@github.com:<あなたのアカウント>/packages.git
git push fork vector_graphics_vertical_writing
# 3. GitHub で PR を作成 (base: flutter/packages main)
#    タイトルと本文は下記を貼り付け
```

CLA (Contributor License Agreement) への署名を求められたら
画面の指示に従って署名する (Google CLA、無料・即時)。

---

## PR タイトル

```
[vector_graphics_compiler] Support SVG vertical writing modes (CJK tategaki)
```

## PR 本文 (貼り付け用)

Fixes the silent drop of SVG vertical text: `writing-mode` is tracked
through the attribute cascade (`_heritableProps` in `parser.dart`) but the
text rendering path never reads it, so vertical (tategaki) text — a
standard SVG 1.1/2 feature essential for Japanese typography — renders
horizontally with no warning.

Flutter's paragraph builder has no vertical text layout, so this change
decomposes vertical text **at compile time** in the resolver into per-cell
horizontal text draws, using only existing IR primitives — **no codec or
runtime changes**, and precompiled `.vec` assets benefit automatically:

- Upright glyphs are stacked along the block axis.
- Characters whose vertical form is a rotation (brackets, dashes, the long
  sound mark) are rotated 90°; the ideographic full stop/comma moves to
  the top-right corner of its cell. This is deliberately font-independent:
  it does not rely on the font covering the Unicode vertical presentation
  forms (U+FE10..FE4F), which many fonts (including Google Fonts' BIZ UD)
  lack — we verified those render as tofu.
- Tate-chū-yoko: runs of 1–2 ASCII alphanumerics stay upright.
- `tspan` attribute cascading works (e.g. mixed font sizes in one column);
  a `tspan` with absolute `x`/`y` starts a new column per SVG semantics.
  `dx`/`dy` falls back to the existing horizontal behavior.

## Motivation

We generate statistical charts as SVG at build time (matplotlib,
`svg.fonttype='none'`) and render them with flutter_svg. Keeping text as
text makes the compiled vector_graphics binary ~7× smaller than outlining
to paths. Vertical writing is table stakes for Japanese content (novels,
official documents, education). We currently ship a string-preprocessing
workaround ([flutter_svg_cjk_friendly](https://github.com/aiseed-dev/flutter_svg_cjk_friendly))
but that is the wrong layer: every consumer pays the cost at runtime, and
`tspan`/inheritance cannot be handled correctly from string preprocessing.

## Tests

10 new tests in `test/vertical_text_test.dart` (stacking, style/`tb`
variants, rotation transforms, corner punctuation, tate-chū-yoko,
text-anchor, tspan cascade, new-column tspan, dx/dy fallback, horizontal
unaffected). All 339 package tests pass. Verified end-to-end with
flutter_svg via a rendered-PNG check using real Japanese text.
