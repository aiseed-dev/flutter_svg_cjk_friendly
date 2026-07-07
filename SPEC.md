# flutter_svg_cjk_friendly 仕様書 v0.1 (設計段階)

## 背景と判断 (2026-07-07 ユーザー決定)

- flutter_svg / vector_graphics は Flutter 本体チームの公式管理下 (flutter/packages。
  原作者 Dan Field 氏逝去後に本体チームが継承)。テキスト対応強化のロードマップはない
- SVG テキストの CJK 問題 (フォントフォールバック・縦書き writing-mode・
  和文メトリクス) は欧米ユーザーには存在しない問題で、上流の優先度に乗らない
- → **上流変更を待たず・戦わず、派生パッケージで解く**
  (mdit-py-cjk-friendly と同じ構図。CJK 固有問題は独立実装が最短)

## 形態: フォークではなくコンパニオン

flutter_svg を依存として**ラップ**する (フォーク保守の負債を負わない):

```dart
import 'package:flutter_svg_cjk_friendly/flutter_svg_cjk_friendly.dart';
CjkSvgPicture.string(svg)   // SVG文字列を前処理してから flutter_svg に渡す
```

- 中核は **Dart 製 SVG 前処理器**: `<text>` まわりの CJK 固有問題を
  flutter_svg が確実に描ける形へ正規化
- 上流が将来対応したら前処理を無効化するだけで移行できる (出口コスト最小)

## 対象とする欠陥 (実測ベースで確定させる)

測定手段: matplotlib 製チャート (人口ピラミッド・CPI 等) + 手書きケースの
golden テスト (headless。統計メモ帳の実資産を検証コーパスに使う)。

**確定 #1 (2026-07-07 実測)**: flutter_svg は CSS の font-family リスト
(`'BIZ UDGothic', 'Noto Sans CJK JP', ...` — matplotlib等が出す標準形) を
パースせず、引用符・カンマ込みの文字列全体を1ファミリー名として扱う
→ 何にもマッチせず全テキスト豆腐化。
検証: 実チャートで再現 (statdb_app/test/render_pyramid.png=豆腐)、
font-family を単一名に正規化すると完全な日本語描画
(render_fixed.png=タイトル・年齢階級・凡例・出典まで完璧)。
→ v0.1 の中核 = **font-family 正規化器** (リストをパースし、引用符除去、
登録済み/指定のファミリーを選択)。

候補 (未計測):
2. text-anchor=middle/end の和文での位置ズレ (golden で判定)
3. 縦書き (writing-mode: vertical-rl / tb) 非対応 → transform+1文字tspan分解で再現
4. tspan の相対位置 (dx/dy) の和文メトリクス

## 検証資産

- 統計メモ帳の実チャートSVG群 (text版。vec 7倍軽量の知見は DESIGN §17 に記録済み)
- golden テスト: statdb_app/test/chart_svg_render_test.dart を移植・拡張

## 公開

pub.dev (名前空き確認要)。MIT。mdit-py-cjk-friendly / washi-md と同じ
「日本語の道具は自分たちで作る」ファミリーとして README で相互参照。
