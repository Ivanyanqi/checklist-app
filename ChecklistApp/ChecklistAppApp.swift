//
//  ChecklistAppApp.swift
//  ChecklistApp
//

import SwiftUI
import SwiftData

@main
struct ChecklistAppApp: App {
    var body: some Scene {
        MenuBarExtra {
            PopoverView()
                .modelContainer(PersistenceController.shared)
        } label: {
            MenuBarLabel()
                .modelContainer(PersistenceController.shared)
        }
        .menuBarExtraStyle(.window)
    }
}

/// MenuBar 图标：显示 checkmark 图标 + 未完成任务数量
struct MenuBarLabel: View {
    @Query(
        filter: #Predicate<Task> { !$0.isCompleted },
        sort: \Task.createdAt
    ) private var pendingTasks: [Task]

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "checkmark.circle.fill")
            if !pendingTasks.isEmpty {
                Text("\(pendingTasks.count)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
        }
    }
}
