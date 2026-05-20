//
//  Tag.swift
//  ChecklistApp
//

import Foundation
import SwiftData

@Model
final class Tag {
    var id: UUID
    var name: String
    var colorHex: String
    @Relationship(inverse: \Task.tags) var tasks: [Task]

    init(name: String, colorHex: String) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.tasks = []
    }
}
