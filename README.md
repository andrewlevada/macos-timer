# macOS Menu Bar Timer

A simple countdown timer that lives in your macOS menu bar.

## Features

- Menu bar icon shows the countdown while running
- Quick presets: 1, 5, 10, 15, 25, 45, and 60 minutes
- Custom duration from 1 to 180 minutes
- Start, pause, resume, and reset
- macOS notification when the timer finishes
- No Dock icon — stays out of the way

## Requirements

- macOS 13 (Ventura) or later
- Xcode 15+

## Build & Run

1. Open `macos-timer.xcodeproj` in Xcode
2. Select the **macos-timer** scheme
3. Press **Cmd+R** to build and run

Or from the terminal:

```bash
xcodebuild -project macos-timer.xcodeproj -scheme macos-timer -configuration Release build
open build/Release/macos-timer.app
```

## Usage

1. Click the **⏱** icon in the menu bar
2. Pick a preset or adjust the duration with the stepper
3. Click **Start**
4. The menu bar label updates with the remaining time
5. When time is up, you get a notification and the label shows **Done!**

Use **Quit** in the popover to exit the app.

## Project Structure

```
macos-timer/
├── TimerApp.swift      # App entry point, MenuBarExtra
├── TimerModel.swift    # Timer logic and notifications
├── TimerView.swift     # Popover UI
└── Info.plist          # LSUIElement (menu bar only)
```
