# auto-video-v2

自動生成動画パイプラインのリポジトリです。旧 `pl-insight/auto-video` と `pl-insight/auto-video-sot` は archive 済みで、本リポジトリが後継です。

## 正本

- 仕様・計画・規範の正本は Notion（DocHub）にあります。本リポジトリの `docs/SOT_Master.md` は配布物です。
- AI エージェント向けの開発契約は [CLAUDE.md](CLAUDE.md) です（[AGENTS.md](AGENTS.md) は CLAUDE.md を参照します）。

## 開発の始め方

必要なもの：[uv](https://docs.astral.sh/uv/)（Python 3.14 は uv が用意します）。

```sh
uv sync --locked
uv run ruff check .
uv run ruff format --check .
uv run pytest
```

上の検査は CI（`.github/workflows/ci.yml`）と同じです。

## 進め方

- 1 Issue＝1 PR。PR は Squash merge で、タイトルは Conventional Commits 形式にします（`pr-title` で自動検査）。
- `main` は Ruleset「main-protection」で保護されています。必須チェックは lint・unit・pr-title です。
