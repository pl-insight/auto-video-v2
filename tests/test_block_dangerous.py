"""block-dangerous.sh（PreToolUse(Bash) hook）のテスト。"""

import json
import subprocess
from pathlib import Path

import pytest

HOOK = Path(__file__).resolve().parents[1] / ".claude" / "hooks" / "block-dangerous.sh"


def run_hook(command: str) -> subprocess.CompletedProcess[str]:
    payload = json.dumps({"tool_name": "Bash", "tool_input": {"command": command}})
    return subprocess.run(
        ["bash", str(HOOK)], input=payload, capture_output=True, text=True, check=False
    )


@pytest.mark.parametrize(
    "command",
    [
        "rm -rf build",
        "rm -fr /tmp/x",
        "rm -r -f dist",
        "rm --recursive --force out",
        "cd x && rm -Rf y",
        "git push --force origin main",
        "git push -f",
        "git push --force-with-lease origin feature",
        "git push origin +main",
        "kubectl delete pod web-1",
        "kubectl -n prod delete deploy api",
        "python render.py --out demo_renderer_sanity.mp4",
        "MODE=stub python a.py && MODE=production python b.py",
        "MODE=production python b.py; MODE=stub python a.py",
    ],
)
def test_blocks_dangerous_commands(command: str) -> None:
    result = run_hook(command)
    assert result.returncode == 2
    assert "STOP:" in result.stderr


@pytest.mark.parametrize(
    "command",
    [
        "rm build/tmp.txt",
        "rm -r empty_dir",
        "git push origin feature",
        "git status",
        "kubectl get pods",
        "uv run pytest",
        "MODE=stub python a.py",
        "grep -r foo src",
    ],
)
def test_allows_safe_commands(command: str) -> None:
    result = run_hook(command)
    assert result.returncode == 0, result.stderr


def test_allows_empty_input() -> None:
    result = subprocess.run(
        ["bash", str(HOOK)], input="{}", capture_output=True, text=True, check=False
    )
    assert result.returncode == 0
