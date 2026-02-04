import Foundation
import Combine

/// ViewModel para la pantalla principal de lista de reminders
/// Responsabilidades:
/// - Gestionar el estado de la lista de reminders
/// - Manejar permisos de ubicación y notificaciones
/// - Coordinar acciones del usuario con los use cases
/// - Mantener sincronización con GeofenceService mediante Combine
final class ReminderListViewModel: ObservableObject {
    // MARK: - Propiedades Publicadas (@Published)
    
    /// Lista de reminders mostrados en la UI
    /// @Published: Notifica a la vista cuando cambia la lista para actualizar automáticamente
    /// private(set): Solo el ViewModel puede modificar, la vista solo lee
    @Published private(set) var reminders: [ExitReminder] = []
    
    /// Estado del permiso de ubicación "Always"
    /// @Published: La UI reacciona para mostrar/hidir botones de permiso
    /// Se actualiza automáticamente mediante bindings con GeofenceService
    @Published private(set) var isLocationPermissionGranted: Bool = false
    
    /// Estado del permiso de notificaciones
    /// @Published: La UI reacciona para mostrar/hidir botones de permiso
    /// Se actualiza automáticamente mediante bindings con GeofenceService
    @Published private(set) var isNotificationPermissionGranted: Bool = false
    
    /// Controla la visibilidad del alert de permisos
    /// @Published: La UI muestra/oculta el alert automáticamente
    /// Modificable por la vista (no private) para permitir cierre manual
    @Published var showPermissionAlert: Bool = false
    
    /// Mensaje mostrado en el alert de permisos
    /// @Published: La UI actualiza el contenido del alert automáticamente
    /// Cambia según el tipo de permiso denegado
    @Published var permissionAlertMessage: String = ""
    
    // MARK: - Dependencias
    
    /// Use cases para operaciones de negocio con reminders
    private let fetchRemindersUseCase: FetchRemindersUseCase
    private let toggleReminderUseCase: ToggleReminderUseCase
    private let deleteReminderUseCase: DeleteReminderUseCase
    
    /// Servicio de geofences para permisos y monitoreo
    /// Fuente de eventos para los bindings de Combine
    private let geofenceService: GeofenceServiceContract
    
    /// Almacenamiento para las suscripciones de Combine
    /// Evita que se cancelen automáticamente los bindings
    private var cancellables = Set<AnyCancellable>()
    
    var isEmpty: Bool {
        reminders.isEmpty
    }
    
    var needsPermissions: Bool {
        !isLocationPermissionGranted || !isNotificationPermissionGranted
    }
    
    init(
        fetchRemindersUseCase: FetchRemindersUseCase,
        toggleReminderUseCase: ToggleReminderUseCase,
        deleteReminderUseCase: DeleteReminderUseCase,
        geofenceService: GeofenceServiceContract
    ) {
        self.fetchRemindersUseCase = fetchRemindersUseCase
        self.toggleReminderUseCase = toggleReminderUseCase
        self.deleteReminderUseCase = deleteReminderUseCase
        self.geofenceService = geofenceService
        
        setupBindings()
    }
    
    /// Configura las suscripciones reactivas con GeofenceService
    /// Usa el patrón Observer para mantener sincronizado el estado de permisos
    /// Flujo: GeofenceService → Publisher → receive(on:) → sink → UI update
    private func setupBindings() {
        // Binding para estado de permiso de ubicación
        geofenceService.locationAuthorizationStatus
            .receive(on: DispatchQueue.main) // Asegura actualización en hilo principal
            .sink { [weak self] authorized in // weak self para evitar retain cycles
                self?.isLocationPermissionGranted = authorized
            }
            .store(in: &cancellables) // Mantiene la suscripción activa
        
        // Binding para estado de permiso de notificaciones
        geofenceService.notificationAuthorizationStatus
            .receive(on: DispatchQueue.main) // Asegura actualización en hilo principal
            .sink { [weak self] authorized in // weak self para evitar retain cycles
                self?.isNotificationPermissionGranted = authorized
            }
            .store(in: &cancellables) // Mantiene la suscripción activa
    }
    
    func onAppear() {
        loadReminders()
        refreshPermissions()
    }
    
    func loadReminders() {
        reminders = fetchRemindersUseCase.execute()
        geofenceService.syncMonitoredRegions(with: reminders)
    }
    
    func refreshPermissions() {
        geofenceService.refreshPermissions()
        isLocationPermissionGranted = geofenceService.isLocationAuthorizedAlways
        isNotificationPermissionGranted = geofenceService.isNotificationAuthorized
    }
    
    /// Alterna el estado de un reminder (habilitado/deshabilitado)
    /// Flujo completo: UI → ViewModel → UseCase → Repository → GeofenceService → CoreLocation
    func toggleReminder(_ reminder: ExitReminder) {
        let newState = !reminder.isEnabled
        toggleReminderUseCase.execute(reminderId: reminder.id, isEnabled: newState)
        
        if newState {
            geofenceService.startMonitoring(reminder: reminder)
        } else {
            geofenceService.stopMonitoring(reminder: reminder)
        }
        
        loadReminders()
    }
    
    func deleteReminder(_ reminder: ExitReminder) {
        geofenceService.stopMonitoring(reminder: reminder)
        deleteReminderUseCase.execute(reminderId: reminder.id)
        loadReminders()
    }
    
    func deleteReminders(at offsets: IndexSet) {
        for index in offsets {
            let reminder = reminders[index]
            geofenceService.stopMonitoring(reminder: reminder)
            deleteReminderUseCase.execute(reminderId: reminder.id)
        }
        loadReminders()
    }
    
    /// Solicita permiso de ubicación con manejo de errores
    /// Si está denegado, muestra alert para ir a Settings
    /// Si no está determinado, solicita el permiso
    func requestLocationPermission() {
        if geofenceService.isLocationDenied {
            permissionAlertMessage = "Location permission is denied. Please enable 'Always' location access in Settings to use exit reminders."
            showPermissionAlert = true
        } else {
            geofenceService.requestLocationPermission()
        }
    }
    
    /// Solicita permiso de notificaciones con manejo de errores
    /// Si está denegado, muestra alert para ir a Settings
    /// Si no está determinado, solicita el permiso y refresca estado
    func requestNotificationPermission() {
        if geofenceService.isNotificationDenied {
            permissionAlertMessage = "Notification permission is denied. Please enable notifications in Settings to receive exit reminders."
            showPermissionAlert = true
        } else {
            geofenceService.requestNotificationPermission { [weak self] _ in
                self?.refreshPermissions()
            }
        }
    }
    
    // MARK: - Debug Methods
    
    #if DEBUG
    func debugTestInstantNotification(for reminder: ExitReminder) {
        geofenceService.debugTriggerInstantNotification(for: reminder)
    }
    
    func debugTestBackgroundNotification(for reminder: ExitReminder) {
        // Schedule notification in 5 seconds - gives time to background/close the app
        geofenceService.debugScheduleDelayedNotification(for: reminder, delaySeconds: 5)
    }
    #endif
}
