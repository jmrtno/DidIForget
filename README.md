# Did I Forget?

A location-based reminder iOS app that notifies you when you leave specific places. Never forget important items again when leaving home, work, or any custom location!

## 🎯 Purpose

"Did I Forget?" solves the common problem of leaving important items behind. The app uses geofencing technology to detect when you exit predefined areas and sends you timely reminders about what you should take with you.

## ✨ Features

- **Geofence-Based Reminders**: Create location-based reminders that trigger when you leave specific areas
- **Smart Location Types**: Choose between Home, Work, or Custom locations with appropriate icons
- **Adjustable Radius**: Set custom detection radius (50-300 meters) for precise location monitoring
- **Toggle Reminders**: Enable/disable reminders without deleting them
- **Permission Management**: Clear UI for requesting and managing location and notification permissions
- **Clean Architecture**: Well-structured codebase using Clean Architecture principles
- **SwiftUI Interface**: Modern, responsive user interface built with SwiftUI

## 🏗️ Architecture

The app follows **Clean Architecture** principles with clear separation of concerns:

### 📁 Project Structure

```
DidIForget/
├── App/
│   └── AppDependencies.swift          # Dependency injection container
├── Domain/
│   ├── Entities/
│   │   └── ExitReminder.swift         # Core business entity
│   ├── Contracts/
│   │   └── ExitReminderRepositoryContract.swift
│   └── UseCases/
│       ├── CreateReminderUseCase.swift
│       ├── DeleteReminderUseCase.swift
│       ├── FetchRemindersUseCase.swift
│       └── ToggleReminderUseCase.swift
├── Data/
│   ├── Repositories/
│   │   └── LocalExitReminderRepository.swift
│   └── Infrastructure/
│       ├── GeofenceService.swift      # Geofence management
│       ├── LocationManager.swift      # CoreLocation wrapper
│       └── NotificationManager.swift  # Push notifications
├── Presentation/
│   ├── ReminderList/
│   │   ├── ReminderListScreen.swift
│   │   ├── ReminderListViewModel.swift
│   │   └── Sections/
│   └── CreateReminder/
│       ├── CreateReminderScreen.swift
│       ├── CreateReminderViewModel.swift
│       └── Sections/
├── Navigation/
│   ├── AppCoordinator.swift           # Navigation coordinator
│   ├── Router.swift                   # Navigation state management
│   ├── Route.swift                    # Navigation routes
│   └── RouteViewFactory.swift         # View factory
└── Common/
    └── PermissionBannerView.swift     # Permission UI component
```

### 🔄 Data Flow

1. **User Interaction** → SwiftUI Views
2. **Views** → ViewModels (Presentation Layer)
3. **ViewModels** → Use Cases (Domain Layer)
4. **Use Cases** → Repository (Data Layer)
5. **Repository** → Infrastructure Services (Location/Notifications)

### 🎯 Core Components

#### ExitReminder Entity
```swift
struct ExitReminder: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var latitude: Double
    var longitude: Double
    var radius: Double
    var placeType: PlaceType
    var isEnabled: Bool
    let createdAt: Date
}
```

#### LocationManager
- Wraps CoreLocation functionality
- Handles permission requests
- Manages geofence monitoring
- Provides delegate pattern for location events

#### GeofenceService
- Coordinates between LocationManager and NotificationManager
- Handles region exit events
- Manages reminder lifecycle

## 🚀 Getting Started

### Prerequisites

- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/jmrtno/DidIForget.git
cd DidIForget
```

2. Open the project in Xcode:
```bash
open DidIForget.xcodeproj
```

3. Build and run the project on your device or simulator.

### Permissions Required

The app requires two key permissions:

1. **Location Services**: 
   - `Always` authorization for background geofence monitoring
   - Used to detect when you exit defined areas

2. **Notifications**: 
   - Required to send reminder notifications
   - Used to alert you when leaving locations

## 📱 Usage

### Creating a Reminder

1. Tap the "+" button to create a new reminder
2. Enter a descriptive title (e.g., "Take keys, wallet, phone")
3. Set location by:
   - Using current location
   - Entering custom coordinates
4. Choose place type (Home, Work, or Custom)
5. Adjust detection radius (50-300 meters)
6. Save the reminder

### Managing Reminders

- **Toggle**: Enable/disable reminders with the switch
- **Delete**: Swipe to delete unwanted reminders
- **View**: See all active reminders on the main screen

### Notification Flow

1. You leave a monitored area
2. iOS detects the region exit
3. App receives the geofence event
4. Local notification is sent immediately
5. You see the reminder with your custom message

## 🛠️ Technical Details

### Geofencing Implementation

- Uses `CLCircularRegion` for circular geofences
- `notifyOnExit = true` (only triggers on exit)
- `notifyOnEntry = false` (no entry notifications)
- Supports up to 20 simultaneous monitored regions (iOS limit)

### Data Persistence

- Reminders stored locally using `UserDefaults`
- Codable protocol for JSON serialization
- Automatic persistence on any change

### Background Execution

- Uses `BGAppRefreshTaskReason` for background processing
- Geofence monitoring works even when app is suspended
- Notifications delivered via iOS background services

### Debug Features

Debug builds include additional features:
- **Test Instant Notification**: Trigger immediate notification
- **Test Background Notification**: Simulate background trigger
- Useful for testing without physical location changes

## 🧪 Testing

### Manual Testing

1. **Permission Testing**: Test all permission states and flows
2. **Geofence Testing**: Use actual device location changes
3. **Notification Testing**: Verify notification delivery
4. **Background Testing**: Test app behavior in background

### Debug Testing

Use debug features to test without moving:
- Enable debug mode in build settings
- Use "Test Instant Notification" for immediate testing
- Use "Test Background Notification" for background simulation

## 🔧 Configuration

### Build Settings

- **iOS Deployment Target**: 16.0
- **Swift Language Version**: 5.7
- **Architecture**: Clean Architecture with MVVM

### Environment Configurations

- **Debug**: Includes debug features and verbose logging
- **Release**: Optimized build with production settings

## 📋 Requirements

### Functional Requirements

- ✅ Create location-based reminders
- ✅ Monitor geofence regions for exit events
- ✅ Send local notifications on region exit
- ✅ Manage reminder lifecycle (create, toggle, delete)
- ✅ Handle permissions gracefully
- ✅ Persist data locally

### Non-Functional Requirements

- ✅ Responsive SwiftUI interface
- ✅ Clean, maintainable code architecture
- ✅ Proper error handling
- ✅ Background execution support
- ✅ iOS design guidelines compliance

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Apple CoreLocation framework for geofencing
- SwiftUI for modern UI development
- Clean Architecture principles for maintainable code

## 📞 Support

If you have any questions or issues, please open an issue on the GitHub repository.

---

**Made with ❤️ using SwiftUI and Clean Architecture**
