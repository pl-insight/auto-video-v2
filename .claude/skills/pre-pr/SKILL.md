---
name: pre-pr
description: PR を作る前、または merge する前に、CLAUDE.md §3 の Stop Gate（緩和版）と §2 の絶対禁止を確かめ、合否を表で示す。ファイルは変更しない。
notion_url: https://app.notion.com/p/3f5037a9fad34f9ca316671ca6f6bd72
notion_version: 0
git_sha: ""
reviewed_at: ""
owner: "@pl-insight"
status: draft
---

# /pre-pr — Stop Gate の事前確認

正本は CLAUDE.md §2・§3（このリポジトリ直下）。食い違ったら CLAUDE.md を優先し、この手順の修正を提案する。
このスキルは読み取りと検査コマンドの実行だけを行い、ファイルを変更しない。

## 1. 差分をつかむ

```sh
git fetch origin main
git diff --name-status origin/main...HEAD
git log --oneline origin/main..HEAD
```

PR がすでにある場合は、PR タイトルと本文も読む。

## 2. 検査コマンドを流す（CI と同じ）

```sh
uv sync --locked
uv run ruff check .
uv run ruff format --check .
uv run pytest
```

## 3. 条件ごとに判定する

| # | 条件（CLAUDE.md §3） | 判定のしかた |
| --- | --- | --- |
| 1 | 公開 ID 露出検出テスト（C-11）と S8 DRY-RUN ログを PR 本文に添付 | 公開経路（S6〜S8）のコードを変える PR だけが対象。S8 実装前は「該当なし：S8 実装前」 |
| 2 | Conventional Commits | PR タイトルが `type(scope)?: 要約` の形か。CI の `pr-title` でも検査される |
| 3 | 契約スキーマ（`contracts/`）を更新済み | ステージ間の受け渡しを変える場合だけ。変えないなら「該当なし：理由」 |
| 4 | テスト追加 | 新規・変更したコード（Python・hook スクリプト）に unit/integration が 1 件以上あるか。文書だけなら「該当なし：文書のみ」 |

## 4. 絶対禁止を確かめる（CLAUDE.md §2・§8）

- `.env` や秘匿値（API キー・トークン・秘密鍵）を差分に含めていない
- `demo_renderer_sanity`、黒塗りダミーのフォールバック、MODE=stub と MODE=production の同一エントリーポイントからの起動を含めていない
- `main` への force push を前提にしていない

## 5. 結果を示す

次の表で示す。1 つでも「不合格」があれば、merge しないことを明記し、直し方を書く。

| 条件 | 結果（合格／不合格／該当なし：理由） | 根拠（ファイル・コマンド出力） |
| --- | --- | --- |

最後に、PR 本文へ貼るチェックリスト（CLAUDE.md §3 の 4 条件）を出力する。
