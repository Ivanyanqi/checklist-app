//
//  ChecklistWidget.swift
//  ChecklistWidget
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Entry
struct ChecklistEntry: TimelineEntry {
    let date: Date
    let tasks: [TaskSnapshot]
}

// MARK: - Timeline Provider
struct ChecklistProvider: TimelineProvider {
    func placeholder(in context: Context) -> ChecklistEntry {
        ChecklistEntry(date: Date(), tasks: [
            TaskSnapshot(id: UUID(), title: "买菜回家", isCompleted: false),
            TaskSnapshot(id: UUID(), title: "回复邮件", isCompleted: false),
            TaskSnapshot(id: UUID(), title: "锻炼 30 分钟", isCompleted: false),
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (ChecklistEntry) -> Void) {
        let tasks = WidgetDataProvider.fetchPendingTasks(maxCount: 8)
        completion(ChecklistEntry(date: Date(), tasks: tasks))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ChecklistEntry>) -> Void) {
        let tasks = WidgetDataProvider.fetchPendingTasks(maxCount: 8)
        let entry = ChecklistEntry(date: Date(), tasks: tasks)

        // 15 分钟后刷新一次（主 App 写入时也会主动刷新）
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget Entry View
struct ChecklistWidgetEntryView: View {
    var entry: ChecklistEntry
    @Environment(\.widgetFamily) private var family

    private var maxRows: Int { family == .systemSmall ? 3 : 6 }
    private var visibleTasks: [TaskSnapshot] { Array(entry.tasks.prefix(maxRows)) }
    private var remainingCount: Int { max(0, entry.tasks.count - maxRows) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 13))
                Text("Checklist")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(entry.tasks.count) 项")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 6)

            if entry.tasks.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary.opacity(0.4))
                        Text("没有待办")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                Spacer()
            } else {
                // 任务列表
                ForEach(visibleTasks) { task in
                    HStack(spacing: 6) {
                        // 勾选按钮（通过 AppIntent）
                        Button(intent: CompleteTaskIntent(taskID: task.id)) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .accentColor : .secondary)
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)

                        Text(task.title)
                            .font(.caption)
                            .lineLimit(1)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 3)

                    if task.id != visibleTasks.last?.id {
                        Divider()
                    }
                }

                // 剩余数量提示
                if remainingCount > 0 {
                    Text("还有 \(remainingCount) 项...")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
    }
}

// MARK: - Widget 配置
struct ChecklistWidgetItem: Widget {
    let kind: String = "ChecklistWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ChecklistProvider()) { entry in
            ChecklistWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Checklist 待办")
        .description("显示今日待办任务，可直接勾选完成。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
