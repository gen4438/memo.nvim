# AI Commands Reference

memo.nvimで利用可能なAIコマンドの一覧と基本的な使い方です。

## セットアップ

初回のみ、以下のコマンドを実行してAIプロンプトテンプレートをメモディレクトリに作成してください：

```vim
:MemoSetupAI
```

これにより以下のファイルが作成されます：
- `.claude/commands/memo.*.md` - Claude Code用のスラッシュコマンド
- `.github/prompts/memo.*.prompt.md` - GitHub Copilot用のスラッシュコマンド
- `.github/copilot-instructions.md` - GitHub Copilot用のプロジェクト全体指示
- `CLAUDE.md` - Claude Code用のプロジェクト全体指示

---

## 利用可能なコマンド

| コマンド | 用途 |
|---------|------|
| `/memo.draft-exp` | 雑なメモを実験ノート形式に展開 |
| `/memo.retitle` | タイトル改善案を3つ提案 |
| `/memo.organize` | メモを整理・構造化（情報は追加しない） |
| `/memo.summarize` | 複数メモの集約レポート生成 |
| `/memo.compare-exp` | 実験比較テーブル生成 |
| `/memo.refine` | 走り書きを洗練されたメモに変換 |
| `/memo.voice-to-memo` | 音声文字起こしを構造化メモに再構成 |

---

## プロンプトテンプレートの場所

各コマンドの詳細な動作は、以下のプロンプトテンプレートファイルで定義されています：

### 開発者向け（プラグイン内）
- `templates/prompts/*.md` - すべてのプロンプトのソース

### ユーザー向け（メモディレクトリ内）
- `.claude/commands/memo.*.md` - Claude Code用
- `.github/prompts/memo.*.prompt.md` - GitHub Copilot用

これらのファイルを編集することで、各コマンドの動作を自由にカスタマイズできます。

---

## 基本的な使い方

### Claude Code
1. テキストを選択（Visual mode）
2. `/memo.コマンド名` を実行
3. ファイル全体を対象にする場合: `/memo.コマンド名 @filename`

### GitHub Copilot (VSCode)
1. テキストを選択
2. Copilot Chat で `/memo.コマンド名` を実行
3. 選択テキストは自動的に `${selection}` 変数として渡される

---

## カスタマイズ

プロンプトテンプレートは通常のMarkdownファイルなので、エディタで直接編集できます：

```bash
# Claude Code用プロンプトを編集
vim .claude/commands/memo.refine.md

# GitHub Copilot用プロンプトを編集
vim .github/prompts/memo.refine.prompt.md
```

特定のドメイン用語、ワークフロー、出力形式に合わせて調整してください。
