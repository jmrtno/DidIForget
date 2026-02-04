import SwiftUI

struct ReminderListScreen: View {
    @StateObject var viewModel: ReminderListViewModel
    @EnvironmentObject private var router: Router
    
    var body: some View {
        ZStack {
            if viewModel.isEmpty {
                ReminderListEmptyView(onCreateTapped: navigateToCreate)
            } else {
                #if DEBUG
                ReminderListContentSection(
                    reminders: viewModel.reminders,
                    onToggle: viewModel.toggleReminder,
                    onDelete: viewModel.deleteReminders,
                    onCreateTapped: navigateToCreate,
                    onTestInstant: viewModel.debugTestInstantNotification,
                    onTestBackground: viewModel.debugTestBackgroundNotification
                )
                #else
                ReminderListContentSection(
                    reminders: viewModel.reminders,
                    onToggle: viewModel.toggleReminder,
                    onDelete: viewModel.deleteReminders,
                    onCreateTapped: navigateToCreate
                )
                #endif
            }
        }
        .navigationTitle("Did I Forget?")
        .safeAreaInset(edge: .bottom) {
            if viewModel.needsPermissions {
                PermissionBannerView(
                    isLocationGranted: viewModel.isLocationPermissionGranted,
                    isNotificationGranted: viewModel.isNotificationPermissionGranted,
                    onRequestLocation: viewModel.requestLocationPermission,
                    onRequestNotification: viewModel.requestNotificationPermission
                )
            }
        }
        .alert("Permission Required", isPresented: $viewModel.showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.permissionAlertMessage)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    private func navigateToCreate() {
        router.push(.createReminder)
    }
}
