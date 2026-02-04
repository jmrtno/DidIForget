import SwiftUI

struct RouteViewFactory {
    let dependencies: AppDependencies
    
    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .reminderList:
            ReminderListScreen(
                viewModel: ReminderListViewModel(
                    fetchRemindersUseCase: dependencies.fetchRemindersUseCase,
                    toggleReminderUseCase: dependencies.toggleReminderUseCase,
                    deleteReminderUseCase: dependencies.deleteReminderUseCase,
                    geofenceService: dependencies.geofenceService
                )
            )
        case .createReminder:
            CreateReminderScreen(
                viewModel: CreateReminderViewModel(
                    createReminderUseCase: dependencies.createReminderUseCase,
                    geofenceService: dependencies.geofenceService
                )
            )
        }
    }
}
