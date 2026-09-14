#!/usr/bin/env bash
# Per-workspace layout switcher.
#
# Presents dwindle/master/scrolling in noctalia's launcher and applies the pick
# to the CURRENT workspace via a Hyprland workspace rule.
#
# Runtime only, on purpose: workspaces.lua stays the source of truth, so a
# config reload (which happens on every config file save) or a Hyprland restart
# re-applies whatever is written there and discards the pick made here.
#
# This is a script rather than a Lua bind because `noctalia dmenu` is a blocking
# round-trip on stdin/stdout; doing that from a Lua bind would block Hyprland's
# main thread for as long as the launcher is open.
set -euo pipefail

LAYOUTS=(dwindle master scrolling)

# Resolve the workspace BEFORE opening the launcher. The focused monitor's
# .activeWorkspace is the normal workspace even while a special one is shown.
mon=$(hyprctl monitors -j)
ws=$(jq -r 'first(.[] | select(.focused)) | .activeWorkspace.id' <<<"$mon")
[[ -n "$ws" && "$ws" != "null" ]] || exit 1

cur=$(hyprctl workspaces -j | jq -r --argjson id "$ws" \
        'first(.[] | select(.id == $id)) | .tiledLayout // ""')

# Mark the active layout; the marker is stripped back off after the choice.
items=()
for l in "${LAYOUTS[@]}"; do
    if [[ "$l" == "$cur" ]]; then items+=("$l ●"); else items+=("$l"); fi
done

choice=$(printf '%s\n' "${items[@]}" | noctalia dmenu -p "layout · workspace $ws") || exit 0
choice=${choice%% *}
[[ -n "$choice" ]] || exit 0

# Only ever interpolate a known-good name into the Lua expression below.
valid=false
for l in "${LAYOUTS[@]}"; do [[ "$choice" == "$l" ]] && valid=true; done
[[ "$valid" == true ]] || { echo "unknown layout: $choice" >&2; exit 1; }

# `hyprctl dispatch` takes Lua here, not legacy syntax. Sending only workspace +
# layout is deliberate: rules merge, so monitor/persistent pinning is preserved.
hyprctl dispatch "function()
    hl.workspace_rule({ workspace = \"$ws\", layout = \"$choice\" })
end" >/dev/null
