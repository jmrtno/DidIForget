import SwiftUI

struct PermissionBannerView: View {
    let isLocationGranted: Bool
    let isNotificationGranted: Bool
    let onRequestLocation: () -> Void
    let onRequestNotification: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            if !isLocationGranted {
                PermissionRowView(
                    icon: "location.fill",
                    title: "Location Access Required",
                    description: "Enable 'Always' location to trigger reminders when you leave.",
                    buttonTitle: "Enable",
                    action: onRequestLocation
                )
            }
            
            if !isNotificationGranted {
                PermissionRowView(
                    icon: "bell.fill",
                    title: "Notifications Required",
                    description: "Enable notifications to receive exit alerts.",
                    buttonTitle: "Enable",
                    action: onRequestNotification
                )
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

struct PermissionRowView: View {
    let icon: String
    let title: String
    let description: String
    let buttonTitle: String
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(buttonTitle, action: action)
                .buttonStyle(.bordered)
                .controlSize(.small)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
