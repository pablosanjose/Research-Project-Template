#!/usr/bin/env bash
# Copy the Overleaf template's infrastructure into an existing paper clone.
#   maintenance/rollout-manuscript.sh OVERLEAF-TEMPLATE-CLONE PAPER-CLONE
# Never touches the paper itself (main.tex, biblio.bib, figures/). Keeps the paper's
# "Paper conventions" section of .claude/CLAUDE.md. Does not commit: review with git diff;
# if GitDoc runs for that paper, it syncs the changes to Overleaf on its own.
set -euo pipefail

T="${1:?usage: maintenance/rollout-manuscript.sh OVERLEAF-TEMPLATE-CLONE PAPER-CLONE}"
P="${2:?usage: maintenance/rollout-manuscript.sh OVERLEAF-TEMPLATE-CLONE PAPER-CLONE}"

[[ -d "$P/.git" && -f "$P/main.tex" ]] || { echo "Not a paper clone: $P" >&2; exit 1; }

conv=""
if [[ -f "$P/.claude/CLAUDE.md" ]]; then
    conv="$(awk '/^## Paper conventions/{f=1} f' "$P/.claude/CLAUDE.md")"
fi

mkdir -p "$P/tools" "$P/.claude" "$P/.vscode" "$P/.github"
cp -R "$T/tools/." "$P/tools/"
cp "$T/.claude/CLAUDE.md" "$T/.claude/settings.json" "$T/.claude/CLAUDE.local.md.example" "$P/.claude/"
cp "$T/.vscode/settings.json" "$T/.vscode/tasks.json" "$T/.vscode/extensions.json" "$P/.vscode/"
cp "$T/.github/copilot-instructions.md" "$P/.github/"
cp "$T/.gitignore" "$T/.gitattributes" "$P/"
chmod +x "$P/tools/githooks/pre-commit"
rm -f "$P/tools/CLAUDE.local.md.example"          # old location

if [[ -n "$conv" ]]; then
    tmp="$(mktemp)"
    awk '/^## Paper conventions/{exit} {print}' "$P/.claude/CLAUDE.md" > "$tmp"
    printf '%s\n' "$conv" >> "$tmp"
    mv "$tmp" "$P/.claude/CLAUDE.md"
fi

echo "Updated infrastructure in $P:"
git -C "$P" status --short
echo "Next: in VS Code, run Tasks: Run Task -> Paper: one-time setup, once."
