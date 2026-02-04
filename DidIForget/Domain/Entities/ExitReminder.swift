import Foundation

enum PlaceType: String, Codable, CaseIterable, Identifiable {
    case home
    case work
    case custom
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .home: return "Home"
        case .work: return "Work"
        case .custom: return "Custom"
        }
    }
    
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .work: return "briefcase.fill"
        case .custom: return "mappin.circle.fill"
        }
    }
}

struct ExitReminder: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var latitude: Double
    var longitude: Double
    var radius: Double
    var placeType: PlaceType
    var isEnabled: Bool
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        latitude: Double,
        longitude: Double,
        radius: Double,
        placeType: PlaceType,
        isEnabled: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.placeType = placeType
        self.isEnabled = isEnabled
        self.createdAt = createdAt
    }
    
    var regionIdentifier: String {
        "exitreminder_\(id.uuidString)"
    }
    
    static let radiusRange: ClosedRange<Double> = 50...300
}
