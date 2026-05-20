//
//  TaskRowView.swift
//  ChecklistApp
//

import SwiftUI
import SwiftData
import WidgetKit

struct TaskRowView: View {
    @Environment(\.modelContext) private var modelContext
    let task: Task
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            // 勾选按钮
            Button {
                toggleComplete()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .accentColor : .secondary)
                    .font(.system(size: 18))
            }
            .buttonStyle(.plain)

            // 任务标题
            Text(task.title)
                .font(.body)
                .foregroundColor(task.isCompleted ? .secondary : .primary)
                .strikethrough(task.isCompleted)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 标签色点
            if !task.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(task.tags.prefix(3)) { tag in
                        Circle()
                            .fill(Color(hex: tag.colorHex))
                            .frame(width: 8, height: 8)
                    }
                }
            }

            // 删除按钮（hover 时显示）
            if isHovered {
                Button {
                    deleteTask()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.7))
                        .font(.system(size: 13))
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .background(isHovered ? Color.primary.opacity(0.05) : Color.clear)
    }

    private func toggleComplete() {
        withAnimation(.easeInOut(duration: 0.2)) {
            task.isCompleted.toggle()
            task.completedAt = task.isCompleted ? Date() : nil
        }
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func deleteTask() {
        modelContext.delete(task)
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
