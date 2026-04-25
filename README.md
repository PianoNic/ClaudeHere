# ClaudeHere

<p align="center">
  <img src="assets/claude-source.png" width="128" alt="Claude icon" />
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

Right-click `install.ps1` → *Run with PowerShell*. The script asks which variant you want, then auto-elevates via UAC.

To skip the prompt:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Variant safe
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Variant yolo
```

The script copies `claude.ico` to `%LOCALAPPDATA%\ClaudeHere\`, imports the matching `.reg` file, and localizes the menu labels to your OS UI language.

### Localization

The menu entries are translated at install time based on your Windows UI language. Currently shipped: `de`, `fr`, `es`, `it`, `pt`, `nl`, `pl`, `cs`, `sk`, `hu`, `ro`, `sv`, `nb`, `da`, `fi`, `is`, `el`, `tr`, `ru`, `uk`, `bg`, `sr`, `hr`, `sl`, `lt`, `lv`, `et`, `ca`, `eu`, `gl`, `ja`, `zh-Hans`, `zh-Hant`, `ko`, `vi`, `th`, `id`, `ms`, `fil`, `ar`, `fa`, `he`, `hi`. Anything else falls back to English.

Override with `-Language`:

```powershell
.\install.ps1 -Variant safe -Language ja
```

To add or fix a translation, edit [`translations.xml`](./translations.xml) and open a PR.

> Labels are written to the registry as a snapshot at install time. If you change Windows UI language afterwards, re-run `install.ps1` to refresh.

### Manual way

1. Copy `assets/claude.ico` to `%LOCALAPPDATA%\ClaudeHere\claude.ico`
2. Double-click `reg/install-safe.reg` *or* `reg/install-yolo.reg`
3. Confirm the registry merge

> On Windows 11 the entries live under **Show more options** in the context menu (or hold `Shift` while right-clicking). If they don't show up, restart Explorer (Task Manager → *Windows Explorer* → *Restart*).

## Uninstall

Run `uninstall.ps1`, or double-click `reg/uninstall.reg` (this leaves the icon file behind; delete `%LOCALAPPDATA%\ClaudeHere\` manually if you care).

## Files

| File | Purpose |
| --- | --- |
| `install.ps1` | Copies the icon, imports the chosen `.reg`, applies localized labels |
| `uninstall.ps1` | Removes registry entries and the icon |
| `translations.xml` | Per-language menu labels (edit to add a language) |
| `reg/install-safe.reg` | Registry entries — runs `claude` |
| `reg/install-yolo.reg` | Registry entries — runs `claude --dangerously-skip-permissions` |
| `reg/uninstall.reg` | Removes all registry entries |
| `assets/claude.ico` | Multi-resolution icon (16/24/32/48/64/128/256) |
| `assets/claude-source.png` | Source 512×512 PNG |

## Credit

Icon: Anthropic Claude logo (CC0 / public domain), via UXWing.

## License

MIT
