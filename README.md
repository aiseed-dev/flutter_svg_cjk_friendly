# flutter_svg_cjk_friendly

日本語 | [English](README.en.md) | [繁體中文](README.zh-TW.md) | [한국어](README.ko.md)

[flutter_svg](https://pub.dev/packages/flutter_svg) を
日本語・中国語・韓国語 (CJK) フレンドリーにする。

## 問題

flutter_svg は CSS の font-family **リスト** —
`font-family: 'BIZ UDGothic', 'Noto Sans CJK JP', sans-serif`
(matplotlib はじめ多くのツールが出力する標準形) — を、引用符もカンマも
含めた**単一のフォント名**として扱う。実在のフォントに一致しないため
全グリフがフォールバックし、CJK テキストは豆腐 (□) になる。

## 解決

```yaml
# pubspec.yaml (pub.dev 公開までは git 参照で)
dependencies:
  flutter_svg_cjk_friendly:
    git: https://github.com/aiseed-dev/flutter_svg_cjk_friendly.git
```

```dart
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_cjk_friendly/flutter_svg_cjk_friendly.dart';

SvgPicture.string(cjkFriendlySvg(svg));
// pubspec で同梱したフォントを優先させる場合:
SvgPicture.string(cjkFriendlySvg(svg, preferred: ['BIZ UDGothic']));
```

`cjkFriendlySvg` は全ての `font-family` (属性形式と style 形式の両方) を
パースし、引用符を外し、総称ファミリを飛ばし、`preferred` にある
フォントがリストに含まれていればそれを選ぶ。SVG の他の部分には触れない。

実在の日本語統計チャート (ecitizen.jp の人口ピラミッド) で検証済み:
適用前 = 豆腐、適用後 = BIZ UD で完全描画。`test/render_test.dart` の
回帰テストでこの結果を固定している。

本家 (flutter/packages) が優先しにくい CJK 固有の問題を、小さな派生
パッケージで解く試み ([markdown-cjk-friendly](https://github.com/tats-u/markdown-cjk-friendly)
と同じ発想)。上流への要望ドラフトは `docs/upstream-issue.md`。

## 縦書き

flutter_svg は `writing-mode` を無視して縦書きテキストを横書きに
描画してしまう。本パッケージは描画前に、縦書き指定の `<text>` を
「1文字ずつ縦に積んだ通常の `<text>` 群」へ展開する:

- 括弧・長音・ダッシュは90°回転、句読点 (、。) はマス右上へ —
  縦書き用字形グリフに頼らない**フォント非依存**の方式
- 1〜2文字の英数字は縦中横で正立、3文字以上は回転
- `cjkFriendlySvg` に組み込み済み (単体利用は `verticalTextSvg`)
- 制限: `<tspan>` 入りと、親要素から継承した writing-mode は未対応

本パッケージは**単独で完結**する — 上流 (flutter_svg 本体) の対応を
前提にしない。将来 flutter_svg が writing-mode に対応しても干渉しない
(前処理後の SVG には writing-mode が残らないため)。

## ライセンス

MIT (テスト用フォント: BIZ UD、SIL OFL — test/fixtures/OFL.txt)
