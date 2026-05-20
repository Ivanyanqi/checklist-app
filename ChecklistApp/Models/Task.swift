//
//  Task.swift
//  ChecklistApp
//

import Foundation
import SwiftData

@Model
final class Task {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    var tags: [Tag]

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.completedAt = nil
        self.createdAt = Date()
        self.tags = []
    }
}
