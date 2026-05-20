//
//  AddTaskView.swift
//  ChecklistApp
//

import SwiftUI
import SwiftData
import WidgetKit

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var allTags: [Tag]

    @State private var inputText = ""
    @State private var selectedTags: Set<UUID> = []
    @State private var showTagPicker = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // 标签选择器（展开时显示）
            if showTagPicker && !allTags.isEmpty {
                tagPicker
                Divider()
            }

            HStack(spacing: 8) {
                // 标签按钮
                if !allTags.isEmpty {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showTagPicker.toggle()
                        }
                    } label: {
                        Image(systemName: selectedTags.isEmpty ? "tag" : "tag.fill")
                            .foregroundColor(selectedTags.isEmpty ? .secondary : .accentColor)
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                    .help("选择标签")
                }

                // 输入框
                TextField("添加任务...", text: $inputText)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .focused($isFocused)
                    .onSubmit {
                        addTask()
                    }

                // 提交按钮
                Button {
                    addTask()
                } label: {
                    Image(systemName: "return")
                        .foregroundColor(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? .secondary.opacity(0.4) : .accentColor)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                .keyboardShortcut(.return, modifiers: [])
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private var tagPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(allTags) { tag in
                    let isSelected = selectedTags.contains(tag.id)
                    Button {
                        if isSelected {
                            selectedTags.remove(tag.id)
                        } else {
                            selectedTags.insert(tag.id)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: tag.colorHex))
                                .frame(width: 6, height: 6)
                            Text(tag.name)
                                .font(.caption)
                        }
                        .foregroundColor(isSelected ? .white : .primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color(hex: tag.colorHex) : Color(hex: tag.colorHex).opacity(0.15))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private func addTask() {
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let task = Task(title: trimmed)

        // 关联选中的标签
        let tagsToAdd = allTags.filter { selectedTags.contains($0.id) }
        task.tags = tagsToAdd

        modelContext.insert(task)
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()

        // 重置状态
        inputText = ""
        selectedTags = []
        showTagPicker = false
    }
}
