//
//  AppIntent.swift
//  ChecklistWidget
//

import AppIntents
import SwiftData
import WidgetKit

// MARK: - Task 快照（值类型，用于 Widget Entry）
struct TaskSnapshot: Identifiable, Codable {
    var id: UUID
    var title: String
    var isCompleted: Bool
}

// MARK: - 完成任务 Intent
struct CompleteTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "完成任务"
    static var description = IntentDescription("将指定任务标记为已完成")

    @Parameter(title: "Task ID")
    var taskIDString: String

    init() {}

    init(taskID: UUID) {
        self.taskIDString = taskID.uuidString
    }

    func perform() async throws -> some IntentResult {
        guard let taskID = UUID(uuidString: taskIDString) else {
            return .result()
        }

        guard let dbURL = Self.dbURL() else { return .result() }

        let schema = Schema([Task.self, Tag.self])
        let config = ModelConfiguration(schema: schema, url: dbURL, allowsSave: true)
        guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
            return .result()
        }

        let context = ModelContext(container)
        let predicate = #Predicate<Task> { $0.id == taskID }
        let descriptor = FetchDescriptor<Task>(predicate: predicate)

        if let task = try? context.fetch(descriptor).first {
            task.isCompleted = true
            task.completedAt = Date()
            try? context.save()
        }

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }

    static func dbURL() -> URL? {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("ChecklistApp/checklist.sqlite")
    }
}

// MARK: - Widget 数据提供者
struct WidgetDataProvider {
    static func fetchPendingTasks(maxCount: Int = 8) -> [TaskSnapshot] {
        guard let dbURL = CompleteTaskIntent.dbURL(),
              FileManager.default.fileExists(atPath: dbURL.path) else {
            return []
        }

        let schema = Schema([Task.self, Tag.self])
        let config = ModelConfiguration(schema: schema, url: dbURL, allowsSave: false)
        guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
            return []
        }

        let context = ModelContext(container)
        let predicate = #Predicate<Task> { !$0.isCompleted }
        var descriptor = FetchDescriptor<Task>(
            predicate: predicate,
            sortBy: [SortDescriptor(\Task.createdAt, order: .forward)]
        )
        descriptor.fetchLimit = maxCount

        let tasks = (try? context.fetch(descriptor)) ?? []
        return tasks.map { TaskSnapshot(id: $0.id, title: $0.title, isCompleted: $0.isCompleted) }
    }
}
