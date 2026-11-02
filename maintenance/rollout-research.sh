#!/usr/bin/env bash
# Copy the research template's infrastructure into an existing research repository.
#   maintenance/rollout-research.sh PATH/TO/PROJECT
# Updates .vscode/, .claude/settings.json, .github/, CLAUDE.md (with the project's package
# name), syncdata.sh and .gitignore. Never touches simulations/, analysis/, data/,
# manuscript/, syncdata.conf or README.md. Does not commit: review with git diff.
set -euo pipefail
T="$(cd "$(dirname "$0")/.." && pwd)"   # this template repository
P="${1:?usage: maintenance/rollout-research.sh PROJECT}"

[[ -f "$T/simulations/Project.toml" && -f "$P/simulations/Project.toml" ]] || { echo "Both paths must be research repositories" >&2; exit 1; }
pkg="$(sed -n 's/^name *= *"\(.*\)"/\1/p' "$P/simulations/Project.toml" | head -n1)"
[[ -n "$pkg" ]] || { echo "Cannot read the package name from $P/simulations/Project.toml" >&2; exit 1; }

mkdir -p "$P/.vscode" "$P/.claude" "$P/.github"
cp "$T/.vscode/settings.json" "$T/.vscode/tasks.json" "$T/.vscode/extensions.json" "$P/.vscode/"
cp "$T/.claude/settings.json" "$P/.claude/"
cp "$T/.github/copilot-instructions.md" "$P/.github/"
cp "$T/syncdata.sh" "$T/.gitignore" "$P/"
chmod +x "$P/syncdata.sh"
perl -pe "s/\bMyPaperPackage\b/$pkg/g" "$T/CLAUDE.md" > "$P/CLAUDE.md"

echo "Updated infrastructure in $P (package: $pkg):"
git -C "$P" status --short
echo "Review CLAUDE.md with git diff: any project-specific additions there were replaced."
