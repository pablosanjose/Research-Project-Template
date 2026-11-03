#!/usr/bin/env bash
# Sync the project's data between the cluster and this computer, over SSH with rsync.
#
#   ./sync-data.sh          pull: copy new and changed files from the cluster to data/
#   ./sync-data.sh -n       dry run: show what would be copied, copy nothing
#   ./sync-data.sh --push   push: copy local files to the cluster (asks for confirmation)
#
# Settings are in sync-data.conf (shared) and sync-data.local.conf (personal, optional).
# Nothing is ever deleted on either side. Requires passwordless SSH to the cluster
# (and the VPN, if the cluster needs it).
set -euo pipefail
cd "$(dirname "$0")"

source ./sync-data.conf
if [[ -f ./sync-data.local.conf ]]; then source ./sync-data.local.conf; fi

direction=pull
dryrun=()
for arg in "$@"; do
    case "$arg" in
        -n|--dry-run) dryrun=(--dry-run) ;;
        --push)       direction=push ;;
        -h|--help)    sed -n '2,11p' "$0"; exit 0 ;;
        *)            echo "Unknown option: $arg (see ./sync-data.sh --help)" >&2; exit 2 ;;
    esac
done

command -v rsync >/dev/null || { echo "rsync is not installed (on Windows, run this in WSL)." >&2; exit 1; }

if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "$REMOTE" true 2>/dev/null; then
    echo "Cannot reach '$REMOTE' over SSH. Is the VPN on? Is '$REMOTE' defined in ~/.ssh/config?" >&2
    exit 1
fi

excludes=()
for pattern in ${EXCLUDE[@]+"${EXCLUDE[@]}"}; do excludes+=(--exclude "$pattern"); done

mkdir -p "$LOCAL_PATH"
if [[ "$direction" == pull ]]; then
    echo "Pulling $REMOTE:$REMOTE_PATH/ -> $LOCAL_PATH/"
    rsync -azh --progress ${dryrun[@]+"${dryrun[@]}"} ${excludes[@]+"${excludes[@]}"} "$REMOTE:$REMOTE_PATH/" "$LOCAL_PATH/"
else
    read -r -p "Push $LOCAL_PATH/ to $REMOTE:$REMOTE_PATH/ ? [y/N] " answer
    [[ "$answer" == [yY] ]] || { echo "Cancelled."; exit 0; }
    rsync -azh --progress ${dryrun[@]+"${dryrun[@]}"} ${excludes[@]+"${excludes[@]}"} "$LOCAL_PATH/" "$REMOTE:$REMOTE_PATH/"
fi
