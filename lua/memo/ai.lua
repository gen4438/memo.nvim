-- AI integration for memo.nvim
-- Sets up prompt templates for Claude Code and GitHub Copilot

local config = require('memo.config')
local utils = require('memo.utils')

local M = {}

-- Template content for Claude Code slash commands
local claude_templates = {
  ["expand-experiment"] = [[選択した雑なメモや簡単なコメントを、実験ノート（experiment.md）の構造に従って展開してください。

## タスク
以下の雑なメモを、構造化された実験ノートの各セクションに展開してください。

## 入力
選択されたテキスト（簡単なメモ、箇条書き、コメントなど）

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
]],

  ["improve-title"] = [[現在のメモのタイトルを改善し、より検索しやすく意味のあるタイトルを提案してください。

## タスク
メモの内容を分析し、以下の基準で改善されたタイトルを3つ提案してください：

## 評価基準
1. **具体性**: 何についてのメモか一目でわかる
2. **検索性**: 後で検索しやすいキーワードを含む
3. **簡潔性**: 長すぎず、短すぎない（理想は5-10単語）
4. **文脈**: プロジェクト名や技術スタックを含む（該当する場合）

## 入力
- メモの全文（または選択されたテキスト）
- 現在のタイトル（もしあれば）

## 出力形式
以下の形式で3つのタイトル案を提案：

```
【推奨】タイトル案1
理由: なぜこのタイトルが最適か

【代案1】タイトル案2
理由: 別の視点からの提案

【代案2】タイトル案3
理由: さらに別の視点からの提案
```

## 例
```
現在: "実験メモ"

【推奨】ResNet50-ImageNet分類精度改善実験_lr0.001
理由: モデル名、タスク、目的、重要パラメータが含まれており検索性が高い

【代案1】ImageNet分類_ResNet50ハイパーパラメータチューニング
理由: タスクを強調し、何をチューニングしているか明確

【代案2】深層学習_画像分類モデル最適化_2025-10実験
理由: より一般的な用語で、時期も含めて整理
```
]],

  ["organize-memo"] = [[散らかったメモの内容を整理し、構造化された読みやすい形式に変換してください。

## タスク
選択されたメモを以下の方針で整理してください：

## 整理方針
1. **重複の統合**: 同じ内容が複数回書かれている場合は1つにまとめる
2. **論理的な並び替え**: 関連する情報をグループ化し、論理的な順序に並べる
3. **階層構造の追加**: 見出し（#, ##, ###）を使って階層構造を明確に
4. **箇条書きの整理**: 不揃いな箇条書きを統一されたフォーマットに
5. **不明瞭な情報のマーク**: 曖昧な情報は `[要確認]` でマーク
6. **TODO項目の抽出**: アクションアイテムを「次のステップ」セクションに集約

## 入力
整理されていないメモの内容

## 出力形式
構造化されたMarkdown形式のメモ

## 出力例
整理前:
```
resnet50試す。lr=0.001。batch32。
精度上がった。95%くらい？
次はlr変える。0.0001とか。
データ増強も試したい
```

整理後:
```markdown
# ResNet50実験結果

## 実験設定
- モデル: ResNet50
- 学習率: 0.001
- バッチサイズ: 32

## 結果
- 精度: 約95% [要確認: 正確な値を記録]

## 次のステップ
- [ ] 学習率を0.0001に変更して再実験
- [ ] データ増強の適用を検討
```

## 注意事項
- 元の情報は削除しない（重複を除く）
- 推測や補完した情報は明示する
- コードブロックは適切にフォーマット
- テーブルが使える場合は使う
]],

  ["summarize-weekly"] = [[今週作成したメモを分析し、週次レビューレポートを自動生成してください。

## タスク
指定された期間（通常は1週間）のメモファイルを分析し、以下の内容を含む週次レポートを生成してください。

## 入力
- 対象期間のメモファイル一覧（ファイル名と内容）
- デイリーメモ、実験ノート、一般メモなど全て

## 出力形式
以下の構造でMarkdown形式のレポートを生成：

```markdown
# 週次レビュー: YYYY年MM月第N週

## サマリー
今週の主な活動と成果を2-3文で要約

## 主な成果
- 成果1: 具体的な達成内容
- 成果2: ...
- 成果3: ...

## プロジェクト別の進捗
### プロジェクトA
- 実施したこと
- 得られた結果
- 課題

### プロジェクトB
- ...

## 実験まとめ
| 実験ID | タイトル | 主な結果 | ステータス |
|--------|---------|---------|-----------|
| exp001 | ... | ... | ✅ 完了 |
| exp002 | ... | ... | 🔬 進行中 |

## 学んだこと・気づき
- 技術的な学び
- プロセスの改善点
- 新しい知見

## 来週のアクションアイテム
- [ ] タスク1
- [ ] タスク2
- [ ] タスク3

## 未解決の課題
- 課題1: 詳細と対応方針
- 課題2: ...

## メトリクス（該当する場合）
- 作成メモ数: X件
- 実験実施数: Y件
- 完了タスク: Z件
```

## 分析のポイント
- 実験ノートは結果とステータスを重点的に
- デイリーメモからは定性的な気づきを抽出
- プロジェクト横断的な学びを見つける
- 未完了タスクを来週のアクションに引き継ぐ
]],

  ["compare-experiments"] = [[指定された複数の実験ノートを分析し、パラメータと結果を比較するテーブルを生成してください。

## タスク
複数の実験ノートファイルを読み込み、以下の比較分析を実施してください：

1. パラメータ設定の比較テーブル
2. 結果（メトリクス）の比較テーブル
3. 各実験の特徴・違いのサマリー
4. 最良の結果を出した実験の分析
5. 次に試すべきパラメータの提案

## 入力
- 実験ノートファイルのパス（複数）
- または実験ID範囲（例: exp001-exp005）
- またはファイル内容を直接貼り付け

## 出力形式

### 1. パラメータ比較テーブル
```markdown
## パラメータ比較

| 実験ID | モデル | 学習率 | バッチサイズ | エポック数 | その他 |
|--------|-------|--------|------------|-----------|--------|
| exp001 | ResNet50 | 0.001 | 32 | 100 | - |
| exp002 | ResNet50 | 0.0001 | 32 | 100 | データ増強 |
| exp003 | ResNet101 | 0.001 | 64 | 100 | - |
```

### 2. 結果比較テーブル
```markdown
## 結果比較

| 実験ID | Accuracy | Loss | 実行時間 | ステータス | メモ |
|--------|----------|------|---------|-----------|------|
| exp001 | 94.5% | 0.23 | 2h | ✅ 完了 | ベースライン |
| exp002 | 95.2% | 0.19 | 2.5h | ✅ 完了 | 最良 |
| exp003 | 93.8% | 0.25 | 4h | ✅ 完了 | 過学習傾向 |
```

### 3. 分析サマリー
```markdown
## 分析

### 最良の結果
- **実験ID**: exp002
- **精度**: 95.2%
- **特徴**: 学習率を0.0001に下げ、データ増強を適用
- **考察**: 学習率の低減とデータ増強の組み合わせが効果的

### 主な発見
1. 学習率0.0001の方が安定した収束
2. ResNet101は精度向上せず、過学習傾向
3. データ増強は+0.7%の精度向上に寄与

### パラメータの影響
- **学習率**: 大きな影響あり（0.001 → 0.0001で+0.7%）
- **モデル深度**: ResNet50で十分、101は不要
- **バッチサイズ**: 32と64で有意差なし

## 次の実験提案

### 優先度: 高
1. exp002の設定を基に、データ増強の種類を変えて試す
2. 学習率スケジューラの導入を検討

### 優先度: 中
3. Optimizer変更（Adam → SGD with momentum）
4. より大きなバッチサイズ（128）でのテスト
```

## 注意事項
- 欠損データがある場合は「N/A」と記載
- 実験間で測定していないメトリクスは空欄に
- 統計的に有意な差を強調
- 実験の失敗からも学びを抽出
]]
}

