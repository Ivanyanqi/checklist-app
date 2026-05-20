//
//  TagManagerView.swift
//  ChecklistApp
//

import SwiftUI
import SwiftData

struct TagManagerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Tag.name) private var allTags: [Tag]

    @State private var newTagName = ""
    @State private var newTagColor = Color.blue
    @FocusState private var isInputFocused: Bool

    // 预设颜色
    private let presetColors: [Color] = [
        .blue, .green, .orange, .red, .purple,
        .pink, .yellow, .teal, .indigo, .brown
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("标签管理")
                    .font(.headline)
                Spacer()
                Button("完成") { dismiss() }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            // 已有标签列表
            if allTags.isEmpty {
                Text("还没有标签，添加一个吧")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                List {
                    ForEach(allTags) { tag in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color(hex: tag.colorHex))
                                .frame(width: 12, height: 12)
                            Text(tag.name)
                                .font(.body)
                            Spacer()
                            Text("\(tag.tasks.count) 个任务")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                    .onDelete(perform: deleteTags)
                }
                .listStyle(.plain)
                .frame(maxHeight: 200)
            }

            Divider()

            // 新建标签区域
            VStack(alignment: .leading, spacing: 12) {
                Text("新建标签")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                // 标签名称输入
                HStack {
                    TextField("标签名称", text: $newTagName)
                        .textFieldStyle(.roundedBorder)
                        .focused($isInputFocused)
                        .onSubmit { addTag() }

                    Button("添加") { addTag() }
                        .buttonStyle(.borderedProminent)
                        .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                // 颜色选择
                HStack(spacing: 8) {
                    Text("颜色")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(presetColors, id: \.self) { color in
                        let isSelected = newTagColor == color
                        Button {
                            newTagColor = color
                        } label: {
                            Circle()
                                .fill(color)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: isSelected ? 2 : 0)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(color.opacity(0.5), lineWidth: isSelected ? 3 : 0)
                                        .padding(-2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .frame(width: 320, height: 380)
        .onAppear { isInputFocused = true }
    }

    private func addTag() {
        let name = newTagName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        // 避免重名
        guard !allTags.contains(where: { $0.name.lowercased() == name.lowercased() }) else { return }

        let tag = Tag(name: name, colorHex: newTagColor.hexString)
        modelContext.insert(tag)
        try? modelContext.save()

        newTagName = ""
        newTagColor = .blue
    }

    private func deleteTags(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(allTags[index])
        }
        try? modelContext.save()
    }
}
