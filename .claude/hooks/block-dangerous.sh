#!/usr/bin/env bash
# PreToolUse(Bash) hook（ClaudeCode 開発契約 BP §7.2-1・§12.2）
# 標準入力の JSON から tool_input.command を取り出し、危険なコマンドを止める。
# 遮断は終了コード 2（Claude Code の hook 仕様。終了コード 1 では遮断されない）。
set -u

input="$(cat)"
if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
else
  cmd="$(printf '%s' "$input" | python3 -c \
    'import json, sys; print(json.load(sys.stdin).get("tool_input", {}).get("command", ""))')"
fi
[ -z "$cmd" ] && exit 0

block() {
  echo "STOP: $1（.claude/hooks/block-dangerous.sh）" >&2
  exit 2
}

has() { printf '%s' "$cmd" | grep -qE -- "$1"; }

# 1. rm -rf（-fr・-r -f・--recursive --force などの組み合わせを含む）
if has '(^|[;&|(`[:space:]])rm[[:space:]]'; then
  if has '[[:space:]]-[[:alpha:]]*[rR][[:alpha:]]*f[[:alpha:]]*([[:space:]]|$)' \
    || has '[[:space:]]-[[:alpha:]]*f[[:alpha:]]*[rR][[:alpha:]]*([[:space:]]|$)' \
    || { has '[[:space:]](-[[:alpha:]]*[rR][[:alpha:]]*|--recursive)([[:space:]]|$)' \
      && has '[[:space:]](-[[:alpha:]]*f[[:alpha:]]*|--force)([[:space:]]|$)'; }; then
    block "rm -rf は禁止です"
  fi
fi

# 2. git push の強制（--force・-f・--force-with-lease・+refspec）
if has 'git([[:space:]]+-[^[:space:]]+)*[[:space:]]+push([[:space:]]|$)'; then
  if has '[[:space:]](--force|--force-with-lease|-f)([[:space:]=]|$)' \
    || has 'push([[:space:]]+[^[:space:]]+)*[[:space:]]+\+[^[:space:]]+'; then
    block "git push の強制は禁止です（CLAUDE.md §2）"
  fi
fi

# 3. kubectl delete
if has 'kubectl([[:space:]]+[^[:space:]]+)*[[:space:]]+delete([[:space:]]|$)'; then
  block "kubectl delete は禁止です"
fi

# 4. 黒塗りダミー・stub と production の混在（CLAUDE.md §8・BP §12.2）
if has 'demo_renderer_sanity'; then
  block "demo_renderer_sanity を含むコマンドは禁止です（CLAUDE.md §8）"
fi
if has 'MODE=stub.*production|MODE=production.*stub'; then
  block "MODE=stub と MODE=production の混在は禁止です（CLAUDE.md §8）"
fi

exit 0