-- Template content for VSCode Copilot prompts
local vscode_templates = claude_templates -- 同じ内容を使用

-- GitHub Copilot instructions content
local copilot_instructions = [[# GitHub Copilot Instructions for memo.nvim Project

このプロジェクトは個人用のメモ・実験ノート管理システムです。
以下のガイドラインに従ってコード補完とチャット応答を行ってください。

## プロジェクト構造

### ディレクトリレイアウト
- `general/`: 一般メモ
  - `daily/`, `weekly/`, `monthly/`, `yearly/`: 定期メモ
  - `notes/`: 一般的な雑多なメモ
- `work/`: プロジェクトごとの作業メモ
  - `<project>/experiments/`: 実験ノート
  - `<project>/YYYY/MM/`: 通常のメモ
- `templates/`: テンプレートファイル
- `todo/`: TODOリスト

### ファイル命名規則
- 一般メモ: `YYYY-MM-DD_title.md`
- 実験ノート: `YYYY-MM-DD_expXXX_title.md` (XXXは自動採番ID)
- 定期メモ: `YYYY-MM-DD_daily.md`, `YYYY-wXX_weekly.md` など

## 実験ノートの構造

実験ノート（`work/<project>/experiments/`）は以下の10セクション構造を持ちます：

1. Objective & Hypothesis
2. Environment
3. Input Data
4. Method & Configuration
5. Execution
6. Results
7. Analysis & Discussion
8. Conclusions
9. Next Steps
10. References & Related Work

### パラメータ記述
設定パラメータはYAMLまたはJSON形式で記述してください：

```yaml
model:
  type: ResNet50
  layers: [3, 4, 6, 3]

hyperparameters:
  learning_rate: 0.001
  batch_size: 32
  optimizer: Adam
```

### 結果記述
結果はMarkdownテーブルで整理してください：

```markdown
| Metric | Train | Validation | Test |
|--------|-------|------------|------|
| Accuracy | 98.5% | 95.2% | 94.8% |
| Loss | 0.05 | 0.15 | 0.18 |
```

## コーディングスタイル

### Markdown
- 見出しは ATX形式 (`#`) を使用
- コードブロックは言語指定を含める
- テーブルは整形して見やすく
- 数式はLaTeX記法（`$...$` または `$$...$$`）

### パス記述
- 絶対パスではなく相対パスを使用
- 日本語ファイル名は避ける（ファイルシステム互換性）
- スペースの代わりにアンダースコアを使用

### メモ整理のベストプラクティス
1. 1メモ = 1トピック
2. タイトルは具体的に（検索しやすさ重視）
3. タグは `#keyword` 形式
4. 関連メモへのリンクは相対パス
5. 実験ノートは必ず実験IDを含める

## AI補完時の注意事項

### メモ作成時
- 現在の日付に基づいた適切なファイル名を提案
- プロジェクト名を推測できる場合は含める
- テンプレート構造に従う

### 実験ノート作成時
- 実験IDは自動採番される（exp001, exp002...）
- 科学的・技術的に正確な用語を使用
- 再現性を重視（環境、コマンド、設定を詳細に）
- TODO項目は明示的にマーク

### メモ整理時
- 情報の欠損や曖昧さは `[TODO]` や `[要確認]` でマーク
- 重複情報は統合
- 関連する情報はグループ化
- 階層構造を明確に

### コード補完時
- コードブロックには適切な言語指定
- 実行結果の例も含める
- エラーハンドリングを考慮

## プロジェクト特有の用語

- **実験ノート**: データ分析・機械学習実験の詳細記録
- **実験ID**: プロジェクト内で一意な実験識別子（exp001形式）
- **定期メモ**: daily/weekly/monthly/yearlyの振り返りメモ
- **一般メモ**: プロジェクトに属さない雑多なメモ

## 推奨される対応

### タイトル改善を求められた場合
- 具体性、検索性、簡潔性を考慮
- プロジェクト名や技術キーワードを含める
- 5-10単語程度が理想

### メモ整理を求められた場合
- Markdown記法で構造化
- 見出しと箇条書きを活用
- テーブルで比較を表現

### 実験比較を求められた場合
- パラメータテーブル生成
- 結果テーブル生成
- 統計的な差異を強調
- 次の実験提案を含める

このガイドラインに従って、効率的で一貫性のあるメモ管理をサポートしてください。
]]

