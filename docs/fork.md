# flutter/packages フォークの維持 (縦書き実装)

vector_graphics_compiler 本体への縦書き実装は、上流にマージされなくても
困らない (本パッケージが単独で機能するため) が、**いつでもマージできる
状態を維持する**。上流が要望に応えるとき、あるいは自分たちがフォーク版を
使いたくなったとき、そのまま使えるように。

## 場所

- リポジトリ: `~/dev/flutter-packages` (flutter/packages の sparse clone)
- ブランチ: `vector_graphics_vertical_writing` (main から1コミット)
- 変更: `packages/vector_graphics_compiler` のみ
  - `lib/src/svg/vertical_text.dart` (新規 — セル分解の純粋ロジック)
  - `lib/src/svg/resolver.dart` (visitTextPositionNode + 縦組解決)
  - `test/vertical_text_test.dart` (10テスト)
  - CHANGELOG 1.3.0 エントリ + pubspec version

## 上流への追従 (マージ可能性の維持)

上流が進んだら rebase して全テストを回す:

```bash
cd ~/dev/flutter-packages
git fetch origin main
git rebase origin/main vector_graphics_vertical_writing
cd packages/vector_graphics_compiler
~/development/flutter/bin/flutter pub get
~/development/flutter/bin/flutter test          # 全テスト (339+) が通ること
```

conflict が出ても変更は resolver の1メソッド + 独立ファイルに
閉じているので、AI に「上流の変更に合わせてパッチを当て直して」で足りる。

## フォーク版を実際に使いたいとき

利用側の `pubspec_overrides.yaml` (git 管理外) に:

```yaml
dependency_overrides:
  vector_graphics_compiler:
    path: /home/saki/dev/flutter-packages/packages/vector_graphics_compiler
```

これで flutter_svg が前処理なしで writing-mode を解釈する。
本パッケージ (前処理) と併用しても干渉しない。
