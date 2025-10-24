選択した雑なメモや簡単なコメントを、実験ノート（experiment.md）の構造に従って展開してください。

## 使用方法

### Claude Code
- エディタでテキストを選択後: `/memo.draft-exp`
- ファイル全体を対象: `/memo.draft-exp @filename`

### GitHub Copilot (VS Code)
- エディタでテキストを選択後: `/memo.draft-exp`
- 変数を使用: `${selection}` で選択テキスト、`${file}` でファイル全体

## タスク
以下の雑なメモを、構造化された実験ノートの各セクションに展開してください。

## 入力
選択されたテキスト（簡単なメモ、箇条書き、コメントなど）
- Claude Code: 選択テキストまたは `@filename` で指定されたファイル
- GitHub Copilot: `${selection}` 変数で渡される選択テキスト

## 出力形式
実験ノートの各セクションに対応する内容を生成してください：

1. **目的と仮説**: このメモから実験の目的を推測し、検証すべき仮説を明確化
2. **手法と設定**: 使用するアルゴリズム、モデル、パラメータを整理
3. **入力データ**: データセット名、パスがあれば記載
4. **実行コマンド**: 実行予定のコマンドを推測して記載
5. **期待される結果**: どのようなメトリクスを測定するか
6. **次のステップ**: 実験後に何をすべきかを提案

## 注意事項
- 明確に書かれていない情報は `[TODO: 確認が必要]` とマーク
- 推測した内容は明示的に「推測:」と記載
- パラメータ設定はYAML形式で整理
- 科学的・技術的に正確な用語を使用

## 出力例
```markdown
## 1. Objective & Hypothesis
### Objective
推測: ImageNetデータセットでの分類精度向上

### Hypothesis
学習率を0.001に設定することで、収束が安定すると期待される

## 4. Method & Configuration
### Parameters & Settings
\`\`\`yaml
model:
  type: ResNet50

hyperparameters:
  learning_rate: 0.001
  batch_size: 32
  epochs: [TODO: 確認が必要]
\`\`\`
```
