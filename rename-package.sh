#!/usr/bin/env bash
# Run once, right after creating a project from the template:
#   ./rename-package.sh MyNewPackage
# Renames the Julia package MyPaperPackage everywhere, gives it a fresh UUID,
# and then deletes itself. Commit the result.
set -euo pipefail
cd "$(dirname "$0")"

OLD=MyPaperPackage
OLDUUID=37c8eba6-234e-488c-98bb-e89ef5533ccc
NEW="${1:-}"

[[ "$NEW" =~ ^[A-Z][A-Za-z0-9]*$ ]] || { echo "Usage: ./rename-package.sh NewName  (CamelCase letters and digits, e.g. TwistedBilayer)" >&2; exit 2; }
[[ -f "simulations/src/$OLD.jl" ]] || { echo "Package already renamed (no simulations/src/$OLD.jl)." >&2; exit 1; }

if command -v julia >/dev/null; then NEWUUID=$(julia --startup-file=no -e 'using UUIDs; print(uuid4())')
elif command -v uuidgen >/dev/null; then NEWUUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
else NEWUUID=$(cat /proc/sys/kernel/random/uuid); fi

files=()
while IFS= read -r f; do files+=("$f"); done < <(grep -rlI -e "$OLD" -e "$OLDUUID" --exclude-dir=.git --exclude-dir=manuscript --exclude-dir=data --exclude=rename-package.sh .)
perl -pi -e "s/\\b$OLD\\b/$NEW/g; s/$OLDUUID/$NEWUUID/g" "${files[@]}"

if git rev-parse --git-dir >/dev/null 2>&1; then git mv "simulations/src/$OLD.jl" "simulations/src/$NEW.jl"
else mv "simulations/src/$OLD.jl" "simulations/src/$NEW.jl"; fi

echo "Renamed $OLD to $NEW (new UUID $NEWUUID) in:"; printf '  %s\n' "${files[@]}"
rm -- "$0"
echo "rename-package.sh removed itself. Now commit: git add -A && git commit -m \"Rename package to $NEW\""
