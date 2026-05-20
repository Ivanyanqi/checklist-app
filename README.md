# Checklist App

一款住在 macOS 菜单栏里的轻量级待办清单应用。无需账号、无需同步、没有多余干扰，专注于记录和完成你的每一件事。

## 功能特性

- **菜单栏优先** — 常驻菜单栏，图标实时显示未完成任务数量，随时一键呼出
- **标签管理** — 创建自定义颜色标签，按标签快速筛选任务
- **完成归档** — 已完成任务自动移入归档视图，主列表始终保持整洁
- **桌面小组件** — 支持 small / medium 两种尺寸的 WidgetKit 小组件，桌面直接查看待办并勾选完成（Widget 与主 App 数据共享需付费开发者账号，详见下方说明）
- **完全本地** — 所有数据存储在本机 `~/Library/Application Support/ChecklistApp/checklist.sqlite`，不联网、不上传

## 环境要求

- macOS 14 Sonoma 及以上
- Xcode 15 及以上（从源码构建时需要）

## 快速开始

1. 克隆仓库

```bash
git clone git@github.com:Ivanyanqi/checklist-app.git
cd checklist-app
```

2. 用 Xcode 打开项目

```bash
open ChecklistApp.xcodeproj
```

3. 选择 `ChecklistApp` Scheme，按 **Run**（`⌘R`）运行，App 图标会出现在菜单栏中。

## 项目结构

```
ChecklistApp/
├── ChecklistApp/
│   ├── ChecklistAppApp.swift            # App 入口，MenuBarExtra + MenuBarLabel
│   ├── Models/
│   │   ├── Task.swift                   # SwiftData 任务模型
│   │   └── Tag.swift                    # SwiftData 标签模型
│   ├── Persistence/
│   │   └── PersistenceController.swift  # 本地 SQLite 容器初始化
│   └── Views/
│       ├── MenuBarPopover/
│       │   ├── PopoverView.swift        # 根视图，Tab 切换待办/归档
│       │   ├── TaskListView.swift       # 待办任务列表
│       │   ├── TaskRowView.swift        # 单条任务行
│       │   ├── AddTaskView.swift        # 新建任务输入面板
│       │   └── ArchiveView.swift        # 已完成任务归档视图
│       ├── TagFilter/
│       │   └── TagFilterView.swift      # 标签筛选栏
│       └── TagManager/
│           └── TagManagerView.swift     # 标签创建与删除
└── ChecklistWidget/
    ├── ChecklistWidget.swift            # Widget 视图 & 时间线 Provider
    ├── ChecklistWidgetBundle.swift      # Widget Bundle
    └── AppIntent.swift                  # CompleteTaskIntent + WidgetDataProvider
```

## 技术栈

| | |
|---|---|
| 开发语言 | Swift 5.10 |
| UI 框架 | SwiftUI |
| 数据持久化 | SwiftData（SQLite） |
| 小组件 | WidgetKit + AppIntents |
| 最低系统版本 | macOS 14 Sonoma |

## 已知限制

使用个人开发者账号（Personal Team）构建时，桌面小组件暂时无法读取主 App 的数据，显示为空。原因是 Personal Team 不支持 App Groups 功能，而主 App 与 Widget Extension 共享 SwiftData 数据库依赖 App Groups。升级为付费 Apple Developer 账号并开启 App Group 后即可打通数据。

## License

MIT
