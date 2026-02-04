import SwiftUI

struct CreateReminderScreen: View {
    @StateObject var viewModel: CreateReminderViewModel
    @EnvironmentObject private var router: Router
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        CreateReminderContentSection(
            title: $viewModel.title,
            latitude: $viewModel.latitude,
            longitude: $viewModel.longitude,
            radius: $viewModel.radius,
            placeType: $viewModel.placeType,
            radiusText: viewModel.radiusText,
            onUseCurrentLocation: viewModel.useCurrentLocation
        )
        .navigationTitle("New Reminder")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    router.pop()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveReminder()
                }
                .fontWeight(.semibold)
                .disabled(!viewModel.isValid)
            }
        }
        .alert("Error", isPresented: $viewModel.showValidationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.validationErrorMessage)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    private func saveReminder() {
        if viewModel.createReminder() {
            router.pop()
        }
    }
}
