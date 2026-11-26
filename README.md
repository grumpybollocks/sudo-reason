# sudo-reason

A sudo password pop-up that tells you **why** it's asking.

When an AI coding agent such as Claude Code, or any script, runs `sudo` without a terminal, you normally
get a bare "password for user:" box with no idea what it's for. sudo-reason replaces that box with one that
shows:

```
Claude needs your password

Why:  Remove the unused real-time kernel
Does: Remove software packages: linux61-rt …
Runs: pacman -Rns linux61-rt …

Not expecting this? Cancel.
```

- **Why:** the reason the caller gave, via `SUDO_REASON="..."`
- **Does:** a plain-English guess for common commands (pacman, systemctl, update-grub, rm, mount …)
- **Runs:** the exact command that will run as root, read from the real sudo process, so the caller can't fake it

## Install

```
git clone https://github.com/grumpybollocks/sudo-reason.git
cd sudo-reason
./install.sh
```

No sudo needed. Everything goes in your home folder and survives reboots. Running it again is safe.

It installs `~/.local/bin/sudo-askpass-reason`, adds a marked block at the top of `~/.zshenv` and `~/.bashrc`
(backups are made), and sets `SUDO_ASKPASS` for your desktop session via `~/.config/environment.d/`.

Inside Claude Code (detected by `$CLAUDECODE`), `sudo` is wrapped as `sudo -A`, so the pop-up is always used,
including for `!` commands. Normal terminals keep asking in the terminal as usual.

## Use

```
SUDO_REASON="Rebuild the boot menu" sudo update-grub
```

Test it:

```
sudo -k; SUDO_REASON="Testing the pop-up" sudo -A true
```

### Telling your AI agent
Add something like this to your agent's instructions (for example `CLAUDE.md`):

> Always run sudo as `SUDO_REASON="<plain-English reason>" sudo <command>`.

## Requirements
Linux with sudo, bash, and one of `kdialog` (KDE), `zenity` (GNOME etc.) or `ksshaskpass`.

## Uninstall

```
./uninstall.sh
```

## Security notes
- The password goes straight from the dialog to sudo on stdout. Nothing is logged or stored.
- The **Runs:** line comes from `/proc/<sudo pid>/cmdline`, not from anything the caller passes.
- The **Why:** line is whatever the caller wrote, so judge it against **Runs:**. If they don't match, cancel.
- sudo caches your password for a few minutes, so a second command soon after may not show a box.

## Licence
MIT
