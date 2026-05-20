//
//  TaskListView.swift
//  ChecklistApp
//

import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<Task> { !$0.isCompleted },
        sort: \Task.createdAt,
        order: .forward
    ) private var allPendingTasks: [Task]

    let selectedTag: Tag?

    private var filteredTasks: [Task] {
        guard let tag = selectedTag else { return allPendingTasks }
        return allPendingTasks.filter { task in
            task.tags.contains(where: { $0.id == tag.id })
        }
    }

    var body: some View {
        Group {
            if filteredTasks.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredTasks) { task in
                            TaskRowView(task: task)
                            if task.id != filteredTasks.last?.id {
                                Divider()
                                    .padding(.leading, 44)
                            }
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.4))
            Text(selectedTag == nil ? "没有待办事项" : "该标签下没有待办")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
