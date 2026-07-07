# Changelog

## 0.1.0 (2026-07-07)

- `cjkFriendlySvg(svg, preferred:)` — SVG中の全 font-family (属性/style) の
  CSSリストをパースし単一ファミリー名へ正規化。総称ファミリーは後回し、
  preferred 指定でアプリ同梱フォントを優先
- `resolveFontFamily(cssList, preferred:)` 単体でも利用可
- 実チャート (日本語統計グラフ) による描画回帰テスト付き
