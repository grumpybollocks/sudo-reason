#!/usr/bin/env bash
# Installs the "sudo password pop-up that says why" for the current user.
# Safe to run again: it replaces its own block instead of adding duplicates.
# Needs no sudo. Survives reboots (plain files in your home folder).
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
bin="$HOME/.local/bin/sudo-askpass-reason"
begin="# >>> sudo-reason-popup >>>"
end="# <<< sudo-reason-popup <<<"

block='# >>> sudo-reason-popup >>>
# sudo password pop-up that shows WHY (command + reason). Optional: SUDO_REASON="..." sudo <cmd>
export SUDO_ASKPASS="$HOME/.local/bin/sudo-askpass-reason"
# Inside Claude Code always use the pop-up; normal terminals are unchanged.
if [ -n "${CLAUDECODE:-}" ]; then
    sudo() { command sudo -A "$@"; }
fi
# <<< sudo-reason-popup <<<'

# 1. the pop-up script
mkdir -p "$HOME/.local/bin"
install -m 755 "$here/sudo-askpass-reason" "$bin"
echo "Installed $bin"

# 2. shell start-up files (zsh and bash)
add_block() {
    local f=$1
    touch "$f"
    cp -p "$f" "$f.bak-sudo-popup-$(date +%Y%m%d-%H%M%S)"
    # remove our old block and any previous SUDO_ASKPASS line (we set it ourselves)
    awk -v b="$begin" -v e="$end" '
        $0==b {skip=1; next} $0==e {skip=0; next} skip {next}
        /^export SUDO_ASKPASS=/ {next}
        !started && /^[[:space:]]*$/ {next}
        {started=1; print}' "$f" > "$f.tmp"
    { printf '%s\n\n' "$block"; cat "$f.tmp"; } > "$f"
    rm -f "$f.tmp"
    echo "Updated $f"
}
add_block "$HOME/.zshenv"
add_block "$HOME/.bashrc"

# 3. whole desktop session (apps started from the menu), from next login
mkdir -p "$HOME/.config/environment.d"
printf 'SUDO_ASKPASS=${HOME}/.local/bin/sudo-askpass-reason\n' > "$HOME/.config/environment.d/50-sudo-askpass.conf"
echo "Wrote ~/.config/environment.d/50-sudo-askpass.conf"

# 4. checks
bash -n "$bin" && echo "Script syntax: OK"
command -v kdialog >/dev/null && echo "kdialog: found" || echo "WARNING: kdialog not found (will try zenity/ksshaskpass)"
zsh -c 'source ~/.zshenv; [ "$SUDO_ASKPASS" = "$HOME/.local/bin/sudo-askpass-reason" ] && echo "zsh setup: OK"' 2>/dev/null || true
echo
echo "Done. Test it from Claude Code with:"
echo '  ! sudo -k; SUDO_REASON="Testing the pop-up" sudo true'
