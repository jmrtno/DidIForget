import SwiftUI

#if DEBUG
struct DebugNotificationView: View {
    let reminder: ExitReminder
    let onTestInstant: () -> Void
    let onTestBackground: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Debug: \(reminder.title)")
                .font(.caption)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                Button(action: onTestInstant) {
                    VStack(spacing: 4) {
                        Image(systemName: "bell.badge.fill")
                            .font(.title3)
                        Text("Instant")
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                
                Button(action: onTestBackground) {
                    VStack(spacing: 4) {
                        Image(systemName: "clock.badge.fill")
                            .font(.title3)
                        Text("5s Delay")
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            }
            
            Text("Use '5s Delay' to test background/closed app notifications")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
#endif
