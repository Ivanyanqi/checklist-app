//
//  ArchiveView.swift
//  ChecklistApp
//

import SwiftUI
import SwiftData
import WidgetKit

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<Task> { $0.isCompleted },
        sort: \Task.completedAt,
        order: .reverse
    ) private var completedTasks: [Task]

    private var groupedTasks: [(String, [Task])] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        var groups: [String: [Task]] = [:]
        for task in completedTasks {
            let completedAt = task.completedAt ?? task.createdAt
            let day = calendar.startOfDay(for: completedAt)
            let key: String
            if day == today {
                key = "今天"
            } else if day == yesterday {
                key = "昨天"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "M月d日"
                key = formatter.string(from: day)
            }
            groups[key, default: []].append(task)
        }

        // 按日期降序排列分组
        let sortOrder = ["今天", "昨天"]
        let sorted = groups.sorted { a, b in
            let aIdx = sortOrder.firstIndex(of: a.key) ?? Int.max
            let bIdx = sortOrder.firstIndex(of: b.key) ?? Int.max
            if aIdx != Int.max || bIdx != Int.max {
                return aIdx < bIdx
            }
            return a.key > b.key
        }
        return sorted
    }

    var body: some View {
        Group {
            if completedTasks.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(groupedTasks, id: \.0) { (dateLabel, tasks) in
                            // 日期分组标题
                            Text(dateLabel)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                                .padding(.bottom, 4)

                            ForEach(tasks) { task in
                                archiveRow(task: task)
                                if task.id != tasks.last?.id {
                                    Divider().padding(.leading, 44)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func archiveRow(task: Task) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.secondary.opacity(0.4))
                .font(.system(size: 18))

            Text(task.title)
                .font(.body)
                .foregroundColor(.secondary)
                .strikethrough()
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 取消完成按钮
            Button {
                uncomplete(task)
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .foregroundColor(.secondary.opacity(0.6))
                    .font(.system(size: 13))
            }
            .buttonStyle(.plain)
            .help("移回待办")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private func uncomplete(_ task: Task) {
        withAnimation {
            task.isCompleted = false
            task.completedAt = nil
        }
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "archivebox")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.4))
            Text("暂无已完成的任务")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
