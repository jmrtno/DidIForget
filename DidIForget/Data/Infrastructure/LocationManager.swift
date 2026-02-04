import Foundation
import CoreLocation
import Combine

/// Protocolo de delegado para eventos de ubicación
/// Permite que GeofenceService reaccione a cambios de estado y eventos de geofence
protocol LocationManagerDelegate: AnyObject {
    func didExitRegion(identifier: String)           // Se activa cuando el usuario sale de una región
    func didUpdateAuthorizationStatus(_ status: CLAuthorizationStatus) // Cambia el estado de permisos
}

/// Wrapper de CoreLocation que abstrae la complejidad del manejo de ubicación
/// Responsabilidades:
/// - Gestionar permisos de ubicación
/// - Monitorear regiones geofence (solo salida)
/// - Proporcionar acceso a la ubicación actual
/// Flujo: GeofenceService → LocationManager → CoreLocation → Delegate
final class LocationManager: NSObject {
    /// Componente principal de CoreLocation para toda la funcionalidad de ubicación
    private let locationManager: CLLocationManager
    /// Última ubicación conocida del usuario (se actualiza continuamente)
    private var currentLocation: CLLocation?
    
    weak var delegate: LocationManagerDelegate?
    
    /// Estado actual de autorización de ubicación
    /// Se mantiene en caché para acceso rápido y notificación de cambios
    private(set) var authorizationStatus: CLAuthorizationStatus
    
    var isAuthorizedAlways: Bool {
        authorizationStatus == .authorizedAlways
    }
    
    var isAuthorizedWhenInUse: Bool {
        authorizationStatus == .authorizedWhenInUse
    }
    
    var isDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }
    
    var isNotDetermined: Bool {
        authorizationStatus == .notDetermined
    }
    
    /// Configura CoreLocation con los parámetros óptimos para geofences
    /// - Precisión máxima para detección precisa
    /// - Delegate para recibir eventos de ubicación
    override init() {
        self.locationManager = CLLocationManager()
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestCurrentLocation() {
        locationManager.requestLocation()
    }
    
    func getCurrentLocation() -> CLLocation? {
        currentLocation
    }
    
    /// Crea una región geofence circular para monitorear salida de área
    /// Configuración específica: solo notifica al salir (notifyOnExit = true)
    /// Esto es clave para el caso de uso "Did I Forget?"
    func startMonitoring(reminder: ExitReminder) {
        let region = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: reminder.latitude, longitude: reminder.longitude),
            radius: reminder.radius,
            identifier: reminder.regionIdentifier
        )
        region.notifyOnEntry = false
        region.notifyOnExit = true
        
        locationManager.startMonitoring(for: region)
    }
    
    func stopMonitoring(reminder: ExitReminder) {
        for region in locationManager.monitoredRegions {
            if region.identifier == reminder.regionIdentifier {
                locationManager.stopMonitoring(for: region)
                break
            }
        }
    }
    
    func stopMonitoring(regionIdentifier: String) {
        for region in locationManager.monitoredRegions {
            if region.identifier == regionIdentifier {
                locationManager.stopMonitoring(for: region)
                break
            }
        }
    }
    
    func isMonitoring(reminder: ExitReminder) -> Bool {
        locationManager.monitoredRegions.contains { $0.identifier == reminder.regionIdentifier }
    }
    
    var monitoredRegionIdentifiers: Set<String> {
        Set(locationManager.monitoredRegions.map { $0.identifier })
    }
}

extension LocationManager: CLLocationManagerDelegate {
    /// Maneja cambios en el estado de autorización de ubicación
    /// Actualiza el estado local y notifica al delegado para reacciones en cadena
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        /// Automatically request Always after When In Use is granted
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
        
        delegate?.didUpdateAuthorizationStatus(status)
    }
    
    /// Evento crítico: el usuario ha salido de una región geofence
    /// Flujo: CoreLocation → LocationManager → GeofenceService → NotificationManager
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        delegate?.didExitRegion(identifier: circularRegion.identifier)
    }
    
    /// Actualiza la ubicación actual cuando CoreLocation proporciona nuevos datos
    /// Esta ubicación se usa para mostrar posición actual en la UI
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silent fail for location errors
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        // Silent fail for monitoring errors
    }
}
