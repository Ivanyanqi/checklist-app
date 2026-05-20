//
//  TagFilterView.swift
//  ChecklistApp
//

import SwiftUI
import SwiftData

struct TagFilterView: View {
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @Binding var selectedTag: Tag?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // 全部按钮
                filterChip(label: "全部", color: .secondary, isSelected: selectedTag == nil) {
                    selectedTag = nil
                }

                ForEach(allTags) { tag in
                    filterChip(
                        label: tag.name,
                        color: Color(hex: tag.colorHex),
                        isSelected: selectedTag?.id == tag.id
                    ) {
                        selectedTag = (selectedTag?.id == tag.id) ? nil : tag
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }

    @ViewBuilder
    private func filterChip(label: String, color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(isSelected ? color : color.opacity(0.15))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color from Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }

    var hexString: String {
        let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self)
        let r = Int((nsColor.redComponent * 255).rounded())
        let g = Int((nsColor.greenComponent * 255).rounded())
        let b = Int((nsColor.blueComponent * 255).rounded())
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
