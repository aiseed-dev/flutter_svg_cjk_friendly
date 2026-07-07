# flutter_svg_cjk_friendly

[日本語](README.md) | [English](README.en.md) | [简体中文](README.zh.md) | 한국어

[flutter_svg](https://pub.dev/packages/flutter_svg)를
한국어·일본어·중국어 (CJK) 텍스트에 친화적으로 만듭니다.

## 문제

flutter_svg는 CSS의 font-family **목록** —
`font-family: 'BIZ UDGothic', 'Noto Sans CJK JP', sans-serif`
(matplotlib 등 대부분의 도구가 출력하는 표준 형식) — 을 따옴표와 쉼표까지
포함한 **하나의 글꼴 이름**으로 취급합니다. 실제 글꼴과 일치할 수 없으므로
모든 글리프가 폴백되고, CJK 텍스트는 두부 (□) 로 렌더링됩니다.

## 해결

```yaml
# pubspec.yaml (pub.dev 공개 전에는 git 참조로)
dependencies:
  flutter_svg_cjk_friendly:
    git: https://github.com/aiseed-dev/flutter_svg_cjk_friendly.git
```

```dart
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_cjk_friendly/flutter_svg_cjk_friendly.dart';

SvgPicture.string(cjkFriendlySvg(svg));
// pubspec에 번들한 글꼴을 우선시키려면:
SvgPicture.string(cjkFriendlySvg(svg, preferred: ['BIZ UDGothic']));
```

`cjkFriendlySvg`는 모든 `font-family` (속성 형식과 `style:` 형식 모두) 를
파싱해 따옴표를 제거하고, 제네릭 패밀리를 건너뛰고, 목록에 `preferred`
글꼴이 있으면 그것을 선택합니다. SVG의 다른 부분은 건드리지 않습니다.

실제 일본어 통계 차트 (ecitizen.jp의 인구 피라미드) 로 검증했습니다:
적용 전 = 두부, 적용 후 = BIZ UD로 완벽 렌더링.
`test/render_test.dart`의 회귀 테스트가 이 결과를 고정합니다.

업스트림 관리자가 우선순위를 두기 어려운 CJK 고유 문제를 작은 파생
패키지로 해결하는 시도 —
[markdown-cjk-friendly](https://github.com/tats-u/markdown-cjk-friendly)와
같은 발상입니다. 업스트림 기능 요청 초안은 `docs/upstream-issue.md`에
있습니다.

## 라이선스

MIT (테스트용 글꼴: BIZ UD, SIL OFL — test/fixtures/OFL.txt 참조)
