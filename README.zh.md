# flutter_svg_cjk_friendly

[日本語](README.md) | [English](README.en.md) | 简体中文 | [한국어](README.ko.md)

让 [flutter_svg](https://pub.dev/packages/flutter_svg)
对中文、日文、韩文 (CJK) 文本友好。

## 问题

flutter_svg 把 CSS 的 font-family **列表** —
`font-family: 'BIZ UDGothic', 'Noto Sans CJK JP', sans-serif`
(matplotlib 等多数工具输出的标准形式) — 当作**单个字面字体名**处理，
连引号和逗号都包含在内。它永远匹配不到真实字体，所有字形都会回退；
CJK 文本渲染成豆腐块 (□)。

## 解决方案

```yaml
# pubspec.yaml (pub.dev 发布前使用 git 引用)
dependencies:
  flutter_svg_cjk_friendly:
    git: https://github.com/aiseed-dev/flutter_svg_cjk_friendly.git
```

```dart
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_cjk_friendly/flutter_svg_cjk_friendly.dart';

SvgPicture.string(cjkFriendlySvg(svg));
// 优先使用你在 pubspec 中捆绑的字体:
SvgPicture.string(cjkFriendlySvg(svg, preferred: ['BIZ UDGothic']));
```

`cjkFriendlySvg` 解析所有 `font-family` (属性形式和 `style:` 形式)，
去除引号，跳过通用字体族，如果列表中有 `preferred` 指定的字体则优先
选用。SVG 的其他部分不做任何改动。

已用真实的日文统计图表 (ecitizen.jp 的人口金字塔) 验证:
修复前 = 豆腐块，修复后 = BIZ UD 完美渲染。
`test/render_test.dart` 中的回归测试锁定了这一结果。

上游维护者难以优先处理的 CJK 特有问题，用小型派生包来解决 —
与 [markdown-cjk-friendly](https://github.com/tats-u/markdown-cjk-friendly)
是同一思路。给上游的功能请求草案在 `docs/upstream-issue.md`。

## 许可证

MIT (测试用字体: BIZ UD、SIL OFL — 见 test/fixtures/OFL.txt)
