# Lessons

Real problems hit while building and using sudo-reason, and the rule that came out of each.

1. **A bare password box is not enough.** The owner kept getting "[sudo] password for user:" with no idea why.
   Rule: every pop-up shows Why (the caller's reason), Does (a plain-English guess) and Runs (the exact command).
2. **Read the command from the real sudo process.** `/proc/$PPID/cmdline` of the askpass helper is sudo's own
   command line, so the caller can't fake the Runs line. An early version had a test override for the PID, and
   it was removed from the shipped script because it would let a caller show a fake command.
3. **kdialog collapses plain newlines.** The first version showed one long line ("no spacing"). Rule: build the text
   as HTML (`<p>`, `<b>`) and escape `& < >`.
4. **Bash `${var//x/&...}` treats `&` as "the match"** (patsub_replacement, bash 5.2+), so `&lt;` came out wrong.
   Rule: escape with `sed`, not with parameter substitution.
5. **`~/.bashrc` often returns early for non-interactive shells** (`[[ $- != *i* ]] && return`), so a block
   appended at the end never ran. Rule: put the block at the **top** of start-up files.
6. **Re-running an installer must not pile things up.** Rule: use a marked block and replace it, strip leading blank
   lines, and test install ×3 + uninstall in a throwaway `$HOME`.
7. **Claude Code `!` commands can't answer prompts.** `pacman -S` stopped at "Proceed? [Y/n]" and nothing happened.
   Rule: show what will change, then use `--noconfirm`. Check the result afterwards, never assume.
8. **"Sorry, try again." is a rejected password, not a broken pop-up.** The log (`journalctl -t sudo`) showed one
   auth failure and then success, with `tty=` empty, which proves the pop-up path was used.
9. **Check dependencies before removing packages.** Removing an unused kernel also wanted to remove its VirtualBox
   module package, which VirtualBox needed. It turned out VirtualBox had no modules for the main kernel at all.
   Rule: install the replacement first, then remove.
10. **Short and plain wins.** The first pop-up text was a wall of words. The owner asked for "easier to read,
    shorter". Rule: four lines (Why / Does / Runs / Cancel hint), with the command cut at 200 characters.
