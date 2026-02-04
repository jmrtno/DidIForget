import SwiftUI

struct CreateReminderContentSection: View {
    @Binding var title: String
    @Binding var latitude: String
    @Binding var longitude: String
    @Binding var radius: Double
    @Binding var placeType: PlaceType
    let radiusText: String
    let onUseCurrentLocation: () -> Void
    
    var body: some View {
        Form {
            Section {
                TextField("What might you forget?", text: $title)
                    .textInputAutocapitalization(.sentences)
            } header: {
                Text("Reminder")
            } footer: {
                Text("e.g., \"Did I lock the door?\", \"Did I turn off the stove?\"")
            }
            
            Section {
                Picker("Place Type", selection: $placeType) {
                    ForEach(PlaceType.allCases) { type in
                        Label(type.displayName, systemImage: type.iconName)
                            .tag(type)
                    }
                }
                .pickerStyle(.menu)
            } header: {
                Text("Place Type")
            }
            
            Section {
                HStack {
                    Text("Latitude")
                    Spacer()
                    TextField("0.000000", text: $latitude)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }
                
                HStack {
                    Text("Longitude")
                    Spacer()
                    TextField("0.000000", text: $longitude)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }
                
                Button(action: onUseCurrentLocation) {
                    Label("Use Current Location", systemImage: "location.fill")
                }
            } header: {
                Text("Location")
            } footer: {
                Text("The reminder will trigger when you exit this location.")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Radius")
                        Spacer()
                        Text(radiusText)
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(
                        value: $radius,
                        in: ExitReminder.radiusRange,
                        step: 10
                    )
                }
            } header: {
                Text("Geofence Radius")
            } footer: {
                Text("Smaller radius = more precise but may trigger more often. Recommended: 100-150m.")
            }
            
            Section {
                NotificationInfoView()
            } header: {
                Text("Important Information")
            }
        }
    }
}

struct NotificationInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            InfoRowView(
                icon: "bell.badge.fill",
                iconColor: .blue,
                text: "Notifications will appear even when your phone is silenced."
            )
            
            InfoRowView(
                icon: "speaker.slash.fill",
                iconColor: .orange,
                text: "Sound will NOT play if your device is muted (silent switch)."
            )
            
            InfoRowView(
                icon: "speaker.wave.2.fill",
                iconColor: .green,
                text: "Keep your phone unmuted if you want audible alerts."
            )
        }
        .padding(.vertical, 4)
    }
}

struct InfoRowView: View {
    let icon: String
    let iconColor: Color
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 20)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
