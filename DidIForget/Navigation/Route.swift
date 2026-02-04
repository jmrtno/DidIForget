import Foundation

enum Route: Hashable, Identifiable {
    case reminderList
    case createReminder
    
    var id: String {
        switch self {
        case .reminderList:
            return "reminderList"
        case .createReminder:
            return "createReminder"
        }
    }
}
