# Claude Explorer Context Menu

Adds two right-click entries to Windows Explorer for quickly launching [Claude Code](https://claude.com/claude-code) in the current folder:

- **Open Claude here** — starts a fresh chat
- **Open Claude here (continue)** — resumes the most recent chat

Both entries appear when right-clicking a folder, the empty space inside a folder, or a drive.

## Prerequisites

- Windows 10 / 11
- [Claude Code](https://claude.com/claude-code) installed and `claude` available on your `PATH`

## Install

1. Download [`claude-context-menu.reg`](./claude-context-menu.reg)
2. Double-click the file
3. Confirm the security prompt and the registry merge
4. On Windows 11, the entries live under **Show more options** (or hold `Shift` while right-clicking)

If they don't show up immediately, restart Explorer (Task Manager → *Windows Explorer* → *Restart*).

## Uninstall

Double-click [`claude-context-menu-uninstall.reg`](./claude-context-menu-uninstall.reg) and confirm.

## What it does

The commands launched are:

```
cmd.exe /k "cd /d "<folder>" && claude --dangerously-skip-permissions"
cmd.exe /k "cd /d "<folder>" && claude --dangerously-skip-permissions --continue"
```

> **Note:** `--dangerously-skip-permissions` skips Claude Code's per-tool permission prompts. Remove it from the `.reg` file if you'd rather keep the prompts.

## Customize

Open `claude-context-menu.reg` in a text editor to:

- Rename the menu entries (change the `@="..."` value)
- Change the icon (`"Icon"="cmd.exe"`)
- Drop the `--dangerously-skip-permissions` flag
- Use `--resume` instead of `--continue` to get a chat picker

## License

MIT
