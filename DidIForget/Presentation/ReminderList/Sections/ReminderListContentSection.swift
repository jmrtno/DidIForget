import SwiftUI

struct ReminderListContentSection: View {
    let reminders: [ExitReminder]
    let onToggle: (ExitReminder) -> Void
    let onDelete: (IndexSet) -> Void
    let onCreateTapped: () -> Void
    
    #if DEBUG
    let onTestInstant: (ExitReminder) -> Void
    let onTestBackground: (ExitReminder) -> Void
    @State private var selectedDebugReminder: ExitReminder?
    #endif
    
    var body: some View {
        List {
            ForEach(reminders) { reminder in
                ReminderRowView(
                    reminder: reminder,
                    onToggle: { onToggle(reminder) }
                )
                #if DEBUG
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        onTestInstant(reminder)
                    } label: {
                        Label("Test Now", systemImage: "bell.badge.fill")
                    }
                    .tint(.blue)
                    
                    Button {
                        onTestBackground(reminder)
                    } label: {
                        Label("Test 5s", systemImage: "clock.badge.fill")
                    }
                    .tint(.orange)
                }
                #endif
            }
            .onDelete(perform: onDelete)
            
            #if DEBUG
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Debug Mode", systemImage: "ladybug.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                    
                    Text("Swipe RIGHT on any reminder to test notifications:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("• **Test Now**: Instant notification (app open)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("• **Test 5s**: 5-second delay (close app to test background)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            #endif
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onCreateTapped) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct ReminderRowView: View {
    let reminder: ExitReminder
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: reminder.placeType.iconName)
                .font(.title2)
                .foregroundColor(reminder.isEnabled ? .accentColor : .secondary)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.body)
                    .foregroundColor(reminder.isEnabled ? .primary : .secondary)
                
                Text("\(reminder.placeType.displayName) • \(Int(reminder.radius))m radius")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { reminder.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}