-- Setup AI templates in memo directory
function M.setup_ai_templates()
  local cfg = config.get()
  local memo_dir = vim.fn.expand(cfg.memo_dir)

  -- Create .claude/commands directory
  local claude_dir = memo_dir .. "/.claude/commands"
  utils.ensure_dir_exists(claude_dir)

  -- Create .vscode/prompts directory
  local vscode_dir = memo_dir .. "/.vscode/prompts"
  utils.ensure_dir_exists(vscode_dir)

  -- Create .github directory
  local github_dir = memo_dir .. "/.github"
  utils.ensure_dir_exists(github_dir)

  local files_created = 0
  local files_skipped = 0

  -- Write Claude Code templates
  for name, content in pairs(claude_templates) do
    local filepath = claude_dir .. "/" .. name .. ".md"
    if vim.fn.filereadable(filepath) == 0 then
      local file = io.open(filepath, "w")
      if file then
        file:write(content)
        file:close()
        files_created = files_created + 1
      end
    else
      files_skipped = files_skipped + 1
    end
  end

  -- Write VSCode Copilot templates
  for name, content in pairs(vscode_templates) do
    local filepath = vscode_dir .. "/" .. name .. ".md"
    if vim.fn.filereadable(filepath) == 0 then
      local file = io.open(filepath, "w")
      if file then
        file:write(content)
        file:close()
        files_created = files_created + 1
      end
    else
      files_skipped = files_skipped + 1
    end
  end

  -- Write GitHub Copilot instructions
  local copilot_file = github_dir .. "/copilot-instructions.md"
  if vim.fn.filereadable(copilot_file) == 0 then
    local file = io.open(copilot_file, "w")
    if file then
      file:write(copilot_instructions)
      file:close()
      files_created = files_created + 1
    end
  else
    files_skipped = files_skipped + 1
  end

  -- Show result message
  local message = string.format(
    "AI templates setup completed!\nCreated: %d files\nSkipped (already exists): %d files\n\nLocations:\n- Claude Code: %s\n- VSCode Copilot: %s\n- GitHub Copilot: %s",
    files_created,
    files_skipped,
    claude_dir,
    vscode_dir,
    copilot_file
  )
  vim.notify(message, vim.log.levels.INFO)
end

return M
