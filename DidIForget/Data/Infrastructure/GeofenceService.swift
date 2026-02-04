import Foundation
import Combine
import CoreLocation

/// Contrato que define las responsabilidades del servicio de geofences
/// - Gestiona permisos de ubicación y notificaciones
/// - Controla el monitoreo de regiones geográficas
/// - Proporciona acceso al estado de autorizaciones
protocol GeofenceServiceContract {
    var locationAuthorizationStatus: Published<Bool>.Publisher { get }
    var notificationAuthorizationStatus: Published<Bool>.Publisher { get }
    
    var isLocationAuthorizedAlways: Bool { get }
    var isLocationDenied: Bool { get }
    var isLocationNotDetermined: Bool { get }
    var isNotificationAuthorized: Bool { get }
    var isNotificationDenied: Bool { get }
    var isNotificationNotDetermined: Bool { get }
    
    func requestLocationPermission()
    func requestNotificationPermission(completion: @escaping (Bool) -> Void)
    func refreshPermissions()
    
    func startMonitoring(reminder: ExitReminder)
    func stopMonitoring(reminder: ExitReminder)
    func syncMonitoredRegions(with reminders: [ExitReminder])
    
    func requestCurrentLocation()
    func getCurrentLatitude() -> Double?
    func getCurrentLongitude() -> Double?
    
    /// Debug methods for testing notifications
    func debugTriggerInstantNotification(for reminder: ExitReminder)
    func debugScheduleDelayedNotification(for reminder: ExitReminder, delaySeconds: TimeInterval)
}

/// Servicio principal que coordina la funcionalidad de geofences
/// Actúa como fachada que integra LocationManager y NotificationManager
/// Flujo de datos: User Action → GeofenceService → (LocationManager/NotificationManager) → Repository
final class GeofenceService: NSObject, GeofenceServiceContract {
    /// Dependencias inyectadas para seguir principios SOLID
    private let locationManager: LocationManager        // Gestiona CoreLocation y geofences
    private let notificationManager: NotificationManager // Gestiona UserNotifications
    private let repository: ExitReminderRepositoryContract // Acceso a datos persistidos
    
    /// Publicadores del estado de autorizaciones para que la UI pueda reaccionar a cambios
    @Published private var locationAuthorized: Bool = false     // true cuando tenemos permiso 'Always'
    @Published private var notificationAuthorized: Bool = false // true cuando tenemos permiso de notificaciones
    
    var locationAuthorizationStatus: Published<Bool>.Publisher {
        $locationAuthorized
    }
    var notificationAuthorizationStatus: Published<Bool>.Publisher {
        $notificationAuthorized
    }
    
    var isLocationAuthorizedAlways: Bool {
        locationManager.isAuthorizedAlways
    }
    var isLocationDenied: Bool {
        locationManager.isDenied
    }
    var isLocationNotDetermined: Bool {
        locationManager.isNotDetermined
    }
    var isNotificationAuthorized: Bool {
        notificationManager.isAuthorized
    }
    var isNotificationDenied: Bool {
        notificationManager.isDenied
    }
    var isNotificationNotDetermined: Bool {
        notificationManager.isNotDetermined
    }
    
    init(
        locationManager: LocationManager,
        notificationManager: NotificationManager,
        repository: ExitReminderRepositoryContract
    ) {
        self.locationManager = locationManager
        self.notificationManager = notificationManager
        self.repository = repository
        super.init()
        
        locationManager.delegate = self
        notificationManager.delegate = self
        
        refreshPermissions()
    }
    
    /// Solicita permiso de ubicación siempre que sea posible
    /// Estrategia: Si no está determinado → solicitar When In Use
    ///          Si solo es 'When in Use' → actualizar a 'Always'
    func requestLocationPermission() {
        if locationManager.isNotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if locationManager.isAuthorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        notificationManager.requestAuthorization(completion: completion)
    }
    
    func refreshPermissions() {
        locationAuthorized = locationManager.isAuthorizedAlways
        notificationManager.refreshAuthorizationStatus()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.notificationAuthorized = self?.notificationManager.isAuthorized ?? false
        }
    }
    
    func startMonitoring(reminder: ExitReminder) {
        guard locationManager.isAuthorizedAlways else { return }
        locationManager.startMonitoring(reminder: reminder)
    }
    
    func stopMonitoring(reminder: ExitReminder) {
        locationManager.stopMonitoring(reminder: reminder)
        notificationManager.cancelNotification(for: reminder)
    }
    
    /// Sincroniza las regiones monitoreadas con los reminders activos
    /// Flujo: 1) Filtrar reminders habilitados
    ///        2) Remover regiones obsoletas
    ///        3) Agregar nuevas regiones faltantes
    /// Esto mantiene consistencia entre datos persistidos y CoreLocation
    func syncMonitoredRegions(with reminders: [ExitReminder]) {
        let enabledReminders = reminders.filter { $0.isEnabled }
        let enabledIdentifiers = Set(enabledReminders.map { $0.regionIdentifier })
        let monitoredIdentifiers = locationManager.monitoredRegionIdentifiers
        
        for identifier in monitoredIdentifiers {
            if identifier.hasPrefix("exitreminder_") && !enabledIdentifiers.contains(identifier) {
                locationManager.stopMonitoring(regionIdentifier: identifier)
                notificationManager.cancelNotification(identifier: identifier)
            }
        }
        
        for reminder in enabledReminders {
            if !monitoredIdentifiers.contains(reminder.regionIdentifier) {
                startMonitoring(reminder: reminder)
            }
        }
    }
    
    func requestCurrentLocation() {
        locationManager.requestCurrentLocation()
    }
    
    func getCurrentLatitude() -> Double? {
        locationManager.getCurrentLocation()?.coordinate.latitude
    }
    
    func getCurrentLongitude() -> Double? {
        locationManager.getCurrentLocation()?.coordinate.longitude
    }
    
    // MARK: - Debug Methods
    
    func debugTriggerInstantNotification(for reminder: ExitReminder) {
        notificationManager.scheduleExitNotification(for: reminder)
    }
    
    func debugScheduleDelayedNotification(for reminder: ExitReminder, delaySeconds: TimeInterval) {
        notificationManager.scheduleDelayedNotification(for: reminder, delay: delaySeconds)
    }
}

extension GeofenceService: LocationManagerDelegate {
    /// Maneja el evento de salida de una región geofence
    /// Flujo: 1) Validar que sea un reminder válido
    ///        2) Buscar en repository por UUID
    ///        3) Verificar que esté habilitado
    ///        4) Programar notificación inmediata
    func didExitRegion(identifier: String) {
        guard identifier.hasPrefix("exitreminder_") else { return }
        
        let uuidString = String(identifier.dropFirst("exitreminder_".count))
        guard let uuid = UUID(uuidString: uuidString),
              let reminder = repository.find(by: uuid),
              reminder.isEnabled else {
            return
        }
        
        notificationManager.scheduleExitNotification(for: reminder)
    }
    
    func didUpdateAuthorizationStatus(_ status: CLAuthorizationStatus) {
        locationAuthorized = status == .authorizedAlways
    }
}

extension GeofenceService: NotificationManagerDelegate {
    func didReceiveNotificationInForeground(identifier: String) {
        // Notification already displayed via completionHandler in NotificationManager
    }
}
