# Changelog

## 0.2.0

- 縦書き対応: `writing-mode` が縦の `<text>` を、1文字ずつ縦に積んだ
  通常の `<text>` 群へ描画前に展開する (`verticalTextSvg`、
  `cjkFriendlySvg` にも組み込み)。flutter_svg 本体は writing-mode を
  無視するため、前処理で縦書きを実現する
- 約物はフォント非依存の幾何学処理: 括弧・長音・ダッシュは90°回転、
  句読点 (、。，) はマス右上へ配置 (縦書き用字形グリフに頼らない)
- 1〜2文字の英数字は縦中横で正立、3文字以上は回転して組む
- 制限: `<tspan>` 入りテキストと親要素から継承した writing-mode は未対応

## 0.1.0 (2026-07-07)

- `cjkFriendlySvg(svg, preferred:)` — SVG中の全 font-family (属性/style) の
  CSSリストをパースし単一ファミリー名へ正規化。総称ファミリーは後回し、
  preferred 指定でアプリ同梱フォントを優先
- `resolveFontFamily(cssList, preferred:)` 単体でも利用可
- 実チャート (日本語統計グラフ) による描画回帰テスト付き
