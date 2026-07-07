# flutter_svg_cjk_friendly

[日本語](README.md) | [English](README.en.md) | 繁體中文 | [한국어](README.ko.md)

讓 [flutter_svg](https://pub.dev/packages/flutter_svg)
對中文、日文、韓文 (CJK) 文字友善。

## 問題

flutter_svg 把 CSS 的 font-family **清單** —
`font-family: 'BIZ UDGothic', 'Noto Sans CJK JP', sans-serif`
(matplotlib 等多數工具輸出的標準形式) — 當成**單一的字面字型名稱**
處理，連引號和逗號都包含在內。它永遠比對不到真實字型，所有字符都會
後備；CJK 文字就算繪成豆腐 (□)。

## 解決方案

```yaml
# pubspec.yaml (pub.dev 發佈前請使用 git 參照)
dependencies:
  flutter_svg_cjk_friendly:
    git: https://github.com/aiseed-dev/flutter_svg_cjk_friendly.git
```

```dart
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_cjk_friendly/flutter_svg_cjk_friendly.dart';

SvgPicture.string(cjkFriendlySvg(svg));
// 優先使用你在 pubspec 中隨附的字型:
SvgPicture.string(cjkFriendlySvg(svg, preferred: ['BIZ UDGothic']));
```

`cjkFriendlySvg` 會剖析所有 `font-family` (屬性形式與 `style:` 形式)、
去除引號、略過通用字型族，若清單中有 `preferred` 指定的字型則優先
選用。SVG 的其他部分完全不動。

已用真實的日文統計圖表 (ecitizen.jp 的人口金字塔) 驗證:
修正前 = 豆腐，修正後 = 以 BIZ UD 完美算繪。
`test/render_test.dart` 的回歸測試鎖定了這個結果。

上游維護者難以優先處理的 CJK 特有問題，用小型衍生套件來解決 —
與 [markdown-cjk-friendly](https://github.com/tats-u/markdown-cjk-friendly)
是同一種想法。給上游的功能請求草稿在 `docs/upstream-issue.md`。

## 直排 (縱書)

flutter_svg 會忽略 `writing-mode`，把直排文字算繪成橫排。
本套件在算繪前把直排的 `<text>` 展開成「一字一個、縱向堆疊的
一般 `<text>`」:

- 括號、長音符、破折號旋轉 90°；句讀點 (、。) 移到格子右上 —
  **不依賴字型**的做法，不需要縱排專用字形
- 1〜2 個英數字直立 (直排內橫排)，3 個以上旋轉排列
- 已內建於 `cjkFriendlySvg` (單獨使用: `verticalTextSvg`)
- 限制: 含 `<tspan>` 的文字與從父元素繼承的 writing-mode 尚未支援

本套件**獨立完備** — 不以上游 (flutter_svg 本體) 的支援為前提。
將來即使 flutter_svg 原生支援 writing-mode 也不會互相干擾
(前處理後的 SVG 已不含 writing-mode)。

## 本套件的退場

當 flutter_svg 同時支援 font-family 清單解析與直排後，本套件就
功成身退。衍生套件是上游跟上之前的橋——過了橋就不再需要橋。
在那之前它獨立運作；退場後最終版本仍可照常使用。

## 授權條款

MIT (測試用字型: BIZ UD、SIL OFL — 見 test/fixtures/OFL.txt)
