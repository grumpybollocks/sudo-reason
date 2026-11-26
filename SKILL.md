---
name: sudo-reason
description: How to run sudo so the user's password pop-up says why. Use whenever a command needs sudo/root (pacman, systemctl, update-grub, mount, editing /etc …), when suggesting a sudo command for the user to run with `!`, or when asked to set up the sudo-reason pop-up.
---

# sudo-reason

The user has (or wants) a sudo password pop-up that shows **Why** (your reason), **Does** (a plain-English
guess) and **Runs** (the exact command, read from the real sudo process). See
https://github.com/grumpybollocks/sudo-reason

## Every time you use sudo
1. Give each sudo its own short, plain-English reason:
   `SUDO_REASON="Rebuild the boot menu" sudo update-grub`
   In chains, give **each** sudo its own: `SUDO_REASON="A" sudo x && SUDO_REASON="B" sudo y`.
2. Make the reason honest and specific. The user compares **Why** with **Runs** and will cancel if they don't match.
3. Group related root steps into one chain, so the user gets fewer pop-ups.
4. `!` commands and your own Bash calls can't answer prompts. For pacman and similar, show what will
   change first, then use `--noconfirm`. Never pipe a password into sudo or ask the user for it in chat.
5. "Sorry, try again." means the password was rejected (usually a typo). It isn't a bug; check the
   result before assuming the command ran.
6. Before claiming success, verify the effect (for example `pacman -Q`, `systemctl status`), not just the exit code.

## Check / install
- Installed if: `[ "$SUDO_ASKPASS" = "$HOME/.local/bin/sudo-askpass-reason" ] && echo yes`
- Not installed and the user wants it (no sudo needed):
  `git clone https://github.com/grumpybollocks/sudo-reason.git ~/sudo-reason && ~/sudo-reason/install.sh`
  Then the user restarts Claude Code and tests with
  `! sudo -k; SUDO_REASON="Testing the pop-up" sudo true`
- Remove: `~/sudo-reason/uninstall.sh`

## How it works (for debugging)
- `~/.zshenv` / `~/.bashrc` have a marked block at the top that sets `SUDO_ASKPASS` and, when
  `$CLAUDECODE` is set, wraps `sudo` as `sudo -A`, so the pop-up is used even when a terminal exists.
- The helper reads the command from `/proc/$PPID/cmdline` and the reason from `$SUDO_REASON`, then shows
  kdialog (HTML text; plain newlines get collapsed), zenity or ksshaskpass.
- sudo caches the password per caller for a few minutes, so a missing pop-up right after another one is normal.
