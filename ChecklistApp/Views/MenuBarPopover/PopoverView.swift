//
//  PopoverView.swift
//  ChecklistApp
//

import SwiftUI
import SwiftData

struct PopoverView: View {
    @State private var selectedTab: Tab = .todo
    @State private var selectedTag: Tag? = nil
    @State private var showTagManager = false

    enum Tab: String, CaseIterable {
        case todo = "待办"
        case archive = "已完成"
    }

    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            headerView

            Divider()

            // 标签过滤栏（仅待办 Tab 显示）
            if selectedTab == .todo {
                TagFilterView(selectedTag: $selectedTag)
                Divider()
            }

            // 主内容区
            Group {
                if selectedTab == .todo {
                    TaskListView(selectedTag: selectedTag)
                } else {
                    ArchiveView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            // 底部：快速添加（仅待办 Tab）+ Tab 切换
            if selectedTab == .todo {
                AddTaskView()
                Divider()
            }

            tabBar
        }
        .frame(width: 340, height: 480)
        .sheet(isPresented: $showTagManager) {
            TagManagerView()
        }
    }

    private var headerView: some View {
        HStack {
            Text("✓ Checklist")
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            // 标签管理按钮
            Button {
                showTagManager = true
            } label: {
                Image(systemName: "tag")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("管理标签")

            // 退出按钮
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("退出应用")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline)
                        .fontWeight(selectedTab == tab ? .semibold : .regular)
                        .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
    }
}
