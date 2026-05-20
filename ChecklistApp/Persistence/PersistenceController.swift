//
//  PersistenceController.swift
//  ChecklistApp
//

import Foundation
import SwiftData

struct PersistenceController {

    /// 主 App 使用 Application Support 本地存储
    static let shared: ModelContainer = {
        let schema = Schema([Task.self, Tag.self])

        // 存储路径：~/Library/Application Support/ChecklistApp/checklist.sqlite
        let appSupportURL = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("ChecklistApp", isDirectory: true)

        try? FileManager.default.createDirectory(
            at: appSupportURL,
            withIntermediateDirectories: true
        )

        let dbURL = appSupportURL.appendingPathComponent("checklist.sqlite")
        print("[PersistenceController] DB path: \(dbURL.path)")

        let config = ModelConfiguration(schema: schema, url: dbURL, allowsSave: true)
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            print("[PersistenceController] ✅ Container created")
            return container
        } catch {
            print("[PersistenceController] ❌ Failed: \(error)")
            // 兜底内存存储
            let mem = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [mem])
        }
    }()

    /// 仅用于单元测试
    static func inMemoryContainer() -> ModelContainer {
        let schema = Schema([Task.self, Tag.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [config])
    }
}
