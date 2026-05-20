# Checklist App

A lightweight macOS checklist app that lives in your Menu Bar. No accounts, no sync, no distractions — just a clean place to track what needs to get done.

## Features

- **Menu Bar First** — lives quietly in your menu bar, shows a badge count of pending tasks at a glance
- **Tags** — create color-coded tags to organize tasks, filter the list by any tag
- **Archive** — completed tasks are moved to an archive view, keeping the main list clean
- **Desktop Widget** — small and medium WidgetKit widgets display pending tasks on your desktop (requires a paid Apple Developer account to share data with the main app via App Groups)
- **Fully Local** — all data is stored on-device in `~/Library/Application Support/ChecklistApp/checklist.sqlite`, nothing leaves your Mac

## Requirements

- macOS 14 Sonoma or later
- Xcode 15 or later (to build from source)

## Getting Started

1. Clone the repo

```bash
git clone git@github.com:Ivanyanqi/checklist-app.git
cd checklist-app
```

2. Open the project in Xcode

```bash
open ChecklistApp.xcodeproj
```

3. Select the `ChecklistApp` scheme, then press **Run** (`⌘R`). The app will appear in your menu bar.

## Project Structure

```
ChecklistApp/
├── ChecklistApp/
│   ├── ChecklistAppApp.swift       # App entry point, MenuBarExtra + MenuBarLabel
│   ├── Models/
│   │   ├── Task.swift              # SwiftData Task model
│   │   └── Tag.swift               # SwiftData Tag model
│   ├── Persistence/
│   │   └── PersistenceController.swift  # Local SQLite container setup
│   └── Views/
│       ├── MenuBarPopover/
│       │   ├── PopoverView.swift   # Root view with tab switching
│       │   ├── TaskListView.swift  # Pending task list
│       │   ├── TaskRowView.swift   # Individual task row
│       │   ├── AddTaskView.swift   # New task input sheet
│       │   └── ArchiveView.swift   # Completed task archive
│       ├── TagFilter/
│       │   └── TagFilterView.swift # Tag filter bar
│       └── TagManager/
│           └── TagManagerView.swift # Create / delete tags
└── ChecklistWidget/
    ├── ChecklistWidget.swift       # Widget entry view & timeline provider
    ├── ChecklistWidgetBundle.swift # Widget bundle
    └── AppIntent.swift             # CompleteTaskIntent + WidgetDataProvider
```

## Tech Stack

| | |
|---|---|
| Language | Swift 5.10 |
| UI | SwiftUI |
| Persistence | SwiftData (SQLite) |
| Widget | WidgetKit + AppIntents |
| Minimum OS | macOS 14 Sonoma |

## Known Limitations

The desktop widget currently shows empty data when built with a Personal Team provisioning profile. This is because Personal Team accounts do not support App Groups, which is required to share the SwiftData store between the main app and the widget extension. Upgrading to a paid Apple Developer account and enabling an App Group will allow the widget to read live data from the main app.

## License

MIT
