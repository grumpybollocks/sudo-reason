#!/usr/bin/env bash
# Removes the sudo-reason pop-up for the current user. Needs no sudo.
set -euo pipefail
begin="# >>> sudo-reason-popup >>>"
end="# <<< sudo-reason-popup <<<"

for f in "$HOME/.zshenv" "$HOME/.bashrc"; do
    [ -f "$f" ] || continue
    grep -qF "$begin" "$f" || continue
    cp -p "$f" "$f.bak-sudo-popup-$(date +%Y%m%d-%H%M%S)"
    awk -v b="$begin" -v e="$end" '$0==b {skip=1; next} $0==e {skip=0; next} skip {next} !started && /^[[:space:]]*$/ {next} {started=1; print}' "$f" > "$f.tmp"
    mv "$f.tmp" "$f"
    echo "Removed block from $f"
done

rm -f "$HOME/.config/environment.d/50-sudo-askpass.conf"
rm -f "$HOME/.local/bin/sudo-askpass-reason"
echo "Removed the pop-up script and session setting."
echo "Open a new terminal (and log out/in for desktop apps) to finish."
