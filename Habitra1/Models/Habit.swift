import Foundation

enum Weekday: Int, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var id: Int { self.rawValue }
    
    var shortName: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }
}

struct Habit: Identifiable {
    let id: UUID
    var title: String
    var icon: String
    var colorHex: String
    var frequency: [Weekday]
    var completionDates: [Date]
    var createdDate: Date
    var isArchived: Bool
    var reminderTime: Date?
    
    init(entity: HabitEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.icon = entity.icon ?? "star.fill"
        self.colorHex = entity.colorHex ?? "#0000FF"
        self.frequency = (entity.frequency as? [Int] ?? []).compactMap { Weekday(rawValue: $0) }
        self.completionDates = entity.completionDates as? [Date] ?? []
        self.createdDate = entity.createdDate ?? Date()
        self.isArchived = entity.value(forKey: "isArchived") as? Bool ?? false
        self.reminderTime = entity.value(forKey: "reminderTime") as? Date
    }
    
    init(id: UUID = UUID(), title: String, icon: String, colorHex: String, frequency: [Weekday], completionDates: [Date] = [], createdDate: Date = Date(), isArchived: Bool = false, reminderTime: Date? = nil) {
        self.id = id
        self.title = title
        self.icon = icon
        self.colorHex = colorHex
        self.frequency = frequency
        self.completionDates = completionDates
        self.createdDate = createdDate
        self.isArchived = isArchived
        self.reminderTime = reminderTime
    }
} 