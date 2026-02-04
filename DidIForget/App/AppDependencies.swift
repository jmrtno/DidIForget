import Foundation

final class AppDependencies {
    // MARK: - Data Layer
    
    private lazy var repository: ExitReminderRepositoryContract = {
        LocalExitReminderRepository()
    }()
    
    private lazy var locationManager: LocationManager = {
        LocationManager()
    }()
    
    private lazy var notificationManager: NotificationManager = {
        NotificationManager()
    }()
    
    // MARK: - Infrastructure
    
    lazy var geofenceService: GeofenceServiceContract = {
        GeofenceService(
            locationManager: locationManager,
            notificationManager: notificationManager,
            repository: repository
        )
    }()
    
    // MARK: - Use Cases
    
    lazy var fetchRemindersUseCase: FetchRemindersUseCase = {
        FetchRemindersUseCase(repository: repository)
    }()
    
    lazy var createReminderUseCase: CreateReminderUseCase = {
        CreateReminderUseCase(repository: repository)
    }()
    
    lazy var toggleReminderUseCase: ToggleReminderUseCase = {
        ToggleReminderUseCase(repository: repository)
    }()
    
    lazy var deleteReminderUseCase: DeleteReminderUseCase = {
        DeleteReminderUseCase(repository: repository)
    }()
}
