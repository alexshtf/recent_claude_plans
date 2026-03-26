# Claude Plans Menu Bar App

macOS menu bar app that shows Claude Code plan files from `~/.claude/plans`.

## Tech Stack

- **Swift + AppKit** — native `NSStatusBar` / `NSMenu` APIs
- No SwiftUI, no web views, no bundled runtimes
- Single binary, minimal footprint

## Behavior

- Clipboard icon in the macOS menu bar (system tray area)
- Clicking opens a dropdown listing `.md` files from `~/.claude/plans/`, sorted by modification time (newest first)
- Each item shows:
  - **Plan name** (filename without `.md`) — bold top line
  - **Title** — extracted from the first `# ...` heading in the file, with `Plan:` prefix stripped if present
  - **Last modified** — human-friendly: "Today, 4:25 PM" / "Yesterday, ..." / "Mar 21, 2:32 PM"
- Clicking a plan opens the `.md` file in the configured editor
- List refreshes every time the menu is opened (re-scans the directory)

## Configure Menu Item

- Appears below a separator after the plan list
- Opens a settings window with:
  - **Plans to show** — integer (default 10)
  - **Editor** — dropdown: VS Code (`code`), Zed (`zed`), Sublime Text (`subl`), TextEdit (`open -a TextEdit`), Custom (user-provided shell command)

## Settings

- Persisted to `~/.config/claude-plans-menu/config.json`
- Format: `{"max_plans": 10, "editor": "code"}`

## Build

- Swift Package Manager, no Xcode project required
- Target: macOS 13+
