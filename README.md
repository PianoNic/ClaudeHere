# ClaudeHere

<p align="center">
  <img src="claude-source.png" width="128" alt="Claude icon" />
</p>

Right-click anywhere in Windows Explorer to launch [Claude Code](https://claude.com/claude-code) in that folder.

Adds two entries to the context menu:

- **Open Claude here** — starts a fresh chat
- **Open Claude here (continue)** — resumes the most recent chat (`claude --continue`)

Both appear when right-clicking a folder, the empty space inside a folder, or a drive.

## Prerequisites

- Windows 10 / 11
- [Claude Code](https://claude.com/claude-code) installed and `claude` available on your `PATH`

## Install

Pick a variant:

| Variant | Command run | When to use |
| --- | --- | --- |
| **safe** (default) | `claude` | Keeps Claude Code's per-tool permission prompts. Recommended. |
| **yolo** | `claude --dangerously-skip-permissions` | Skips permission prompts. Faster, but only use in folders you fully trust. |

### Easy way (PowerShell)

Right-click `install.ps1` → *Run with PowerShell*. Defaults to safe.

For the yolo variant:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Variant yolo
```

The script copies `claude.ico` to `%LOCALAPPDATA%\ClaudeHere\` and imports the matching `.reg` file.

### Manual way

1. Copy `claude.ico` to `%LOCALAPPDATA%\ClaudeHere\claude.ico`
2. Double-click `install-safe.reg` *or* `install-yolo.reg`
3. Confirm the registry merge

> On Windows 11 the entries live under **Show more options** in the context menu (or hold `Shift` while right-clicking). If they don't show up, restart Explorer (Task Manager → *Windows Explorer* → *Restart*).

## Uninstall

Run `uninstall.ps1`, or double-click `uninstall.reg` (this leaves the icon file behind; delete `%LOCALAPPDATA%\ClaudeHere\` manually if you care).

## Files

| File | Purpose |
| --- | --- |
| `install-safe.reg` | Registry entries — runs `claude` |
| `install-yolo.reg` | Registry entries — runs `claude --dangerously-skip-permissions` |
| `uninstall.reg` | Removes all registry entries |
| `install.ps1` | Copies the icon, imports the chosen `.reg` |
| `uninstall.ps1` | Removes registry entries and the icon |
| `claude.ico` | Multi-resolution icon (16/24/32/48/64/128/256) |
| `claude-source.png` | Source 512×512 PNG |

## Credit

Icon: Anthropic Claude logo (CC0 / public domain), via UXWing.

## License

MIT
